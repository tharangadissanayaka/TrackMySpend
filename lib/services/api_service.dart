

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  static FirebaseFirestore get db => FirebaseFirestore.instance;
  static FirebaseAuth get auth => FirebaseAuth.instance;

  static String? get currentUserId => auth.currentUser?.uid;

  static bool get isLoggedIn => auth.currentUser != null;
}


