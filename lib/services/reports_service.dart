

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  
  static Future<Map<String, dynamic>> getSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return {
        'summary': {
          'totalIncome': 0.0,
          'totalExpenses': 0.0,
          'balance': 0.0,
        }
      };
    }

    double totalIncome = 0;
    double totalExpenses = 0;

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final amount = (data['amount'] as num).toDouble();
        final type = (data['type'] ?? '').toString().toLowerCase();

        final ts = data['date'];
        final date = ts is Timestamp ? ts.toDate() : null;

        if (startDate != null && date != null && date.isBefore(startDate)) continue;
        if (endDate != null && date != null && date.isAfter(endDate)) continue;

        if (type == 'income') {
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
        }
      };
    } catch (e) {
      print('ReportService.getSummary error: $e');
      return {
        'summary': {
          'totalIncome': 0.0,
          'totalExpenses': 0.0,
          'balance': 0.0,
        }
      };
    }
  }

  static Future<List<Map<String, dynamic>>> getTopCategories({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 5,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final Map<String, double> categoryTotals = {};

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .where('type', isEqualTo: 'expense')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final ts = data['date'];
        final date = ts is Timestamp ? ts.toDate() : null;
        if (startDate != null && date != null && date.isBefore(startDate)) continue;
        if (endDate != null && date != null && date.isAfter(endDate)) continue;

        final categoryName = data['categoryName'] ?? 'Unknown';
        final amount = (data['amount'] as num).toDouble();

        categoryTotals[categoryName] =
            (categoryTotals[categoryName] ?? 0) + amount;
      }

      final sorted = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sorted.take(limit).map((e) {
        return {
          'category': e.key,
          'amount': e.value,
        };
      }).toList();
    } catch (e) {
      print('ReportService.getTopCategories error: $e');
      return [];
    }
  }

  
  static Future<Map<String, Map<int, double>>> getMonthlyReport({
    int? year,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return {'income': {}, 'expenses': {}};

    final selectedYear = year ?? DateTime.now().year;

    Map<int, double> monthlyIncome = {};
    Map<int, double> monthlyExpenses = {};

    try {
      final snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();

        if (date.year != selectedYear) continue;

        final month = date.month;
        final amount = (data['amount'] as num).toDouble();
        final type = (data['type'] ?? '').toString().toLowerCase();

        if (type == 'income') {
          monthlyIncome[month] = (monthlyIncome[month] ?? 0) + amount;
        } else {
          monthlyExpenses[month] = (monthlyExpenses[month] ?? 0) + amount;
        }
      }
    } catch (e) {
      print('ReportService.getMonthlyReport error: $e');
    }

    return {
      'income': monthlyIncome,
      'expenses': monthlyExpenses,
    };
  }

 
  static Future<List<Map<String, dynamic>>> getCategoryTotals({
    required String type, 
  }) async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('type', isEqualTo: type)
        .get();

    final Map<String, double> totals = {};
    final Map<String, String> colors = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final category = data['categoryName'] ?? 'Unknown';
      final amount = (data['amount'] as num).toDouble();

      totals[category] = (totals[category] ?? 0) + amount;
      colors[category] = data['categoryColor'] ?? '#9e9e9e';
    }

    return totals.entries.map((e) {
      return {
        'category': e.key,
        'amount': e.value,
        'color': colors[e.key],
      };
    }).toList();
  }
}
