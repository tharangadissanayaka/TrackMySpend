import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  // Firebase Authentication instance
  static final FirebaseAuth auth = FirebaseAuth.instance;

  // Firestore database instance
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  // Get current logged-in user (Firebase User)
  static User? get currentUser => auth.currentUser;

  // Get current user ID
  static String? get currentUserId => auth.currentUser?.uid;

  // Check if user is logged in
  static bool isLoggedIn() {
    return auth.currentUser != null;
  }

  // Sign out user
  static Future<void> signOut() async {
    await auth.signOut();
  }
}
