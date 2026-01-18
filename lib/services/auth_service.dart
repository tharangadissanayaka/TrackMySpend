

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app_user;
import 'api_service.dart';

class AuthService {
  static final FirebaseAuth _auth = ApiService.auth;
  static final FirebaseFirestore _db = ApiService.db;

  // Pick the first non-empty, trimmed string from the list
  static String _firstNonEmpty(List<String?> values, {String defaultValue = 'User'}) {
    for (final v in values) {
      final s = (v ?? '').trim();
      if (s.isNotEmpty) return s;
    }
    return defaultValue;
  }

  // REGISTER
  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Keep Firebase Auth display name in sync for UI fallbacks
    await credential.user!.updateDisplayName(name);
    await credential.user!.reload();

    await _db.collection('users').doc(credential.user!.uid).set(
      {
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // LOGIN
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // If displayName is missing, try to hydrate it from Firestore
    final user = _auth.currentUser;
    if (user != null && (user.displayName == null || user.displayName!.isEmpty)) {
      try {
        final doc = await _db.collection('users').doc(user.uid).get();
        final data = doc.data();
        final name = _firstNonEmpty([
          data?['name'] as String?,
          (user.email ?? '').split('@').first,
        ]);
        if (name.isNotEmpty && name != (user.displayName ?? '')) {
          await user.updateDisplayName(name);
          await user.reload();
        }
      } catch (_) {
        // ignore; UI will still work using email fallback
      }
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // AUTH STATE STREAM
  static Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // CHECK IF USER IS LOGGED IN
  static Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // GET CURRENT USER DETAILS (safe fallback on permission errors)
  static Future<app_user.User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    await user.reload();
    final refreshed = _auth.currentUser;

    try {
      final doc = await _db.collection('users').doc(refreshed!.uid).get();
      if (!doc.exists) {
        // Log to console to avoid VM service issues on web
        // ignore: avoid_print
        print('getCurrentUser: Firestore doc missing; using Auth fallback');
        // Fallback to auth profile if Firestore doc missing
        final fallbackName = _firstNonEmpty([
          refreshed.displayName,
          (refreshed.email ?? '').split('@').first,
        ]);
        final fallbackEmail = _firstNonEmpty([
          refreshed.email,
        ], defaultValue: '');
        return app_user.User(
          id: refreshed.uid,
          name: fallbackName,
          email: fallbackEmail,
        );
      }
      final data = doc.data();
      // ignore: avoid_print
      print('getCurrentUser: Loaded from Firestore for uid=${refreshed.uid}');
      final resolvedName = _firstNonEmpty([
        data?['name'] as String?,
        refreshed!.displayName,
        (refreshed.email ?? '').split('@').first,
      ]);
      final resolvedEmail = _firstNonEmpty([
        data?['email'] as String?,
        refreshed.email,
      ], defaultValue: '');
      return app_user.User(
        id: refreshed.uid,
        name: resolvedName,
        email: resolvedEmail,
      );
    } catch (e) {
      // ignore: avoid_print
      print('getCurrentUser: Firestore read error; using Auth fallback. Error: $e');
      // Permission denied or other errors: return auth profile
      final fallbackName = _firstNonEmpty([
        refreshed!.displayName,
        (refreshed.email ?? '').split('@').first,
      ]);
      final fallbackEmail = _firstNonEmpty([
        refreshed.email,
      ], defaultValue: '');
      return app_user.User(
        id: refreshed.uid,
        name: fallbackName,
        email: fallbackEmail,
      );
    }
  }
}
