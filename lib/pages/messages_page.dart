import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  MessagesPage({
    required this.categoryId,
    required this.categoryName,
  });

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
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

  bool isNewMessage(Timestamp timestamp) {
    DateTime currentDate = DateTime.now();
    DateTime messageDate = timestamp.toDate();
    int differenceInDays = currentDate.difference(messageDate).inDays;
    return differenceInDays <= 2;
  }

  Future<void> _showNewMessageDialog(BuildContext context) async {
    String message = '';
    String content = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ajouter un nouveau message à ${widget.categoryName}"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (value) => message = value,
                  decoration: InputDecoration(labelText: 'Titre'),
                ),
                TextField(
                  onChanged: (value) => content = value,
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
            ElevatedButton(
              onPressed: () {
                // Ajouter le nouveau message à Firestore
                FirebaseFirestore.instance
                    .collection('categorie')
                    .doc(widget.categoryId)
                    .collection('messages')
                    .add({
                  'message': message,
                  'content': content,
                  'timestamp': Timestamp.now(),
                });

                Navigator.of(context).pop();
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(widget.categoryName),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Implémentez ici la logique de déconnexion
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: 'Rechercher des messages...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('categorie')
                  .doc(widget.categoryId)
                  .collection('messages')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Erreur: ${snapshot.error}');
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
                    final message = data['message'] as String? ?? '';
                    final content = data['content'] as String? ?? '';
                    final timestamp = data['timestamp'] as Timestamp;
                    final newMessage = isNewMessage(timestamp);

                    // Filtrer les messages en fonction du terme de recherche
                    if (searchTerm.isNotEmpty &&
                        !message.toLowerCase().contains(searchTerm)) {
                      return SizedBox.shrink();
                    }

                    return GestureDetector(
                      onTap: () {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final currentMessage = data['message'] as String? ?? '';
                        final currentContent = data['content'] as String? ?? '';
                        _showEditMessageDialog(context, docs[index].reference,
                            currentMessage, currentContent);
                      },
                      child: ListTile(
                        title: Text(message),
                        subtitle: Text(content),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())}',
                              style: TextStyle(
                                  fontSize:
                                      12), // Adjust the font size as needed
                            ),
                            if (newMessage) // Afficher une bulle bleue pour les nouveaux messages
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
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
          _showNewMessageDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

Future<void> _showEditMessageDialog(
    BuildContext context,
    DocumentReference messageRef,
    String currentMessage,
    String currentContent) async {
  String message = currentMessage;
  String content = currentContent;

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Modifier le message"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: TextEditingController(text: message),
                onChanged: (value) => message = value,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: TextEditingController(text: content),
                onChanged: (value) => content = value,
                decoration: InputDecoration(labelText: 'Message'),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await messageRef.delete();
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Modifier le message dans Firestore
              await messageRef.update({
                'message': message,
                'content': content,
              });
              Navigator.of(context).pop();
            },
            child: Text('Enregistrer'),
          ),
        ],
      );
    },
  );
}
