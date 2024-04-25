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
  final User? user = FirebaseAuth.instance.currentUser;

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

  void _deleteCategory(String? categoryId) async {
    try {
      if (categoryId != null) {
        await categoryCollection.doc(categoryId).delete();
        print("Category deleted successfully");
      }
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  void _editCategory(String? categoryId, String newCategoryName,
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

                    // Filter categories based on search term
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
                          vertical: 8.0,
                          horizontal: 16.0,
                        ),
                        child: ListTile(
                          title: Text(categoryName),
                          subtitle: Text(categoryDescription),
                          trailing: Container(
                            padding: EdgeInsets.only(
                              top: 8.0,
                            ), // Adjust the top padding as needed
                            child: PopupMenuButton(
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry>[
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('Edit'),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          String newCategoryName = categoryName;
                                          String newCategoryDescription =
                                              categoryDescription;
                                          return AlertDialog(
                                            title: Text('Edit Category'),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                TextField(
                                                  onChanged: (value) {
                                                    newCategoryName = value;
                                                  },
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'Category Name'),
                                                  controller:
                                                      TextEditingController(
                                                          text: categoryName),
                                                ),
                                                TextField(
                                                  onChanged: (value) {
                                                    newCategoryDescription =
                                                        value;
                                                  },
                                                  decoration: InputDecoration(
                                                      labelText:
                                                          'Category Description'),
                                                  controller:
                                                      TextEditingController(
                                                          text:
                                                              categoryDescription),
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                onPressed: () {
                                                  _editCategory(
                                                    categoryId,
                                                    newCategoryName,
                                                    newCategoryDescription,
                                                  );
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Save'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                PopupMenuItem(
                                  child: ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('Delete'),
                                    onTap: () {
                                      _deleteCategory(categoryId);
                                    },
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
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String categoryName = '';
              String categoryDescription = '';
              return AlertDialog(
                title: Text('Add Category'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        categoryName = value;
                      },
                      decoration: InputDecoration(labelText: 'Category Name'),
                    ),
                    TextField(
                      onChanged: (value) {
                        categoryDescription = value;
                      },
                      decoration:
                          InputDecoration(labelText: 'Category Description'),
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _addCategory(categoryName, categoryDescription);
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Add Category',
        child: const Icon(Icons.add),
      ),
    );
  }
}
