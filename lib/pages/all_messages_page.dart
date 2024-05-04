import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_6/components/app_bar_drawer.dart';
import 'package:flutter_application_6/pages/login_page.dart';
import 'package:flutter_application_6/services/categories.dart';
import 'package:flutter_application_6/services/messages.dart';
import 'package:intl/intl.dart';

class AllMessagesPage extends StatelessWidget {
  final MessagesCRUD _messagesCRUD = MessagesCRUD();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        user: FirebaseAuth.instance.currentUser,
        signOut: () {
          FirebaseAuth.instance.signOut();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        },
      ),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          SizedBox(height: 20), // Add some space at the top
          Center(
            // Center the title
            child: Text(
              "Tous les Messages",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20), // Add some space below the title
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: CategoriesCRUD.getCategories().asStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> categoryData =
                        document.data() as Map<String, dynamic>;

                    return FutureBuilder<QuerySnapshot>(
                      future: document.reference.collection('messages').get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> messagesSnapshot) {
                        if (messagesSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey[200], // Couleur de fond de la bande
                                borderRadius: BorderRadius.circular(
                                    8), // Bord arrondi de la bande
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Catégorie: ${categoryData['nom_cat']}"),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      _showNewMessageDialog(context,
                                          document.id, categoryData['nom_cat']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                                height:
                                    10), // Espace entre la bande et la liste des messages
                            ListView(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              children: messagesSnapshot.data!.docs
                                  .map((DocumentSnapshot messageDocument) {
                                Map<String, dynamic> messageData =
                                    messageDocument.data()
                                        as Map<String, dynamic>;

                                return ListTile(
                                  title: Text(messageData['message']),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${messageData['message']}'),
                                      SizedBox(height: 5),
                                      Text(
                                        'Date de publication: ${DateFormat('yyyy-MM-dd HH:mm').format(messageData['timestamp'].toDate())}', // Date de publication
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            Divider(),
                          ],
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool isNewMessage(Timestamp timestamp) {
    DateTime currentDate = DateTime.now();
    DateTime messageDate = timestamp.toDate();
    int differenceInDays = currentDate.difference(messageDate).inDays;
    return differenceInDays <= 2;
  }

  Future<void> _showNewMessageDialog(
      BuildContext context, String categoryId, String categoryName) async {
    String titre = '';
    String message = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Nouveau Message pour $categoryName"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => titre = value,
                  decoration: InputDecoration(labelText: 'Titre'),
                ),
                TextField(
                  onChanged: (value) => message = value,
                  decoration: InputDecoration(labelText: 'Message'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _messagesCRUD.addMessage(categoryId, titre, message);
                Navigator.of(context).pop();
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
