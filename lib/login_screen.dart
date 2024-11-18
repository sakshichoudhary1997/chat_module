

import 'package:chat_module/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Services/chat_service.dart';
import 'chat_screen.dart';  // Import the ChatScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late ChatService _chatService;
  // String user_id = 'XpQa3dFCfWCU7BgxWVOm9XHkAjlwbieK';
  // String target_id = 'ryua8S6uHEVEudqjtJYCuxQWvtoSHjzy';
  // String target_id = 'A7FSt1TsLTOGNK1n5u8B9DqNznA82YdW';
  String product_id = '0DqmBh8cJqtB2g9ZbxdnhPV5tFicFoCm12';
  // String user_id = 'mLdBU7uxv6kzZDCzYAPsVGg1jpO7FsMW';
  String user_id = 'A7FSt1TsLTOGNK1n5u8B9DqNznA82YdW';
  String target_id = 'ryua8S6uHEVEudqjtJYCuxQWvtoSHjzy';

  @override
  void initState() {
    super.initState();
  }

  Future<String> createChat(String user1Id, String user2Id, String productCode) async {
    // Step 1: Create a sorted user pair key
    final userPair = '${user1Id.hashCode < user2Id.hashCode ? user1Id : user2Id}-${user1Id.hashCode < user2Id.hashCode ? user2Id : user1Id}';

    // Step 2: Query chats using the combined user pair key and product code
    final chatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('user_pair', isEqualTo: userPair)  // Query using the sorted user pair
        .where('product_code', isEqualTo: productCode)  // Check if the product code matches
        .get();

    if (chatQuery.docs.isEmpty) {
      // Step 3: If no chat exists, create a new chat for both users and the product code
      final chatId = '${userPair}-$productCode'; // Generate a unique chat ID using the user pair and product code

      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'users': [user1Id, user2Id],
        'user_pair': userPair,  // Store the sorted user pair for future queries
        'createdAt': FieldValue.serverTimestamp(),
        'product_code': productCode,
      });

      print("New chat created with ID: $chatId for product: $productCode");
      return chatId;
    } else {
      // Step 4: If a chat exists, return the existing chat ID
      print("Chat already exists with ID: ${chatQuery.docs.first.id} for product: $productCode");
      return chatQuery.docs.first.id;
    }
  }


// Start the chat when the user clicks the button
  void startChat(String targetUserId, String productCode) async {
    final chatId = await createChat(user_id, targetUserId, productCode);
    print('Chat ID: $chatId');

    // Navigate to the ChatScreen with the chat ID, target user, and product ID
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
            chatId: chatId,
            targetUserId: targetUserId,
            productId: product_id
        ),
      ),
    );
  }


  // Login User function
  Future<void> loginUser() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomeScreen()),
      // );
    } on FirebaseAuthException catch (e) {
      // Handle different error cases, like incorrect email/password
      print('Error logging in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging in: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Email input field
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            // Password input field
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            // Login button
            ElevatedButton(
              // onPressed: () => startChat(target_id),
              // Trigger loginUser when clicked
              onPressed: () => startChat(target_id, product_id),
              child: Text("Chat"),
            ),
            SizedBox(height: 16.0),
            // Link to register screen for users who don't have an account
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');  // Navigate to RegisterScreen
              },
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}

