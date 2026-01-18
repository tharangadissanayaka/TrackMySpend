class Category {
  String id;
  String name;
  String type; // e.g. "income" or "expense"
  String icon;
  String color;
  bool isDefault;

  // Relationship can have many transactions
  List<String> transactionIds = [];

  Category({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    this.isDefault = false,
  });

  // Create Category from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      icon: json['icon'] ?? '',
      color: json['color'] ?? '',
      isDefault: json['isDefault'] ?? false,
    );
  }

  // Convert Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
    };
  }

  void addCategory() {
    print("Category $name added.");
  }

  void editCategory({String? newName, String? newType}) {
    if (newName != null) name = newName;
    if (newType != null) type = newType;
    print("Category $id updated.");
  }

  void deleteCategory() {
    print("Category $id deleted.");
  }

  Category getCategory() {
    return this;
  }
}

