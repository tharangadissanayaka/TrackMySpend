import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  static final _firestore = FirebaseFirestore.instance;
  static final _auth = FirebaseAuth.instance;

  /// Get financial summary
  static Future<Map<String, dynamic>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = _auth.currentUser!.uid;

    Query query = _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId);

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final snapshot = await query.get();

    double totalIncome = 0;
    double totalExpenses = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num).toDouble();

      if (data['type'] == 'income') {
        totalIncome += amount;
      } else {
        totalExpenses += amount;
      }
    }

    return {
      'summary': {
        'totalIncome': totalIncome,
        'totalExpenses': totalExpenses,
        'balance': totalIncome - totalExpenses,
      },
    };
  }

  /// Get monthly financial report
  static Future<Map<String, dynamic>> getMonthlyReport({int? year}) async {
    final selectedYear = year ?? DateTime.now().year;
    final userId = _auth.currentUser!.uid;

    Map<int, double> monthlyIncome = {};
    Map<int, double> monthlyExpenses = {};

    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();

      if (date.year != selectedYear) continue;

      final month = date.month;
      final amount = (data['amount'] as num).toDouble();

      if (data['type'] == 'income') {
        monthlyIncome[month] = (monthlyIncome[month] ?? 0) + amount;
      } else {
        monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + amount;
      }
    }

    return {
      'year': selectedYear,
      'income': monthlyIncome,
      'expenses': monthlyExpenses,
    };
  }

  /// Get top spending categories
  static Future<Map<String, dynamic>> getTopCategories({
    DateTime? startDate,
    DateTime? endDate,
    String type = 'expense',
    int limit = 5,
  }) async {
    final userId = _auth.currentUser!.uid;

    Query query = _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type);

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    final snapshot = await query.get();

    final Map<String, double> categoryTotals = {};

    for (final doc in snapshot.docs) {
  final data = doc.data() as Map<String, dynamic>;

  final category = data['categoryName'] as String? ?? 'Unknown';
  final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;

  categoryTotals[category] =
      (categoryTotals[category] ?? 0) + amount;
}


    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'categories': sortedCategories
          .take(limit)
          .map((e) => {
                'category': e.key,
                'amount': e.value,
              })
          .toList(),
    };
  }
}
