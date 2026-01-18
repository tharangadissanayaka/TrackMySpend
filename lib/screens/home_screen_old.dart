// import 'package:flutter/material.dart';
// import '../models/transaction.dart';
// import '../models/category.dart';
// import 'add_transaction_screen.dart';
// import 'transaction_history_screen.dart';
// import 'categories_screen.dart';
// import 'reports_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // Sample data - in a real app, this would come from a database
//   double totalBalance = 2500.00;
//   double monthlyIncome = 5000.00;
//   double monthlyExpenses = 2500.00;

//   List<Transaction> recentTransactions = [
//     Transaction(
//       transactionId: 1,
//       date: DateTime.now().subtract(const Duration(days: 1)),
//       amount: 50.0,
//       type: "expense",
//       description: "Grocery shopping",
//       category: Category(categoryId: 1, name: "Food", type: "expense"),
//     ),
//     Transaction(
//       transactionId: 2,
//       date: DateTime.now().subtract(const Duration(days: 2)),
//       amount: 2000.0,
//       type: "income",
//       description: "Salary",
//       category: Category(categoryId: 2, name: "Salary", type: "income"),
//     ),
//     Transaction(
//       transactionId: 3,
//       date: DateTime.now().subtract(const Duration(days: 3)),
//       amount: 25.0,
//       type: "expense",
//       description: "Coffee",
//       category: Category(categoryId: 3, name: "Food", type: "expense"),
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text(
//           'Expense Tracker',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         backgroundColor: Colors.green[600],
//         foregroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.account_circle),
//             onPressed: () {
//               // TODO: Navigate to profile screen
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Balance Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24.0),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.green[600]!, Colors.green[800]!],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.green.withOpacity(0.3),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     'Total Balance',
//                     style: TextStyle(
//                       color: Colors.white70,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '\$${totalBalance.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Income and Expense Cards
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildSummaryCard(
//                     'Monthly Income',
//                     monthlyIncome,
//                     Colors.blue[600]!,
//                     Icons.trending_up,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: _buildSummaryCard(
//                     'Monthly Expenses',
//                     monthlyExpenses,
//                     Colors.red[600]!,
//                     Icons.trending_down,
//                   ),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 32),
            
//             // Quick Actions
//             const Text(
//               'Quick Actions',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
            
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _buildQuickAction(
//                   'Add Income',
//                   Icons.add_circle,
//                   Colors.green[600]!,
//                   () => _navigateToAddTransaction('income'),
//                 ),
//                 _buildQuickAction(
//                   'Add Expense',
//                   Icons.remove_circle,
//                   Colors.red[600]!,
//                   () => _navigateToAddTransaction('expense'),
//                 ),
//                 _buildQuickAction(
//                   'View Reports',
//                   Icons.bar_chart,
//                   Colors.blue[600]!,
//                   () => _navigateToReports(),
//                 ),
//               ],
//             ),
            
//             const SizedBox(height: 32),
            
//             // Recent Transactions
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Recent Transactions',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () => _navigateToTransactionHistory(),
//                   child: const Text('See All'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
            
//             // Transaction List
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: recentTransactions.take(5).length,
//               itemBuilder: (context, index) {
//                 final transaction = recentTransactions[index];
//                 return _buildTransactionItem(transaction);
//               },
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         selectedItemColor: Colors.green[600],
//         unselectedItemColor: Colors.grey[600],
//         currentIndex: 0,
//         onTap: (index) {
//           switch (index) {
//             case 1:
//               _navigateToTransactionHistory();
//               break;
//             case 2:
//               _navigateToCategories();
//               break;
//             case 3:
//               _navigateToReports();
//               break;
//           }
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.list),
//             label: 'Transactions',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.category),
//             label: 'Categories',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.analytics),
//             label: 'Reports',
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => _navigateToAddTransaction(''),
//         backgroundColor: Colors.green[600],
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildSummaryCard(String title, double amount, Color color, IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             '\$${amount.toStringAsFixed(2)}',
//             style: TextStyle(
//               color: color,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         children: [
//           Container(
//             width: 60,
//             height: 60,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(30),
//             ),
//             child: Icon(icon, color: color, size: 30),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//               color: Colors.grey[700],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionItem(Transaction transaction) {
//     final isExpense = transaction.type == 'expense';
//     final color = isExpense ? Colors.red[600]! : Colors.green[600]!;
//     final icon = isExpense ? Icons.remove_circle : Icons.add_circle;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Icon(icon, color: color, size: 20),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   transaction.description,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   transaction.category?.name ?? 'No Category',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontSize: 12,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '${isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   color: color,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 '${transaction.date.day}/${transaction.date.month}',
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _navigateToAddTransaction(String type) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddTransactionScreen(initialType: type),
//       ),
//     );
//   }

//   void _navigateToTransactionHistory() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const TransactionHistoryScreen(),
//       ),
//     );
//   }

//   void _navigateToCategories() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const CategoriesScreen(),
//       ),
//     );
//   }

//   void _navigateToReports() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ReportsScreen(),
//       ),
//     );
//   }
// }