import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sending a message
  Future<void> sendMessage(String message, {String? replyToMessageId}) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('chats').add({
          'senderId': user.uid,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'replyTo': replyToMessageId, // Store the ID of the message being replied to
        });
      }
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Listening to real-time messages
  Stream<QuerySnapshot> getMessages() {
    return _firestore
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Fetch a specific message by ID
  Future<DocumentSnapshot> getMessageById(String messageId) async {
    try {
      return await _firestore.collection('chats').doc(messageId).get();
    } catch (e) {
      print("Error fetching message by ID: $e");
      rethrow;
    }
  }
}
