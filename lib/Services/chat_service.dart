import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Future<User?> signInAnonymously() async {
  //   try {
  //     UserCredential userCredential = await _auth.signInAnonymously();
  //     return userCredential.user;
  //   } catch (e) {
  //     print("Error signing in anonymously: $e");
  //     return null;
  //   }
  // }

  // Sign in anonymously and associate with web user ID
  Future<User?> signInAnonymouslyWithWebUserID(String webUserID) async {
  try {
  // Step 1: Sign in anonymously to create a Firebase anonymous user
  UserCredential userCredential = await _auth.signInAnonymously();
  User? user = userCredential.user;

  if (user != null) {
  // Step 2: After signing in anonymously, link the user with the web user ID
  await updateUserIDInFirestore(user, webUserID);  // Associate Firebase user with web user ID
  return user;
  }
  return null;
  } catch (e) {
  print("Error signing in anonymously: $e");
  return null;
  }
  }

  // Update the Firestore document to associate the anonymous user with the web user ID
  Future<void> updateUserIDInFirestore(User user, String webUserID) async {
  try {
  await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  'webUserID': webUserID,  // Store the web user ID
  'lastLogin': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true)); // Merge to avoid overwriting existing data
  print("User ID updated with Web User ID: $webUserID");
  } catch (e) {
  print("Error updating user ID in Firestore: $e");
  }
  }
}
