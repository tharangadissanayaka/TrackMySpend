import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';

class Transaction {
  String id;
  DateTime date;
  double amount;
  String type; // "income" or "expense"
  String description;
  String? notes;
  List<String> tags;

  // Relationship: belongs to one Category
  Category? category;

  Transaction({
    required this.id,
    required this.date,
    required this.amount,
    required this.type,
    required this.description,
    this.notes,
    this.tags = const [],
    this.category,
  });

  /* =========================
     🔹 FROM FIRESTORE
     ========================= */
  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Transaction(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      amount: (data['amount'] as num).toDouble(),
      type: data['type'],
      description: data['description'],
      notes: data['notes'],
      tags: List<String>.from(data['tags'] ?? []),
      category: data['category'] != null
          ? Category.fromJson(data['category'])
          : null,
    );
  }

  /* =========================
     🔹 TO FIRESTORE
     ========================= */
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'type': type,
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'tags': tags,
      'category': category?.toJson(), // embed category
      'categoryId': category?.id,     // for querying
    };
  }

  /* =========================
     🔹 OPTIONAL HELPERS
     ========================= */
  void addTransaction() {
    print("Transaction $id added.");
  }

  void editTransaction({double? newAmount, String? newDescription}) {
    if (newAmount != null) amount = newAmount;
    if (newDescription != null) description = newDescription;
    print("Transaction $id edited.");
  }

  void deleteTransaction() {
    print("Transaction $id deleted.");
  }

  Transaction getTransaction() {
    return this;
  }
}
