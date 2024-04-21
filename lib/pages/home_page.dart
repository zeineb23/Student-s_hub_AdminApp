import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_6/components/app_bar_drawer.dart';
import 'package:flutter_application_6/pages/login_page.dart';
import 'package:flutter_application_6/pages/messages_page.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key});

  final User? user = FirebaseAuth.instance.currentUser;
  void signUserOut() {
    FirebaseAuth.instance.signOut();
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

  void _deleteCategory(String categoryId) async {
    try {
      await categoryCollection.doc(categoryId).delete();
      print("Category deleted successfully");
    } catch (e) {
      print("Error deleting category: $e");
    }
  }

  void _editCategory(String categoryId, String newCategoryName,
      String newCategoryDescription) async {
    try {
      await categoryCollection.doc(categoryId).update({
        "nom_cat": newCategoryName,
        "description_cat": newCategoryDescription,
      });
      print("Category edited successfully");
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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Les Catégories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;
                    String categoryId = snapshot.data!.docs[index].id;
                    String categoryName =
                        data['nom_cat']; // Récupération du nom de la catégorie

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MessagesPage(
                                categoryId: categoryId,
                                categoryName: categoryName),
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
                          title: Text(data['nom_cat']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['description_cat']),
                              Row(
                                children: [
                                  Spacer(),
                                  MaterialButton(
                                    onPressed: () {
                                      _deleteCategory(categoryId);
                                    },
                                    padding: EdgeInsets.zero,
                                    shape: CircleBorder(),
                                    color: Colors.red,
                                    child:
                                        Icon(Icons.delete, color: Colors.white),
                                  ),
                                  SizedBox(width: 8),
                                  MaterialButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          String newCategoryName =
                                              data['nom_cat'];
                                          String newCategoryDescription =
                                              data['description_cat'];
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
                                                          text:
                                                              data['nom_cat']),
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
                                                          text: data[
                                                              'description_cat']),
                                                ),
                                              ],
                                            ),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                onPressed: () {
                                                  _editCategory(
                                                      categoryId,
                                                      newCategoryName,
                                                      newCategoryDescription);
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Save'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    shape: CircleBorder(),
                                    color: Colors.blue,
                                    child:
                                        Icon(Icons.edit, color: Colors.white),
                                  ),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward_ios),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LoginPage(), // Navigate to MessagesPage
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
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
