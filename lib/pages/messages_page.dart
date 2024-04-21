import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

class MessagesPage extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  MessagesPage({
    required this.categoryId,
    required this.categoryName,
  });

  final CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('categorie');

  void _addMessage(BuildContext context, String message, String content,
      int priority) async {
    try {
      await messagesCollection.doc(categoryId).collection('messages').add({
        'message': message,
        'content': content,
        'priority': priority,
        'timestamp': Timestamp.now(),
      });
      print("Message added successfully");
      Navigator.of(context).pop(); // Close the dialog after adding the message
    } catch (e) {
      print("Error adding message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: messagesCollection
            .doc(categoryId)
            .collection('messages')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['message']),
                subtitle: Text(data['content']),
                trailing: Text(
                    'Priority: ${data['priority']}\nDate: ${DateFormat('yyyy-MM-dd HH:mm').format(data['timestamp'].toDate())}'),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String message = '';
              String content = '';
              int priority = 1;

              return AlertDialog(
                title: Text('Nouveau Message'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: InputDecoration(labelText: 'Titre'),
                    ),
                    TextField(
                      onChanged: (value) {
                        content = value;
                      },
                      decoration: InputDecoration(labelText: 'Message'),
                    ),
                    TextField(
                      onChanged: (value) {
                        priority = int.parse(value);
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Priorité'),
                    ),
                  ],
                ),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      _addMessage(context, message, content, priority);
                    },
                    child: Text('Ajouter'),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Nouveau Message',
        child: const Icon(Icons.add),
      ),
    );
  }
}
