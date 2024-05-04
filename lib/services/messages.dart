import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesCRUD {
  Future<void> addMessage(
      String categoryId, String titre, String message) async {
    try {
      await FirebaseFirestore.instance
          .collection('categorie')
          .doc(categoryId)
          .collection('messages')
          .add({
        'titre': titre,
        'message': message,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error adding message: $e');
    }
  }
}
