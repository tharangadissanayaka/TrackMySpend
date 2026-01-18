// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/transaction.dart';
// import '../services/transaction_service.dart';
// import 'add_transaction_screen.dart';

// class TransactionHistoryScreen extends StatefulWidget {
//   const TransactionHistoryScreen({super.key});

//   @override
//   State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
// }

// class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
//   String _selectedFilter = 'All';
//   final List<String> _filterOptions = ['All', 'Income', 'Expense'];
  
//   List<Transaction> _transactions = [];
//   bool _isLoading = true;
//   bool _isLoadingMore = false;
//   int _currentPage = 1;
//   bool _hasMoreData = true;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _loadTransactions();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//       if (!_isLoadingMore && _hasMoreData) {
//         _loadMoreTransactions();
//       }
//     }
//   }

//   Future<void> _loadTransactions() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _currentPage = 1;
//       });

//       final String? typeFilter = _selectedFilter == 'All' 
//           ? null 
//           : _selectedFilter.toLowerCase();

//       final transactions = await TransactionService.getTransactions(
//   limit: 20,
//   type: typeFilter,
// );


//       setState(() {
//         _transactions = transactions;
//         _hasMoreData = transactions.length == 20;
//         _isLoading = false;
      
//             // ignore: avoid_print
//             print('History: initial fetch ${transactions.length} items (filter=${typeFilter ?? 'all'})');
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading transactions: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _loadMoreTransactions() async {
//     try {
//       setState(() => _isLoadingMore = true);

//       final String? typeFilter = _selectedFilter == 'All' 
//           ? null 
//           : _selectedFilter.toLowerCase();

//       final newTransactions = await TransactionService.getTransactions(
//   limit: 20,
//   type: typeFilter,
// );

      
//       // ignore: avoid_print
//       print('History: load more fetched ${newTransactions.length} items');

//       setState(() {
//         _transactions.addAll(newTransactions);
//         _currentPage++;
//         _hasMoreData = newTransactions.length == 20;
//         _isLoadingMore = false;
//       });
//     } catch (e) {
//       setState(() => _isLoadingMore = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading more transactions: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _deleteTransaction(Transaction transaction) async {
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Transaction'),
//         content: Text('Are you sure you want to delete "${transaction.description}"?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       try {
//         await TransactionService.deleteTransaction(transaction.id);
//         setState(() {
//           _transactions.removeWhere((t) => t.id == transaction.id);
//         });
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Transaction deleted successfully'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error deleting transaction: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       }
//     }
//   }

//   List<Transaction> get _filteredTransactions {
//     if (_selectedFilter == 'All') {
//       return _transactions;
//     }
//     return _transactions.where((transaction) => 
//         transaction.type.toLowerCase() == _selectedFilter.toLowerCase()).toList();
//   }

//   double get _totalAmount {
//     return _filteredTransactions.fold(0.0, (sum, transaction) {
//       return transaction.type == 'income' 
//           ? sum + transaction.amount 
//           : sum - transaction.amount;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         title: const Text('Transaction History'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black87,
//         elevation: 1,
        
//       ),
//       body: Column(
//         children: [
//           // Summary Card
//           Container(
//             margin: const EdgeInsets.all(16),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: _totalAmount >= 0 
//                     ? [Colors.green.shade400, Colors.green.shade600]
//                     : [Colors.red.shade400, Colors.red.shade600],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: (_totalAmount >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _selectedFilter == 'All' ? 'Net Total' : 'Total $_selectedFilter',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '${_totalAmount >= 0 ? '+' : ''}\$${_totalAmount.abs().toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '${_filteredTransactions.length} transactions',
//                   style: const TextStyle(
//                     color: Colors.white70,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Filter Chips
//           Container(
//             height: 50,
//             margin: const EdgeInsets.symmetric(horizontal: 16),
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: _filterOptions.length,
//               itemBuilder: (context, index) {
//                 final filter = _filterOptions[index];
//                 final isSelected = _selectedFilter == filter;
                
//                 return Container(
//                   margin: const EdgeInsets.only(right: 8),
//                   child: FilterChip(
//                     label: Text(filter),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       setState(() {
//                         _selectedFilter = filter;
//                       });
//                       _loadTransactions();
//                     },
//                     backgroundColor: Colors.white,
//                     selectedColor: Colors.blue.shade50,
//                     checkmarkColor: Colors.blue,
//                     side: BorderSide(
//                       color: isSelected ? Colors.blue : Colors.grey.shade300,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           const SizedBox(height: 16),

//           // Transactions List
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _transactions.isEmpty
//                     ? _buildEmptyState()
//                     : RefreshIndicator(
//                         onRefresh: _loadTransactions,
//                         child: ListView.builder(
//                           controller: _scrollController,
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           itemCount: _filteredTransactions.length + (_isLoadingMore ? 1 : 0),
//                           itemBuilder: (context, index) {
//                             if (index == _filteredTransactions.length) {
//                               return const Center(
//                                 child: Padding(
//                                   padding: EdgeInsets.all(16),
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               );
//                             }
                            
