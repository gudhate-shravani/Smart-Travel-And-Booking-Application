
import 'package:travelapplication/features/driver/presentation/nearby_essential.dart';
import 'package:travelapplication/features/driver/presentation/translator.dart';
import 'package:travelapplication/main.dart';
import 'loction.dart';
import 'profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverDrawer extends StatefulWidget {
  const DriverDrawer({super.key});

  @override
  State<DriverDrawer> createState() => _DriverDrawerState();
}

class _DriverDrawerState extends State<DriverDrawer> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

String? driverName;
bool _isLoading = true;
@override
void initState() {
  super.initState();
  _fetchDriverName();
}

  Future<void> _fetchDriverName() async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      print("⚠️ No user logged in");
      setState(() => _isLoading = false);
      return;
    }

    final doc = await _firestore.collection('Rental Driver').doc(user.email).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        driverName = data['fullName'] ?? 'Driver';
      });
      print("✅ Fetched driver name: ${data['fullName']}");
    } else {
      print("❌ No document found for ${user.email}");
      setState(() => driverName = 'Driver');
    }
  } catch (e) {
    print("❌ Error fetching name: $e");
    setState(() => driverName = 'Driver');
  }

  setState(() => _isLoading = false);
}

  // Example state variable (you can add more later)
  String selectedLanguage = "English";
  bool isDarkMode = false;


  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                 
                 /* IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),*/
                ],
              ),
              const SizedBox(height: 20),

              // Driver Profile Card



              GestureDetector(
  onTap: () {
    // Navigate or perform an action here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DriverProfileScreen()),
    );
  },
            child:   Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person)
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text( _isLoading
      ? "Driver"
      : "${driverName ?? 'Driver'}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Active",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const Text("4.8  "),
                              const Text(
                                "1247 rides",
                                style: TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              
              ),),

              const SizedBox(height: 20),

              // Menu Items
              _buildMenuItem(
                icon: Icons.translate,
                title: "Language Translator",
                subtitle: selectedLanguage,
                onTap: () async {
                  // Example future navigation
                   Navigator.push(context, MaterialPageRoute(builder: (_) => TranslatorScreen()));
                  setState(() {
                    selectedLanguage = "Hindi";
                  });
                },
              ),
              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: "Location Helper",
                subtitle: "New Delhi, India",
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => LocationScreen()));
                },
              ),
             
              _buildMenuItem(
                icon: Icons.star_border,
                title: "nearby Essential",
                subtitle: "all Essential services",
                onTap: () {
                   Navigator.push(context, MaterialPageRoute(builder: (_) => NearbyEssentialsScreen()));
                },
              ),
              _buildMenuItem(
                icon: isDarkMode
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: "Theme",
                subtitle: isDarkMode ? "Dark mode" : "Light mode",
                onTap: () {
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                },
              ),

              const Spacer(),

              // Divider and Logout
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.logout, color: Colors.redAccent, size: 26),
                title: const Text(
                  "Log Out",
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  "Sign out of your account",
                  style: TextStyle(fontSize: 12, color: Colors.redAccent),
                ),
                onTap: () async {
                   {
              await AuthService().logOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (Route<dynamic> route) => false,
              );
            }
                 // Navigator.pop(context);
                  // Add logout logic here
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
