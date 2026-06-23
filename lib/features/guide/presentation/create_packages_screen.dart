
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreatePackageScreen extends StatefulWidget {
  const CreatePackageScreen({super.key});

  @override
  State<CreatePackageScreen> createState() => _CreatePackageScreenState();
}

class _CreatePackageScreenState extends State<CreatePackageScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
  }

  Future<void> _fetchPackages() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final querySnapshot = await _firestore
          .collection('Guide')
          .doc(user.email)
          .collection('packages')
          .get();

      final fetchedPackages = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "title": data['title'] ?? "Untitled Package",
          "location": data['location'] ?? "Unknown Location",
          "description": data['description'] ??
              "No description available for this package.",
          "duration": data['duration'] ?? "N/A",
          "price": data['price'] ?? "₹0",
          "maxTourists": data['maxTourists'] ?? 0,
          "bookings": data['bookings'] ?? 0,
          "image": data['image'] ??
              "https://upload.wikimedia.org/wikipedia/commons/d/da/Taj-Mahal.jpg",
          "guideName": data['guideName'] ?? "Guide",
        };
      }).toList();

      setState(() {
        packages = fetchedPackages;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching packages: $e");
      setState(() => isLoading = false);
    }
  }

  void _openCreatePackageSheet() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController durationController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController maxTouristsController = TextEditingController();
    final TextEditingController bookingsController =
        TextEditingController(text: "0");
    final TextEditingController imageController = TextEditingController();
    final TextEditingController guideNameController = TextEditingController();

    showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      context: context,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text("Create New Package",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                _buildInput("Package Name", titleController),
                _buildInput("Guide Name", guideNameController),
                _buildInput("Location", locationController),
                _buildInput("Description", descriptionController, maxLines: 3),
                _buildInput("Duration", durationController),
                _buildInput("Price", priceController),
                _buildInput("Max Tourists", maxTouristsController),
                _buildInput("Bookings", bookingsController),
                _buildInput("Image URL", imageController),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await _createPackage(
                        titleController.text,
                        guideNameController.text,
                        locationController.text,
                        descriptionController.text,
                        durationController.text,
                        priceController.text,
                        int.tryParse(maxTouristsController.text) ?? 0,
                        int.tryParse(bookingsController.text) ?? 0,
                        imageController.text,
                      );
                      if (mounted) Navigator.pop(context);
                    },
                    child: const Text("Create Package",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createPackage(
    String title,
    String guideName,
    String location,
    String description,
    String duration,
    String price,
    int maxTourists,
    int bookings,
    String image,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null || title.isEmpty) return;

      await _firestore
          .collection('Guide')
          .doc(user.email)
          .collection('packages')
          .doc(title)
          .set({
        "title": title,
        "guideName": guideName,
        "location": location,
        "description": description,
        "duration": duration,
        "price": price,
        "maxTourists": maxTourists,
        "bookings": bookings,
        "image": image,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Package created successfully!")),
      );

      _fetchPackages(); // Refresh list
    } catch (e) {
      debugPrint("Error creating package: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create package.")),
      );
    }
  }

  Widget _buildInput(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Packages'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: _openCreatePackageSheet,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text("Create"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : packages.isEmpty
              ? const Center(child: Text("No packages available"))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final pkg = packages[index];
                      return _buildPackageCard(context, pkg);
                    },
                  ),
                ),
    );
  }

  Widget _buildPackageCard(BuildContext context, Map<String, dynamic> pkg) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  pkg['image'],
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 160,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image, size: 50)),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "active",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    pkg['title'],
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(pkg['location'],
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  pkg['description'],
                  style: const TextStyle(fontSize: 13.5, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _infoItem(Iconsax.clock, pkg['duration']),
                    _infoItem(Icons.currency_rupee, pkg['price']),
                    _infoItem(Iconsax.user, "${pkg['maxTourists']}"),
                    _infoItem(Iconsax.calendar, "${pkg['bookings']}"),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionButton(Iconsax.eye, "View", Colors.purple.shade50,
                        Colors.purple),
                    _actionButton(Iconsax.edit, "Edit", Colors.blue.shade50,
                        Colors.blueAccent),
                    _actionButton(Iconsax.trash, "", Colors.red.shade50,
                        Colors.redAccent),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.purple),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Colors.black87)),
      ],
    );
  }

  Widget _actionButton(
      IconData icon, String label, Color bgColor, Color iconColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(icon, size: 16, color: iconColor),
          label: Text(label,
              style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
