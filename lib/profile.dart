/*import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DriverProfileScreen(),
  ));
}

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(),
            const SizedBox(height: 16),
            _buildContactCard(),
            const SizedBox(height: 16),
            _buildPerformanceCard(),
            const SizedBox(height: 16),
            _buildVehicleCard(),
            const SizedBox(height: 16),
            _buildDocumentsCard(),
            const SizedBox(height: 16),
            _buildRatingBreakdown(),
          ],
        ),
      ),
    );
  }

  // ---------------- Profile Card -----------------
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Stack(
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.verified, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Rajesh Kumar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        "4.8 (256 reviews)",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Text("New Delhi", maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("Experience: 5 years", maxLines: 1, overflow: TextOverflow.ellipsis),
                Text("Member since March'19", maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 100, // Reduced from 110 to 100
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 16),
              label: const Text(
                "Edit",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey),
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Contact Information -----------------
  Widget _buildContactCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Contact Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.phone, color: Colors.blue),
            title: Text("+91 98765 43210"),
            subtitle: Text("Mobile Number"),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.email, color: Colors.green),
            title: Text("rajesh.kumar@email.com"),
            subtitle: Text("Email Address"),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.calendar_month, color: Colors.purple),
            title: Text("5 years"),
            subtitle: Text("Driving Experience"),
          ),
        ],
      ),
    );
  }

  // ---------------- Performance Summary -----------------
  Widget _buildPerformanceCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Performance Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.2, // <-- changed from 3 to 2.2
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: const [
              _InfoTile(icon: Icons.directions_car, title: "Total Rides", value: "1,247"),
              _InfoTile(icon: Icons.currency_rupee, title: "Total Earnings", value: "₹3,45,600"),
              _InfoTile(icon: Icons.star, title: "Average Rating", value: "4.8/5"),
              _InfoTile(icon: Icons.verified, title: "Completion Rate", value: "98%"),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- My Vehicles -----------------
  Widget _buildVehicleCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("My Vehicles", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Add Vehicle"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _vehicleItem("Maruti Swift Dzire", "DL 01 AB 1234", "Sedan", "Active", Colors.green),
          _vehicleItem("Honda City", "DL 02 CD 5678", "Sedan", "Maintenance", Colors.orange),
          _vehicleItem("Toyota Innova", "DL 03 EF 9012", "SUV", "Active", Colors.green),
        ],
      ),
    );
  }

  Widget _vehicleItem(String name, String reg, String type, String status, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: Colors.blue, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(reg),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chip(type, Colors.grey.shade200, Colors.black),
                    const SizedBox(width: 6),
                    _chip(status, color.withOpacity(0.15), color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- My Documents -----------------
  Widget _buildDocumentsCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("My Documents", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _docItem("Driver License", "Expires: Dec 2025", "Verified", Colors.green),
          _docItem("Aadhaar Card", "No expiry", "Verified", Colors.green),
          _docItem("PAN Card", "No expiry", "Verified", Colors.green),
          _docItem("Police Verification", "No expiry", "Pending", Colors.orange),
        ],
      ),
    );
  }

  Widget _docItem(String title, String subtitle, String status, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.description, color: Colors.blue),
      title: Text(title, overflow: TextOverflow.ellipsis, maxLines: 1),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis, maxLines: 1),
      trailing: SizedBox(
        width: 100, // Reduced from 110 to 100
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chip(status, color.withOpacity(0.15), color),
            const SizedBox(width: 4),
            const Icon(Icons.upload_file, color: Colors.grey, size: 18),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                "Update",
                style: TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Rating Breakdown -----------------
  Widget _buildRatingBreakdown() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rating Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _ratingBar(5, 0.70),
          _ratingBar(4, 0.25),
          _ratingBar(3, 0.04),
          _ratingBar(2, 0.01),
          _ratingBar(1, 0.0),
        ],
      ),
    );
  }

  Widget _ratingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$stars ★"),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              color: Colors.blue,
              backgroundColor: Colors.grey.shade300,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text("${(percentage * 100).toInt()}%"),
        ],
      ),
    );
  }

  // ---------------- Reusable UI Elements -----------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3)),
      ],
    );
  }

  static Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // <-- add this line
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'add_vehicle.dart';



class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  String fullName = "";
  String email = "";
  List<Map<String, dynamic>> vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchDriverData();
  }

  Future<void> _fetchDriverData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("⚠️ No logged in user!");
        setState(() => _isLoading = false);
        return;
      }

      final userEmail = user.email!;
      print("🔍 Fetching data for $userEmail");

      // Fetch driver info
      final docRef = _firestore.collection('Rental Driver').doc(userEmail);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final data = docSnap.data()!;
        fullName = data['fullName'] ?? 'Unknown';
        email = data['email'] ?? userEmail;
        print("✅ Driver info: $data");
      } else {
        print("❌ No document found for user: $userEmail");
      }

      // Fetch vehicles under this user
      final vehicleSnap = await docRef.collection('vehicle').get();
      vehicles = vehicleSnap.docs.map((v) {
        final vehicleData = v.data();
        vehicleData['id'] = v.id; // vehicle name is document ID
        return vehicleData;
      }).toList();

      print("🚗 Found ${vehicles.length} vehicles");

    } catch (e) {
      print("❌ Error fetching data: $e");
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildContactCard(),
                  const SizedBox(height: 16),
                  _buildPerformanceCard(),
                  const SizedBox(height: 16),
                  _buildVehicleCard(),
                  const SizedBox(height: 16),
                  _buildDocumentsCard(),
                  const SizedBox(height: 16),
                  _buildRatingBreakdown(),
                ],
              ),
            ),
    );
  }

  // ---------------- Profile Card -----------------
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Stack(
            children: [
               const SizedBox(width: 20),
              const CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(Icons.verified,
                      size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : "Loading...",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        "4.8 (256 reviews)",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(email.isNotEmpty ? email : "Loading...",
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                
                const SizedBox(height: 10),
                       SizedBox(
            width: 100,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 16),
              label: const Text(
                "Edit",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.grey),
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
              ],
             
            ),
          ),
         
        ],
      ),
    );
  }

  // ---------------- Contact Information -----------------
  Widget _buildContactCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Contact Information",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.phone, color: Colors.blue),
            title: Text("+91 98765 43210"),
            subtitle: Text("Mobile Number"),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email, color: Colors.green),
            title: Text(email),
            subtitle: const Text("Email Address"),
          ),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.calendar_month, color: Colors.purple),
            title: Text("5 years"),
            subtitle: Text("Driving Experience"),
          ),
        ],
      ),
    );
  }

  // ---------------- Performance Summary -----------------
  Widget _buildPerformanceCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Performance Summary",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            childAspectRatio: 2.2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: const [
              _InfoTile(icon: Icons.directions_car, title: "Total Rides", value: "1,247"),
              _InfoTile(icon: Icons.currency_rupee, title: "Total Earnings", value: "₹3,45,600"),
              _InfoTile(icon: Icons.star, title: "Average Rating", value: "4.8/5"),
              _InfoTile(icon: Icons.verified, title: "Completion Rate", value: "98%"),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- My Vehicles -----------------
  Widget _buildVehicleCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("My Vehicles",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () {showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: const AddVehicleForm(),
      ),
    ); },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Add Vehicle"),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (vehicles.isEmpty)
            const Text("No vehicles added yet."),
          for (var v in vehicles)
            _vehicleItem(
              v['id'] ?? 'Unknown Vehicle',
              v['vehicleNumber'] ?? 'N/A',
              v['type'] ?? 'N/A',
              v['isActive'] ?? 'InActive',
              (v['isActive'] == 'Active')
                  ? Colors.green
                  : 
                       Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _vehicleItem(
      String name, String reg, String type, String status, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: Colors.blue, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(reg),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _chip(type, Colors.grey.shade200, Colors.black),
                    const SizedBox(width: 6),
                    _chip(status, color.withOpacity(0.15), color),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Documents & Rating -----------------
 Widget _buildDocumentsCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("My Documents", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _docItem("Driver License", "Expires: Dec 2025", "Verified", Colors.green),
          _docItem("Aadhaar Card", "No expiry", "Verified", Colors.green),
          _docItem("PAN Card", "No expiry", "Verified", Colors.green),
          _docItem("Police Verification", "No expiry", "Pending", Colors.orange),
        ],
      ),
    );
  }

  Widget _docItem(String title, String subtitle, String status, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.description, color: Colors.blue),
      title: Text(title, overflow: TextOverflow.ellipsis, maxLines: 1),
      subtitle: Text(subtitle, overflow: TextOverflow.ellipsis, maxLines: 1),
      trailing: SizedBox(
        width: 100, // Reduced from 110 to 100
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _chip(status, color.withOpacity(0.15), color),
            const SizedBox(width: 4),
            const Icon(Icons.upload_file, color: Colors.grey, size: 18),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                "Update",
                style: TextStyle(color: Colors.grey),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }


 Widget _buildRatingBreakdown() {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Rating Breakdown", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _ratingBar(5, 0.70),
          _ratingBar(4, 0.25),
          _ratingBar(3, 0.04),
          _ratingBar(2, 0.01),
          _ratingBar(1, 0.0),
        ],
      ),
    );
  }

  Widget _ratingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$stars ★"),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              color: Colors.blue,
              backgroundColor: Colors.grey.shade300,
              minHeight: 8,
            ),
          ),
          const SizedBox(width: 8),
          Text("${(percentage * 100).toInt()}%"),
        ],
      ),
    );
  }

  // ---------------- Helpers -----------------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3)),
      ],
    );
  }

  static Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
