import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
              // Implement logout logic here
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
                  hintText: 'Search messages...',
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
                    final message = data['message'] as String? ?? '';
                    final content = data['content'] as String? ?? '';
                    final timestamp = data['timestamp'] as Timestamp;
                    final newMessage = isNewMessage(timestamp);

                    // Filter messages based on search term
                    if (searchTerm.isNotEmpty &&
                        !message.toLowerCase().contains(searchTerm)) {
                      return SizedBox.shrink();
                    }

                    return ListTile(
                      title: Text(message),
                      subtitle: Text(content),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                              'Date: ${DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())}'),
                          if (newMessage) // Display blue bubble for new messages
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
