import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesCRUD {
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categorie');

  void addCategory(String categoryName, String categoryDescription) async {
    try {
      await categoryCollection.add({
        "nom_cat": categoryName,
        "description_cat": categoryDescription,
      });
      print("Category added successfully");
    } catch (e) {
      print("Error adding category: $e");
    }
  }

  void deleteCategory(String? categoryId) async {
    try {
      if (categoryId != null) {
        await categoryCollection.doc(categoryId).delete();
        print("Category deleted successfully");
      }
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  void editCategory(String? categoryId, String newCategoryName,
      String newCategoryDescription) async {
    try {
      if (categoryId != null) {
        await categoryCollection.doc(categoryId).update({
          "nom_cat": newCategoryName,
          "description_cat": newCategoryDescription,
        });
        print("Category edited successfully");
      }
    } catch (e) {
      print("Error editing category: $e");
    }
  }

  static Future<QuerySnapshot> getCategories() async {
    return FirebaseFirestore.instance.collection('categorie').get();
  }
}
