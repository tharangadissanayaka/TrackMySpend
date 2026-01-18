import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import 'api_service.dart';

class CategoryService {
  static final FirebaseFirestore _db = ApiService.db;

  // GET ALL CATEGORIES (OPTIONAL FILTER BY TYPE)
  static Future<List<Category>> getCategories({String? type}) async {
    final userId = ApiService.currentUserId;

    Future<List<Category>> fetchUserCategories() async {
      if (userId == null) return [];
      Query userQuery = _db
          .collection('categories')
          .where('userId', isEqualTo: userId);
      if (type != null) {
        userQuery = userQuery.where('type', isEqualTo: type);
      }
      final snap = await userQuery.get();
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['type'] is String) {
          data['type'] = (data['type'] as String).toLowerCase();
        }
        return Category.fromJson({'id': doc.id, ...data});
      }).toList();
    }

    Future<List<Category>> fetchDefaultCategories() async {
      Query defaultQuery = _db
          .collection('categories')
          .where('isDefault', isEqualTo: true);
      if (type != null) {
        defaultQuery = defaultQuery.where('type', isEqualTo: type);
      }
      final snap = await defaultQuery.get();
      return snap.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['type'] is String) {
          data['type'] = (data['type'] as String).toLowerCase();
        }
        return Category.fromJson({'id': doc.id, ...data});
      }).toList();
    }

    final results = await Future.wait([
      fetchUserCategories(),
      fetchDefaultCategories(),
    ]);

    final combined = <String, Category>{};
    for (final list in results) {
      for (final c in list) {
        combined[c.id] = c;
      }
    }

    if (combined.isEmpty) {
      Query anyQuery = _db.collection('categories');
      if (type != null) {
        anyQuery = anyQuery.where('type', isEqualTo: type);
      }
      final anySnapshot = await anyQuery.get();
      for (final doc in anySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['type'] is String) {
          data['type'] = (data['type'] as String).toLowerCase();
        }
        combined[doc.id] = Category.fromJson({'id': doc.id, ...data});
      }
    }

    return combined.values.toList();
  }

  // CREATE NEW CATEGORY
  static Future<Category> createCategory(Category category) async {
    final userId = ApiService.currentUserId;
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final docRef = await _db.collection('categories').add({
      ...category.toJson(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return Category(
      id: docRef.id,
      name: category.name,
      type: category.type,
      icon: category.icon,
      color: category.color,
    );
  }

  // GET CATEGORY  ID
  static Future<Category> getCategory(String id) async {
    final doc = await _db.collection('categories').doc(id).get();

    if (!doc.exists) {
      throw Exception('Category not found');
    }

    return Category.fromJson({
      'id': doc.id,
      ...doc.data() as Map<String, dynamic>,
    });
  }

  // UPDATE CATEGORY
  static Future<Category> updateCategory(String id, Category category) async {
    await _db.collection('categories').doc(id).update({
      ...category.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return Category(
      id: id,
      name: category.name,
      type: category.type,
      icon: category.icon,
      color: category.color,
    );
  }

  // DELETE CATEGORY
  static Future<void> deleteCategory(String id) async {
    await _db.collection('categories').doc(id).delete();
  }
}
