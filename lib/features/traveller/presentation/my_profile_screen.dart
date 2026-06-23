import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String userName = "Loading...";
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchUserName();
  }

  Future<void> fetchUserName() async {
    final userEmail = _auth.currentUser!.email!;
    final doc = await _firestore.collection("Traveler").doc(userEmail).get();
    if (doc.exists) {
      setState(() {
        userName = doc.data()?['fullName'] ?? "No Name Found";
      });
    } else {
      setState(() {
        userName = "User not found";
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(String userEmail, String location) async {
    try {
      setState(() => _isUploading = true);
      // Firebase Storage upload code commented intentionally
      return null;
    } catch (e) {
      debugPrint("Image upload failed: $e");
      return null;
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _showAddPostSheet(BuildContext context, String email) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    _selectedImage = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Add New Post",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(labelText: "Location"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Description"),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      await _pickImage();
                      setModalState(() {});
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.image, color: Colors.purple),
                          const SizedBox(width: 8),
                          Text(
                            _selectedImage == null
                                ? "Upload Image"
                                : "Image Selected ✅",
                            style: const TextStyle(color: Colors.purple),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Image.file(_selectedImage!,
                          height: 150, fit: BoxFit.cover),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: _isUploading
                        ? null
                        : () async {
                            final name = nameController.text.trim();
                            final location = locationController.text.trim();
                            final description = descriptionController.text.trim();

                            if (name.isEmpty ||
                                location.isEmpty ||
                                description.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Please fill all fields")),
                              );
                              return;
                            }

                            String imageUrl =
                                "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=60";

                            await _firestore
                                .collection("Traveler")
                                .doc(email)
                                .collection("post")
                                .add({
                              "name": name,
                              "location": location,
                              "description": description,
                              "imageUrl": imageUrl,
                              "timestamp": DateTime.now(),
                              "likes": 0,
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Post added successfully")),
                            );
                          },
                    child: _isUploading
                        ? const SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Add Post",
                            style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> toggleLike(DocumentReference postRef, bool isLiked) async {
    await postRef.update({
      "likes": FieldValue.increment(isLiked ? -1 : 1),
    });
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _auth.currentUser!.email!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 143, 221),
        title: const Text("My Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
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
                    backgroundColor: Color.fromARGB(255, 54, 143, 221),
                    child: Icon(Icons.person, size: 55, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userName,
                    style:
                        const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(userEmail, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 87, 117, 225),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => _showAddPostSheet(context, userEmail),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Add Post",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Your Posts",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 54, 143, 221)),
                ),
              ),
            ),

            // ✅ Updated StreamBuilder
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("Traveler")
                  .doc(userEmail)
                  .collection("post")
                  .orderBy("timestamp", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(20),
                    child:
                        CircularProgressIndicator(color: Colors.purple),
                  ));
                }

                final posts = snapshot.data!.docs;
                if (posts.isEmpty) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No posts yet.",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
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
                      margin:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10, left: 12, right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text(data['location'],
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(15)),
                            child: Image.network(
                              data['imageUrl'],
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 250,
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                      child: Icon(Icons.broken_image,
                                          color: Colors.grey, size: 50)),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(data['description']),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                StatefulBuilder(builder: (context, setStateLocal) {
                                  return IconButton(
                                    icon: Icon(
                                      Icons.favorite,
                                      color: isLiked ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () async {
                                      setStateLocal(() {
                                        isLiked = !isLiked;
                                      });
                                      await toggleLike(post.reference, isLiked);
                                    },
                                  );
                                }),
                                const SizedBox(width: 4),
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
