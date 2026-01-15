import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPostBottomSheet extends StatefulWidget {
  final String currentUserId;
  const AddPostBottomSheet({super.key, required this.currentUserId});

  @override
  State<AddPostBottomSheet> createState() => _AddPostBottomSheetState();
}

class _AddPostBottomSheetState extends State<AddPostBottomSheet> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    // Copy image to permanent directory
    final appDir = await getApplicationDocumentsDirectory();
    final newPath =
        '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = await File(picked.path).copy(newPath);

    setState(() => _selectedImage = savedImage);
  }

  Future<void> _savePost() async {
    final prefs = await SharedPreferences.getInstance();
    final postsString = prefs.getString('posts');
    List<dynamic> posts = postsString != null ? jsonDecode(postsString) : [];

    posts.add({
      'userId': widget.currentUserId,
      'name': _nameController.text,
      'location': _locationController.text,
      'description': _descController.text,
      'imagePath': _selectedImage?.path ?? '',
    });

    await prefs.setString('posts', jsonEncode(posts));

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add New Post',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold)),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            _selectedImage == null
                ? TextButton.icon(
                    icon: const Icon(Icons.image, color: Colors.purple),
                    label: const Text('Upload Image'),
                    onPressed: _pickImage,
                  )
                : Column(
                    children: [
                      Image.file(_selectedImage!,
                          width: double.infinity, height: 150, fit: BoxFit.cover),
                      TextButton(
                          onPressed: _pickImage,
                          child: const Text('Change Image',
                              style: TextStyle(color: Colors.purple)))
                    ],
                  ),
            const SizedBox(height: 10),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              onPressed: _savePost,
              child: const Text('Post'),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
