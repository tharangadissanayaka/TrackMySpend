import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // REGISTER NEW USER
  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final UserCredential credential =
        await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _db.collection('users').doc(credential.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // LOGIN USER
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // LOGOUT USER
  static Future<void> logout() async {
    await _auth.signOut();
  }

  // CHECK IF USER IS LOGGED IN
  static Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  // GET CURRENT USER DETAILS
  static Future<app_user.User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return app_user.User(
      id: user.uid,
      name: doc['name'],
      email: doc['email'],
    );
  }

  // UPDATE USER PROFILE
  static Future<void> updateProfile({
    String? name,
    Map<String, dynamic>? preferences,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (preferences != null) updateData['preferences'] = preferences;

    await _db.collection('users').doc(user.uid).update(updateData);
  }
}
