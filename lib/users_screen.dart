import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class UsersScreen extends StatefulWidget {
  final String currentUserId;

  UsersScreen({required this.currentUserId});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> targetUserList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTargetUsers();
  }

  /// Fetch all target users (users the current user has chatted with)
  Future<void> fetchTargetUsers() async {
    try {
      var chatQuery = await FirebaseFirestore.instance.collection('chats').get();
      List<Map<String, dynamic>> users = [];

      for (var chatDoc in chatQuery.docs) {
        List<String> idParts = chatDoc.id.split('-');
        if (idParts.length < 3) continue;

        String user1 = idParts[0];
        String user2 = idParts[1];
        String targetUserId = widget.currentUserId == user1 ? user2 : user1;

        if (targetUserId != widget.currentUserId &&
            !users.any((user) => user['userId'] == targetUserId)) {
          // Fetch the user details
          var userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(targetUserId)
              .get();

          users.add({
            'userId': targetUserId,
            'userName': userSnapshot.data()?['name'] ?? 'Unnamed User',
            'profilePicture': userSnapshot.data()?['profilePicture'] ?? '',
          });
        }
      }

      setState(() {
        targetUserList = users;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching target users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : targetUserList.isEmpty
          ? Center(child: Text('No chats available'))
          : ListView.builder(
        itemCount: targetUserList.length,
        itemBuilder: (context, index) {
          var targetUser = targetUserList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: targetUser['profilePicture'].isNotEmpty
                  ? NetworkImage(targetUser['profilePicture'])
                  : AssetImage('assets/images/user.png') as ImageProvider,
            ),
            title: Text(targetUser['userName']),
            subtitle: Text('Tap to view products'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    currentUserId: widget.currentUserId,
                    selectedTargetUserId: targetUser['userId'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