//                             final transaction = _filteredTransactions[index];
//                             return _buildTransactionItem(transaction);
//                           },
//                         ),
//                       ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.receipt_long,
//             size: 64,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No transactions found',
//             style: TextStyle(
//               fontSize: 18,
//               color: Colors.grey.shade600,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _selectedFilter == 'All' 
//                 ? 'Add your first transaction to get started'
//                 : 'No ${_selectedFilter.toLowerCase()} transactions found',
//             style: TextStyle(
//               color: Colors.grey.shade500,
//             ),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//             onPressed: () async {
//               final result = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const AddTransactionScreen(),
//                 ),
//               );
//               if (result == true) {
//                 _loadTransactions();
//               }
//             },
//             icon: const Icon(Icons.add),
//             label: const Text('Add Transaction'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.blue,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTransactionItem(Transaction transaction) {
//     final isIncome = transaction.type == 'income';
    
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 4,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Dismissible(
//         key: Key(transaction.id),
//         direction: DismissDirection.endToStart,
//         background: Container(
//           decoration: BoxDecoration(
//             color: Colors.red,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           alignment: Alignment.centerRight,
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: const Icon(
//             Icons.delete,
//             color: Colors.white,
//             size: 28,
//           ),
//         ),
//         confirmDismiss: (direction) async {
//           return await showDialog<bool>(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: const Text('Delete Transaction'),
//               content: Text('Are you sure you want to delete "${transaction.description}"?'),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(false),
//                   child: const Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(true),
//                   style: TextButton.styleFrom(foregroundColor: Colors.red),
//                   child: const Text('Delete'),
//                 ),
//               ],
//             ),
//           );
//         },
//         onDismissed: (direction) => _deleteTransaction(transaction),
//         child: ListTile(
//           contentPadding: const EdgeInsets.all(16),
//           leading: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: (isIncome ? Colors.green : Colors.red).withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Text(
//               transaction.category?.icon ?? (isIncome ? '💰' : '💸'),
//               style: const TextStyle(fontSize: 20),
//             ),
//           ),
//           title: Text(
//             transaction.description,
//             style: const TextStyle(
//               fontWeight: FontWeight.w600,
//               fontSize: 16,
//             ),
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 transaction.category?.name ?? 'Unknown',
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: 14,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 DateFormat('MMM dd, yyyy • hh:mm a').format(transaction.date),
//                 style: TextStyle(
//                   color: Colors.grey.shade500,
//                   fontSize: 12,
//                 ),
//               ),
//             ],
//           ),
//           trailing: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
//                 style: TextStyle(
//                   color: isIncome ? Colors.green : Colors.red,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 16,
//                 ),
//               ),
//               if (transaction.notes?.isNotEmpty == true)
//                 Container(
//                   margin: const EdgeInsets.only(top: 4),
//                   child: Icon(
//                     Icons.note,
//                     size: 16,
//                     color: Colors.grey.shade400,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/transaction_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Income', 'Expense'];

  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);

    final type =
        _selectedFilter == 'All' ? null : _selectedFilter.toLowerCase();

    final data = await TransactionService.getTransactions(
      limit: 50,
      type: type,
    );

    setState(() {
      _transactions = data;
      _isLoading = false;
    });
  }

  /* =========================
     🔹 DELETE TRANSACTION
     ========================= */
  Future<void> _deleteTransaction(Transaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: Text('Delete "${tx.description}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await TransactionService.deleteTransaction(tx.id);
      _loadTransactions();
    }
  }

  /* =========================
     🔹 EDIT TRANSACTION (DIALOG)
     ========================= */
  Future<void> _editTransaction(Transaction tx) async {
    final amountController =
        TextEditingController(text: tx.amount.toString());
    final descriptionController =
        TextEditingController(text: tx.description);
    final notesController =
        TextEditingController(text: tx.notes ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Transaction'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final updated = Transaction(
        id: tx.id,
        amount: double.parse(amountController.text),
        description: descriptionController.text,
        notes:
            notesController.text.isEmpty ? null : notesController.text,
        type: tx.type,
        date: tx.date,
        category: tx.category,
        tags: tx.tags,
      );

      await TransactionService.updateTransaction(tx.id, updated);
      _loadTransactions();
    }
  }

  /* =========================
     🔹 UI
     ========================= */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: const Color.fromARGB(255, 19, 18, 18),
        foregroundColor: const Color.fromARGB(221, 241, 237, 237),
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? const Center(child: Text('No transactions'))
                    : RefreshIndicator(
                        onRefresh: _loadTransactions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _transactions.length,
                          itemBuilder: (_, i) =>
                              _buildTransactionItem(_transactions[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (_, i) {
          final filter = _filterOptions[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: _selectedFilter == filter,
              onSelected: (_) {
                setState(() => _selectedFilter = filter);
                _loadTransactions();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    final isIncome = tx.type == 'income';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              (isIncome ? Colors.green : Colors.red).withOpacity(0.15),
          child: Text(tx.category?.icon ?? '📁'),
        ),
        title: Text(tx.description,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${tx.category?.name ?? 'Unknown'} • '
          '${DateFormat('MMM dd, yyyy').format(tx.date)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _editTransaction(tx);
            if (value == 'delete') _deleteTransaction(tx);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Delete',
                      style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

