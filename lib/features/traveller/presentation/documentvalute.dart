// ignore_for_file: use_build_context_synchronously

/*import 'package:flutter/material.dart';

class DocumentVaultScreen extends StatelessWidget {
  const DocumentVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'TravelMate',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.black87),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Title
            const Center(
              child: Column(
                children: [
                  Icon(Icons.folder_open, size: 60, color: Colors.teal),
                  SizedBox(height: 8),
                  Text(
                    'Document Vault',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Securely store and access your travel documents',
                    style: TextStyle(color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Encrypted Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'End-to-End Encrypted\nYour documents are secured with military-grade encryption.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Upload Box
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 16, 40, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 40),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal.shade100),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined,
                        size: 60, color: Colors.teal),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload Documents',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Drag and drop files or click to browse',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add Documents'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Categories Section
            const Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.2,
              children: const [
                _CategoryCard(title: 'All Documents', count: '4 documents'),
                _CategoryCard(title: 'Passports & IDs', count: '1 document'),
                _CategoryCard(title: 'Tickets', count: '1 document'),
                _CategoryCard(title: 'Bookings', count: '1 document'),
                _CategoryCard(title: 'Insurance', count: '1 document'),
              ],
            ),

            const SizedBox(height: 24),

            // Recent Documents Section
            const Text(
              'Recent Documents',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Search box
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Document list
            const _DocumentTile(
              name: 'Passport.pdf',
              size: '2.4 MB',
              date: '2024-01-15',
            ),
            const _DocumentTile(
              name: 'Flight_Ticket_NYC.pdf',
              size: '1.2 MB',
              date: '2024-01-10',
            ),
            const _DocumentTile(
              name: 'Hotel_Booking.pdf',
              size: '890 KB',
              date: '2024-01-08',
            ),
            const _DocumentTile(
              name: 'Travel_Insurance.pdf',
              size: '1.5 MB',
              date: '2024-01-05',
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
    
    );
  }
}

// Category card widget
/*
class _CategoryCard extends StatelessWidget {
  final String title;
  final String count;
  const _CategoryCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(count, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }
}
*/

class _CategoryCard extends StatelessWidget {
  final String title;
  final String count;
  const _CategoryCard({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min, // âœ… Prevents overflow
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              count,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
// Document tile widget
class _DocumentTile extends StatelessWidget {
  final String name;
  final String size;
  final String date;
  const _DocumentTile({
    required this.name,
    required this.size,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.teal,
          child: Icon(Icons.insert_drive_file, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$size  â€¢  $date'),
        trailing: Wrap(
          spacing: 10,
          children: const [
            Icon(Icons.download_rounded, color: Colors.grey),
            Icon(Icons.delete_outline, color: Colors.redAccent),
          ],
        ),
      ),
    );
  }
}*/





import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentVaultScreen extends StatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  final List<File> _uploadedDocs = [];

  @override
  void initState() {
    super.initState();
    _loadSavedDocuments();
  }

  /// ðŸ”¹ Load saved documents from SharedPreferences
  Future<void> _loadSavedDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = prefs.getStringList('saved_docs') ?? [];

    setState(() {
      _uploadedDocs.clear();
      _uploadedDocs.addAll(paths.map((p) => File(p)));
    });
  }

  /// ðŸ”¹ Pick an image and save locally
  Future<void> _pickDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final String newPath = '${appDir.path}/$fileName.png';
    final File savedFile = await File(pickedFile.path).copy(newPath);

    setState(() {
      _uploadedDocs.add(savedFile);
    });

    await _saveDocumentsToPrefs();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Document uploaded successfully!")),
    );
  }

  /// ðŸ”¹ Save file paths to SharedPreferences
  Future<void> _saveDocumentsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final paths = _uploadedDocs.map((f) => f.path).toList();
    await prefs.setStringList('saved_docs', paths);
  }

  /// ðŸ”¹ Delete a document
  void _deleteDocument(int index) async {
    final fileToDelete = _uploadedDocs[index];
    if (await fileToDelete.exists()) {
      await fileToDelete.delete();
    }

    setState(() {
      _uploadedDocs.removeAt(index);
    });

    await _saveDocumentsToPrefs();
  }

  /// ðŸ”¹ View image in dialog
  void _viewDocument(File docFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.file(docFile, fit: BoxFit.contain),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Document Vault"),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Upload Document",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text("Add and secure your documents"),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickDocument,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              "Recent Documents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // List of uploaded documents
            if (_uploadedDocs.isEmpty)
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(30),
                child: const Text(
                  "No documents uploaded yet.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              Column(
                children: List.generate(_uploadedDocs.length, (index) {
                  final file = _uploadedDocs[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: () => _viewDocument(file),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        "Document ${index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        file.path.split('/').last,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDocument(index),
                      ),
                    ),
                  );
                }),
              ),
          ],
        ),
      ),
    );
  }
}
