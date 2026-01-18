import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../models/category.dart';
import '../services/transaction_service.dart';
import '../services/category_service.dart';

class AddTransactionScreen extends StatefulWidget {
  final String initialType;

  const AddTransactionScreen({
    super.key,
    this.initialType = 'expense',
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'expense';
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  bool _isSaving = false;
  bool _isLoadingCategories = true;

  List<Category> _categories = [];

  static const String _addNewCategoryId = '__add_new__';

  static const List<String> _defaultColors = [
    '#4caf50',
    '#2196f3',
    '#ff9800',
    '#9c27b0',
    '#009688',
    '#e91e63',
  ];

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType.toLowerCase();
    _loadCategories();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ---------------- LOAD CATEGORIES ----------------
  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);

    try {
      final result =
          await CategoryService.getCategories(type: _selectedType);

      if (!mounted) return;

      setState(() {
        _categories = result;
        _selectedCategory =
            _categories.isNotEmpty ? _categories.first : null;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
    }
  }

  // ---------------- ADD CATEGORY ----------------
  Future<void> _addNewCategory() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Category'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Category name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    final category = Category(
      id: '',
      name: name,
      type: _selectedType,
      icon: _selectedType == 'income' ? '💰' : '📁',
      color: _defaultColors[
          _categories.length % _defaultColors.length],
    );

    final created = await CategoryService.createCategory(category);

    setState(() {
      _categories.add(created);
      _selectedCategory = created;
    });
  }

  // ---------------- SAVE TRANSACTION ----------------
  Future<void> _saveTransaction() async {
  if (!_formKey.currentState!.validate()) return;

  if (_selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a category')),
    );
    return;
  }

  setState(() => _isSaving = true);

  try {
    final transaction = Transaction(
      id: '',
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      type: _selectedType,
      date: _selectedDate,
      notes:
          _notesController.text.isEmpty ? null : _notesController.text,
      category: _selectedCategory!,
    );

    await TransactionService.createTransaction(transaction);

    if (!mounted) return;

    // ✅ SUCCESS MESSAGE
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction added successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // ✅ CLEAR FORM (keep type & category)
    _formKey.currentState!.reset();
    _amountController.clear();
    _descriptionController.clear();
    _notesController.clear();

    setState(() {
      _selectedDate = DateTime.now();
    });

  } catch (e) {
    if (!mounted) return;

    // ❌ ERROR MESSAGE
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to add transaction'),
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _isSaving = false);
  }
}

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveTransaction,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- TYPE TOGGLE ----------
                    Row(
                      children: [
                        _typeButton(
                            'expense', Icons.arrow_downward, Colors.red),
                        _typeButton(
                            'income', Icons.arrow_upward, Colors.green),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _label('Amount'),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          v == null || double.tryParse(v) == null
                              ? 'Invalid amount'
                              : null,
                      decoration:
                          const InputDecoration(prefixText: '\$ '),
                    ),

                    const SizedBox(height: 20),

                    _label('Description'),
                    TextFormField(
                      controller: _descriptionController,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),

                    const SizedBox(height: 20),

                    _label('Category'),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory?.id,
                      items: [
                        ..._categories.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.icon} ${c.name}'),
                          ),
                        ),
                        const DropdownMenuItem(
                          value: _addNewCategoryId,
                          child: Text('➕ Add new category'),
                        ),
                      ],
                      onChanged: (value) async {
                        if (value == _addNewCategoryId) {
                          await _addNewCategory();
                        } else {
                          setState(() {
                            _selectedCategory = _categories
                                .firstWhere((c) => c.id == value);
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    _label('Date'),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        DateFormat('MMM dd, yyyy')
                            .format(_selectedDate),
                      ),
                      onTap: _pickDate,
                    ),

                    const SizedBox(height: 20),

                    _label('Notes'),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------- HELPERS ----------------
  Widget _typeButton(String type, IconData icon, Color color) {
    final selected = _selectedType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedType == type) return;

          setState(() {
            _selectedType = type;
            _selectedCategory = null;
          });

          _loadCategories(); // 🔑 THIS IS THE FIX
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? color.withOpacity(0.15)
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? color : Colors.grey),
              Text(
                type.toUpperCase(),
                style: TextStyle(
                  color: selected ? color : Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) setState(() => _selectedDate = picked);
  }
}
