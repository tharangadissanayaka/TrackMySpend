import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/reports_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;

  List<Map<String, dynamic>> expenseData = [];
  List<Map<String, dynamic>> incomeData = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _loading = true);

    final expenses =
        await ReportService.getCategoryTotals(type: 'expense');
    final incomes =
        await ReportService.getCategoryTotals(type: 'income');

    setState(() {
      expenseData = expenses;
      incomeData = incomes;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Reports'),
        backgroundColor: Color.fromARGB(255, 7, 7, 7),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _chartCard(
                    title: 'Expenses by Category',
                    data: expenseData,
                    emptyText: 'No expense data available',
                  ),
                  const SizedBox(height: 24),
                  _chartCard(
                    title: 'Income by Category',
                    data: incomeData,
                    emptyText: 'No income data available',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _chartCard({
    required String title,
    required List<Map<String, dynamic>> data,
    required String emptyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 15, 211, 165),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(31, 246, 242, 242),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          data.isEmpty
              ? Center(child: Text(emptyText))
              : SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 45,
                      sections: _buildSections(data),
                    ),
                  ),
                ),

          const SizedBox(height: 16),
          _legend(data),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
      List<Map<String, dynamic>> data) {
    final total = data.fold<double>(
        0, (sum, item) => sum + item['amount']);

    return data.map((item) {
      final percent = (item['amount'] / total) * 100;

      return PieChartSectionData(
        value: item['amount'],
        title: '${percent.toStringAsFixed(1)}%',
        radius: 65,
        color: _hexToColor(item['color']),
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      );
    }).toList();
  }

 
  Widget _legend(List<Map<String, dynamic>> data) {
    return Column(
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _hexToColor(item['color']),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(item['category'])),
              Text(
                '\$${item['amount'].toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

 
  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }
}
