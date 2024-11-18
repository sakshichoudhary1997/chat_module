import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_service.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser!;
  }

  Future<void> sendMessage(String text) async {
    try {
      await FirebaseFirestore.instance.collection('messages').add({
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': _currentUser.uid,
        'userEmail': _currentUser.email,
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  Future<void> uploadFile() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      try {
        // Upload image to Firebase Storage
        await FirebaseStorage.instance
            .ref('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg')
            .putFile(file);

        // Get download URL
        String downloadUrl = await FirebaseStorage.instance
            .ref('chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg')
            .getDownloadURL();

        // Save image URL in Firestore as a message
        await FirebaseFirestore.instance.collection('messages').add({
          'imageUrl': downloadUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': _currentUser.uid,
          'userEmail': _currentUser.email,
        });
        print("File uploaded successfully");
      } catch (e) {
        print("Error uploading file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Chat"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _authService.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> messageSnapshot) {
                if (messageSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final messageDocs = messageSnapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messageDocs.length,
                  itemBuilder: (ctx, index) {
                    final message = messageDocs[index];
                    if (message['text'] != null) {
                      return ListTile(
                        title: Text(message['text']),
                        subtitle: Text(message['userEmail']),
                      );
                    } else if (message['imageUrl'] != null) {
                      return ListTile(
                        title: Image.network(message['imageUrl']),
                        subtitle: Text(message['userEmail']),
                      );
                    }
                    return SizedBox();
                  },
                );
              },
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: uploadFile,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(labelText: 'Enter a message'),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  sendMessage(_controller.text);
                  _controller.clear();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
