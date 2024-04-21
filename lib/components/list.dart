import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_6/components/app_bar_drawer.dart';

class CollectionViewer extends StatelessWidget {
  final String collectionName;

  const CollectionViewer({Key? key, required this.collectionName})
      : super(key: key);

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
              "Les " + collectionName, // Use the collection name as the title
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
                  .collection(collectionName)
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
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['displayName']),
                      subtitle: Text(data['email']),
                      // Add any other widget to display additional data from the document
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
}
