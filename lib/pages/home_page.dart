import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_6/components/app_bar_drawer.dart';
import 'package:flutter_application_6/pages/messages_page.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('categorie');

  void _addCategory(String categoryName, String categoryDescription) async {
    if (categoryName.isNotEmpty && categoryDescription.isNotEmpty) {
      try {
        await categoryCollection.add({
          "nom_cat": categoryName,
          "description_cat": categoryDescription,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category added successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding category: $e")),
        );
      }
    }
  }

  void _deleteCategory(String? categoryId) async {
    if (categoryId != null) {
      try {
        await categoryCollection.doc(categoryId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category deleted successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting category: $e")),
        );
      }
    }
  }

  void _editCategory(String? categoryId, String newCategoryName,
      String newCategoryDescription) async {
    if (categoryId != null &&
        newCategoryName.isNotEmpty &&
        newCategoryDescription.isNotEmpty) {
      try {
        await categoryCollection.doc(categoryId).update({
          "nom_cat": newCategoryName,
          "description_cat": newCategoryDescription,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Category edited successfully")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error editing category: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        user: FirebaseAuth.instance.currentUser,
        signOut: () {
          FirebaseAuth.instance.signOut();
        },
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: categoryCollection.snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<DocumentSnapshot> docs = snapshot.data!.docs;

                final searchTerm = _searchController.text.toLowerCase();

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final categoryId = docs[index].id;
                    final categoryName = data['nom_cat'] as String? ?? '';
                    final categoryDescription =
                        data['description_cat'] as String? ?? '';

                    if (searchTerm.isNotEmpty &&
                        !categoryName.toLowerCase().contains(searchTerm)) {
                      return SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagesPage(
                              categoryId: categoryId,
                              categoryName: categoryName,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 3,
                        margin: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          title: Text(categoryName),
                          subtitle: Text(categoryDescription),
                          trailing: Container(
                            padding: EdgeInsets.only(top: 8.0),
                            child: PopupMenuButton(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    showEditDialog(context, categoryId,
                                        categoryName, categoryDescription);
                                    break;
                                  case 'delete':
                                    _deleteCategory(categoryId);
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry>[
                                PopupMenuItem(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddDialog(context);
        },
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }

  void showEditDialog(BuildContext context, String? categoryId,
      String initialCategoryName, String initialCategoryDescription) {
    TextEditingController nameController =
        TextEditingController(text: initialCategoryName);
    TextEditingController descriptionController =
        TextEditingController(text: initialCategoryDescription);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Category Description'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (categoryId != null) {
                  _editCategory(
                    categoryId,
                    nameController.text,
                    descriptionController.text,
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void showAddDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Category Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Category Description'),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                _addCategory(nameController.text, descriptionController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
