import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_6/components/app_bar_drawer.dart';

class AllMessagesPage extends StatelessWidget {
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
              stream: FirebaseFirestore.instance
                  .collection('categorie')
                  .snapshots(),
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
                            Text("Catégorie: ${categoryData['nom_cat']}"),
                            SizedBox(height: 10),
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
                                  subtitle: Text(
                                      "Nouveauté: ${isNewMessage(messageData['timestamp']) ? 'Oui' : 'Non'}"),
                                  // Add any other widget to display additional data from the message
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
    // Get the current date
    DateTime currentDate = DateTime.now();

    // Get the date of the message
    DateTime messageDate = timestamp.toDate();

    // Calculate the difference in days
    int differenceInDays = currentDate.difference(messageDate).inDays;

    // Check if the difference is less than or equal to 2 days
    return differenceInDays <= 2;
  }
}
