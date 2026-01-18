import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Category> _incomeCategories = [];
  List<Category> _expenseCategories = [];
  bool _isLoading = true;

  // Available icons for categorie
  final List<String> _availableIcons = [
    '💼', '💻', '📈', '🎁', '🏆', '💰', '📊', '🎯',
    '🍔', '🚗', '🛍️', '📄', '🎬', '🏥', '📚', '✈️',
    '🏠', '⚡', '💧', '📱', '🎮', '🎵', '👕', '⛽',
    '🏋️', '💊', '🐕', '🎨', '📺', '☕', '🍕', '🎂'
  ];

  // Available colors for categories
  final List<Color> _availableColors = [
    Colors.red, Colors.green, Colors.blue, Colors.orange,
    Colors.purple, Colors.teal, Colors.pink, Colors.brown,
    Colors.indigo, Colors.cyan, Colors.amber, Colors.lime,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoading = true);
      
      final categories = await CategoryService.getCategories();
      
      setState(() {
        _incomeCategories = categories.where((c) => c.type == 'income').toList();
        _expenseCategories = categories.where((c) => c.type == 'expense').toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading categories: $e')),
        );
      }
    }
  }

  Future<void> _showAddCategoryDialog({Category? editCategory}) async {
    final TextEditingController nameController = TextEditingController(
      text: editCategory?.name ?? '',
    );
    String selectedIcon = editCategory?.icon ?? _availableIcons[0];
    Color selectedColor = editCategory?.color != null 
        ? Color(int.parse(editCategory!.color.substring(1), radix: 16) + 0xFF000000)
        : _availableColors[0];
    String selectedType = editCategory?.type ?? 
        (_tabController.index == 0 ? 'income' : 'expense');

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(editCategory == null ? 'Add Category' : 'Edit Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Category Type
                const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Income'),
                        value: 'income',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Expense'),
                        value: 'expense',
                        groupValue: selectedType,
                        onChanged: (value) {
                          setDialogState(() => selectedType = value!);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Icon Selection
                const Text('Icon', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      childAspectRatio: 1,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = selectedIcon == icon;
                      
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedIcon = icon),
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected ? selectedColor.withOpacity(0.2) : null,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected 
                                ? Border.all(color: selectedColor, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Color Selection
                const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableColors.map((color) {
                    final isSelected = selectedColor == color;
                    
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected 
                              ? Border.all(color: Colors.black, width: 3)
                              : Border.all(color: Colors.grey.shade300),
                        ),
                        child: isSelected 
                            ? const Icon(Icons.check, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a category name')),
                  );
                  return;
                }

                try {
                  final category = Category(
                    id: editCategory?.id ?? '',
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    color: '#${selectedColor.value.toRadixString(16).substring(2)}',
                    type: selectedType,
                  );

                  if (editCategory == null) {
                    await CategoryService.createCategory(category);
                  } else {
                    await CategoryService.updateCategory(editCategory.id, category);
                  }

                  Navigator.of(context).pop();
                  await _loadCategories();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(editCategory == null 
                            ? 'Category added successfully!'
                            : 'Category updated successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(editCategory == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(Category category) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await CategoryService.deleteCategory(category.id);
        await _loadCategories();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Categories'),
        backgroundColor: const Color.fromARGB(255, 23, 22, 22),
        foregroundColor: const Color.fromARGB(221, 235, 231, 231),
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
          ],
          labelColor: Color.fromARGB(255, 15, 211, 165),
          unselectedLabelColor: Colors.grey,
          indicatorColor: Color.fromARGB(255, 15, 211, 165),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCategoryList(_incomeCategories, 'income'),
                _buildCategoryList(_expenseCategories, 'expense'),
              ],
            ),
    );
  }

  Widget _buildCategoryList(List<Category> categories, String type) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category,
              size: 64,
              color: Color.fromARGB(255, 15, 211, 165),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type} categories found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first ${type} category to get started',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddCategoryDialog(),
              icon: const Icon(Icons.add),
              label: Text('Add ${type.capitalize()} Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: type == 'income' ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryItem(category);
        },
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    final color = Color(int.parse(category.color.substring(1), radix: 16) + 0xFF000000);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              category.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          category.type.capitalize(),
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        trailing: null,
      ),
            
      
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}