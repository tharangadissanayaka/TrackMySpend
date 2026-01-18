import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction.dart' as model;

class TransactionService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;


  static Future<List<model.Transaction>> getTransactions({
    int limit = 20,
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    Query<Map<String, dynamic>> query = _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true);

    final snapshot = await query.limit(limit).get();

    List<model.Transaction> transactions =
        snapshot.docs.map((doc) {
      final data = doc.data();

      return model.Transaction(
        id: doc.id,
        date: (data['date'] as Timestamp).toDate(),
        amount: (data['amount'] ?? 0).toDouble(),
        type: data['type'] ?? '',
        description: data['description'] ?? '',
        notes: data['notes'],
        tags: List<String>.from(data['tags'] ?? []),
        category: null,
      );
    }).toList();

  
    if (type != null) {
      transactions =
          transactions.where((t) => t.type == type).toList();
    }

    if (startDate != null) {
      transactions =
          transactions.where((t) => t.date.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      transactions =
          transactions.where((t) => t.date.isBefore(endDate)).toList();
    }

    return transactions;
  }

 
  static Future<void> createTransaction(
      model.Transaction transaction) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('transactions').add({
      'userId': user.uid,
      'amount': transaction.amount,
      'type': transaction.type,
      'description': transaction.description,
      'notes': transaction.notes,
      'tags': transaction.tags,
      'date': Timestamp.fromDate(transaction.date),
      'categoryId': transaction.category?.id,
      'categoryName': transaction.category?.name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateTransaction(
      String id, model.Transaction transaction) async {
    await _firestore.collection('transactions').doc(id).update({
      'amount': transaction.amount,
      'type': transaction.type,
      'description': transaction.description,
      'notes': transaction.notes,
      'tags': transaction.tags,
      'date': Timestamp.fromDate(transaction.date),
      // Keep category fields in sync if changed
      'categoryId': transaction.category?.id,
      'categoryName': transaction.category?.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteTransaction(String id) async {
    await _firestore.collection('transactions').doc(id).delete();
  }
}
