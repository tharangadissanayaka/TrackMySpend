import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/reports_service.dart';

import 'add_transaction_screen.dart';
import 'transaction_history_screen.dart';
import 'categories_screen.dart';
import 'reports_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? currentUser;
  List<Transaction> recentTransactions = [];
  Map<String, dynamic> summary = {};
  bool isLoading = true;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadData();
  });
  }

  // ---------------- LOAD DATA ----------------
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final user = await AuthService.getCurrentUser();
      if (!mounted) return;

      final transactions =
          await TransactionService.getTransactions(limit: 5);
      if (!mounted) return;

      final summaryData = await ReportService.getSummary();
      if (!mounted) return;

      setState(() {
        currentUser = user;
        recentTransactions = transactions;
        summary = summaryData ?? {};
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final summaryData = summary['summary'] ?? {};
    final totalIncome =
        (summaryData['totalIncome'] ?? 0).toDouble();
    final totalExpenses =
        (summaryData['totalExpenses'] ?? 0).toDouble();
    final balance = (summaryData['balance'] ?? 0).toDouble();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 252, 252),
      appBar: AppBar(
        title: Text('Hello, ${currentUser?.name ?? 'User'}!'),
        backgroundColor: const Color.fromARGB(255, 7, 7, 7),
        foregroundColor: const Color.fromARGB(221, 252, 247, 247),
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Color.fromARGB(255, 15, 211, 165)),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBalanceCard(balance, totalIncome, totalExpenses),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ---------------- BALANCE CARD ----------------
  Widget _buildBalanceCard(
      double balance, double income, double expenses) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 15, 211, 165), Color.fromARGB(255, 26, 140, 111)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Balance',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('\$${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              _amountColumn('Income', income),
              _amountColumn('Expenses', expenses, alignEnd: true),
            ],
          )
        ],
      ),
    );
  }

  Widget _amountColumn(String label, double value,
      {bool alignEnd = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text('\$${value.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---------------- QUICK ACTIONS ----------------
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickAction(
                Icons.add,
                'Add Transaction',
                const Color.fromARGB(255, 220, 227, 233),
                () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddTransactionScreen(),
                      ),
                    );

                    // ✅ ALWAYS reload when returning
                    _loadData();
                },

              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _quickAction(
                Icons.analytics,
                'View Reports',
                const Color.fromARGB(255, 249, 248, 249),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ReportsScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickAction(
      IconData icon, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 15, 211, 165),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ---------------- RECENT TRANSACTIONS ----------------
  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () async { 
                await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const TransactionHistoryScreen()),
              );           
            
              _loadData();
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        recentTransactions.isEmpty
            ? const Text('No transactions yet')
            : Column(
                children: recentTransactions
                    .map(_buildTransactionItem)
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    final isIncome = tx.type == 'income';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor:
            (isIncome ? Color.fromARGB(255, 15, 211, 165) : const Color.fromARGB(255, 8, 8, 8)).withOpacity(0.1),
        child: Text(tx.category?.icon ?? '💰'),
      ),
      title: Text(tx.description),
      subtitle: Text(tx.category?.name ?? 'Unknown'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(
                color: isIncome ? Color.fromARGB(255, 15, 211, 165) : const Color.fromARGB(255, 22, 21, 21),
                fontWeight: FontWeight.bold),
          ),
          Text(DateFormat('MMM dd').format(tx.date),
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // ---------------- BOTTOM NAV ----------------
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 5, 5, 5),
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Color.fromARGB(255, 15, 211, 165),      // active icon & text
    unselectedItemColor: const Color.fromARGB(255, 249, 248, 248),
      onTap: (index) async {
        if (index == 0) return;
        final pages = [
          null,
          const TransactionHistoryScreen(),
          const CategoriesScreen(),
          const ReportsScreen(),
        ];

        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => pages[index]!),
        );
        _loadData();
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(
            icon: Icon(Icons.category), label: 'Categories'),
        BottomNavigationBarItem(
            icon: Icon(Icons.analytics), label: 'Reports'),
      ],
    );
  }
}
