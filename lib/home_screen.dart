import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  final String selectedTargetUserId;

  HomeScreen({required this.currentUserId, required this.selectedTargetUserId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> productIds = [];
  bool isLoading = true;
  bool showingProducts = false;

  @override
  void initState() {
    super.initState();
    fetchProductIds();
  }

  /// Fetch product IDs for chats between the logged-in user and a target user
  Future<void> fetchProductIds() async {
    try {
      print("Fetching product IDs...");
      var chatQuery = await FirebaseFirestore.instance.collection('chats').get();
      List<String> fetchedProductIds = [];

      for (var chatDoc in chatQuery.docs) {
        List<String> idParts = chatDoc.id.split('-');
        if (idParts.length < 3) continue;

        String user1 = idParts[0];
        String user2 = idParts[1];
        String productId = idParts[2]; // Extract productId from chatId

        // Check if this chat involves the logged-in user and the target user
        if ((user1 == widget.currentUserId && user2 == widget.selectedTargetUserId) ||
            (user2 == widget.currentUserId && user1 == widget.selectedTargetUserId)) {
          fetchedProductIds.add(productId);
        }
      }

      setState(() {
        productIds = fetchedProductIds;
        isLoading = false;
        showingProducts = true; // Show product list
      });
    } catch (e) {
      print("Error fetching product IDs: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showingProducts
            ? 'Products with ${widget.selectedTargetUserId}'
            : 'Chats'),
        leading: showingProducts
            ? IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              showingProducts = false; // Go back to user list
            });
          },
        )
            : null,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : showingProducts
          ? buildProductList()
          : buildTargetUserList(), // Build user list when showing products is false
    );
  }

  /// Build target user list view
  Widget buildTargetUserList() {
    return Center(
      child: Text('No product list available. Please select a user to view products.'),
    );
  }

  /// Build product list view
  Widget buildProductList() {
    return productIds.isEmpty
        ? Center(child: Text('No products found'))
        : ListView.builder(
      itemCount: productIds.length,
      itemBuilder: (context, index) {
        String productId = productIds[index];

        // Generate chatId based on the updated logic
        String chatId = generateChatId(widget.currentUserId, widget.selectedTargetUserId, productId);

        return ListTile(
          title: Text('Product ID: $productId'),
          subtitle: Text('Click to view chat'),
          onTap: () {
            // Navigate to ChatScreen with the correct chatId
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  chatId: chatId,
                  targetUserId: widget.selectedTargetUserId,
                  productId: productId,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Function to generate the chatId based on user pair and productId
  String generateChatId(String user1Id, String user2Id, String productId) {
    // Step 1: Sort the user IDs based on their hashCodes for consistent ordering
    final userPair = '${user1Id.hashCode < user2Id.hashCode ? user1Id : user2Id}-${user1Id.hashCode < user2Id.hashCode ? user2Id : user1Id}';

    // Step 2: Combine the user pair and the product ID to generate a unique chatId
    return '$userPair-$productId';
  }
}
