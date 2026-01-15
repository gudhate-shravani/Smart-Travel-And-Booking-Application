import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatefulWidget {
  final String email;

  const UserProfileScreen({super.key, required this.email});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String fullName = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    try {
      final doc =
          await _firestore.collection("Traveler").doc(widget.email).get();
      if (doc.exists) {
        setState(() {
          fullName = doc.data()?['fullName'] ?? "No Name Found";
          isLoading = false;
        });
      } else {
        setState(() {
          fullName = "User not found";
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user: $e");
      setState(() {
        fullName = "Error loading profile";
        isLoading = false;
      });
    }
  }

  Future<void> toggleLike(DocumentReference postRef, bool isLiked) async {
    await postRef.update({
      "likes": FieldValue.increment(isLiked ? -1 : 1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text("$fullName's Profile"),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ✅ Profile Card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.purple,
                          child:
                              Icon(Icons.person, size: 55, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          fullName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.email,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Posts Section
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Posts",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple),
                      ),
                    ),
                  ),

                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection("Traveler")
                        .doc(widget.email)
                        .collection("post")
                        .orderBy("timestamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                              color: Colors.purple),
                        ));
                      }

                      final posts = snapshot.data!.docs;
                      if (posts.isEmpty) {
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            "No posts yet.",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ));
                      }

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final data = post.data() as Map<String, dynamic>;
                          bool isLiked = false;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 12, right: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? 'Unknown User',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        data['location'] ?? '',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(15)),
                                  child: Image.network(
                                    data['imageUrl'] ?? '',
                                    height: 250,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        height: 250,
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Icon(Icons.broken_image,
                                              color: Colors.grey, size: 50),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(data['description'] ?? ''),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0),
                                  child: Row(
                                    children: [
                                      StatefulBuilder(
                                        builder: (context, setLocalState) {
                                          return IconButton(
                                            icon: Icon(
                                              Icons.favorite,
                                              color: isLiked
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            onPressed: () async {
                                              setLocalState(() {
                                                isLiked = !isLiked;
                                              });
                                              await toggleLike(
                                                  post.reference, isLiked);
                                            },
                                          );
                                        },
                                      ),
                                      Text("${data['likes'] ?? 0}"),
                                      const SizedBox(width: 20),
                                      const Icon(Icons.comment_outlined,
                                          color: Colors.grey),
                                      const SizedBox(width: 4),
                                      const Text("Comments"),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
