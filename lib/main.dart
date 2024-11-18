import 'package:chat_module/chat_screen.dart';
import 'package:chat_module/register_screen.dart';
import 'package:chat_module/users_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Clear Firestore persistence (after initialization)
  // await FirebaseFirestore.instance.clearPersistence();

  try {
    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    print("Error during anonymous sign-in: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/register': (context) => UsersScreen(currentUserId: 'A7FSt1TsLTOGNK1n5u8B9DqNznA82YdW'),
      },
    );
  }
}
