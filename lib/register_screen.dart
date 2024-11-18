import 'package:chat_module/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _productController = TextEditingController();
  final _phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Future<void> registerUser() async {
  //   try {
  //     UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //
  //     await _firestore.collection('users').doc(userCredential.user!.uid).set({
  //       'email': _emailController.text.trim(),
  //       'name': _nameController.text.trim(),
  //       'phone': _phoneController.text.trim(),
  //       'profilePicture': '',
  //       'productId': _productController.text.trim(),
  //       'createdAt': FieldValue.serverTimestamp(),
  //     });
  //
  //     await _auth.signInWithEmailAndPassword(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => HomeScreen()),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'email-already-in-use') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Email is already in use. Please log in.')),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${e.message}')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error signing up: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Unexpected error: $e')),
  //     );
  //   }
  // }


  Future<void> registerUser() async {
    try {
      // Creating user and getting response
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Extracting user details from UserCredential
      String userId = userCredential.user!.uid;
      String email = userCredential.user!.email ?? '';
      String? displayName = userCredential.user!.displayName;
      String? photoURL = userCredential.user!.photoURL;

      print("User IDdddddd: $userId");
      print("User Emaillllllllllll: $email");

      // Storing additional user data in Firestore
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': email,
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'profilePicture': photoURL ?? '',
        'displayName': displayName ?? _nameController.text.trim(),
        'productId': _productController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Signing in the user automatically
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      // Navigating to the HomeScreen
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => HomeScreen()),
      // );

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email is already in use. Please log in.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      print('Error signing up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Full Name"),
            ),
            TextField(
              controller: _productController,
              decoration: InputDecoration(labelText: "Product Id"),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Phone Number"),
            ),
            ElevatedButton(
              onPressed: registerUser, // Call registerUser when button is pressed
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
