
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String targetUserId;
  final String productId;

  ChatScreen({required this.chatId, required this.targetUserId, required this.productId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController = TextEditingController();
  String targetUserEmail = '';
  String targetUsername = '';
  String userId = 'A7FSt1TsLTOGNK1n5u8B9DqNznA82YdW'; //UserID

  // Cache messages locally
  List<QueryDocumentSnapshot> cachedMessages = [];

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _fetchTargetUserEmail();
  }

  // Fetch current user's ID from Firebase Authentication
  Future<void> _fetchUserId() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
      });
    }
  }

  // Fetch target user's email and username from Firestore
  Future<void> _fetchTargetUserEmail() async {
    try {
      final targetUserDoc = await FirebaseFirestore.instance.collection('users')
          .doc(widget.targetUserId)
          .get();

      if (targetUserDoc.exists) {
        setState(() {
          targetUserEmail = targetUserDoc.data()?['email'] ?? 'No email';
          targetUsername = targetUserDoc.data()?['name'] ?? 'No name';
        });
      } else {
        print("Target user document does not exist.");
      }
    } catch (e) {
      print("Error fetching target user email: $e");
    }
  }

  // Send a message to Firestore
  void sendMessage() async {
    if (messageController.text.trim().isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.chatId)
            .collection('messages')
            .add({
          'text': messageController.text,
          'senderId': userId,
          'product_id': widget.productId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("Message sent: ${messageController.text}"); // Debugging
        messageController.clear();
      } catch (e) {
        print('Error sending message: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(targetUsername.isNotEmpty ? targetUsername : targetUserEmail),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .where('product_id', isEqualTo: widget.productId)
              // .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && cachedMessages.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  cachedMessages = snapshot.data!.docs;
                  print("Messages fetched: ${snapshot.data!.docs.length}"); // Debugging
                } else {
                  print("No messages found");
                }

                if (cachedMessages.isEmpty) {
                  return Center(child: Text('No messages yet! Start chatting.'));
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: cachedMessages.length,
                  itemBuilder: (context, index) {
                    final message = cachedMessages[index];
                    final isCurrentUser = message['senderId'] == userId;
                    final timestamp = message['createdAt'] != null
                        ? (message['createdAt'] as Timestamp).toDate()
                        : DateTime.now();
                    final formattedTime = '${timestamp.hour}:${timestamp.minute}';

                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: isCurrentUser ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                message['text'] ?? '',
                                style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              formattedTime,
                              style: TextStyle(fontSize: 10, color: Colors.grey),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(labelText: 'Send a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


