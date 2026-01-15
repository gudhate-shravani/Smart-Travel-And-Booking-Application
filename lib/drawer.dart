import 'package:flutter/material.dart';
import 'about_us.dart';
import 'main.dart';
import 'dart:ui'; 
import 'enhancer.dart';// Required for ImageFilter.blur
import 'journal.dart';
import 'hotel_bookin.dart';
import 'mustdo.dart';
import 'transport.dart';
import 'packages.dart';
import 'tools.dart';
import 'drawer.dart';
import 'documentvalute.dart';
import 'explore.dart';
import 'virtual_tour.dart';
import 'nearby_essential.dart';
import 'homepae.dart';
import 'translator.dart';
import 'ratins.dart';

// --- IMPORT YOUR SCREEN FILES ---
// NOTE: You will need to create these files and paste the code I provided earlier.
// Adjust the paths if your file structure is different.

// import 'screens/photo_enhancer_screen.dart'; 
// import 'screens/must_do_screen.dart';
// import 'screens/journal_screen.dart'; // Or your TripDiaryScreen file
// import 'screens/travel_tools_screen.dart'; // Or your TravelUtilitiesScreen file
// import 'screens/hotel_booking_screen.dart';
// import 'screens/travel_packages_screen.dart';


// --- DATA MODELS ---

// Represents a single navigation item in the drawer.
class DrawerItem {
  final IconData icon;
  final String title;
  final Color iconColor;
  final WidgetBuilder screenBuilder;

  DrawerItem({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.screenBuilder,
  });
}

// --- MAIN DRAWER WIDGET ---

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _isLightTheme = false;
  
  // Data for the navigation items, now pointing to your actual screen classes.
  final List<DrawerItem> _drawerItems = [
    DrawerItem(icon: Icons.translate, title: 'Language Translator', iconColor: Colors.purple, screenBuilder: (context) => const TranslatorScreen()),
    DrawerItem(icon: Icons.camera_enhance, title: 'Photo Enhancer', iconColor: Colors.orange, screenBuilder: (context) => const PhotoEnhancerScreen()),
    DrawerItem(icon: Icons.location_on, title: 'Must Do & Must Try', iconColor: Colors.green, screenBuilder: (context) => const MustDoScreen()),
   // DrawerItem(icon: Icons.book, title: 'Trip Diary', iconColor: Colors.redAccent, screenBuilder: (context) => const JournalScreen()),
    DrawerItem(icon: Icons.settings_input_component, title: 'Travel Utilities & Tools', iconColor: Colors.blueAccent, screenBuilder: (context) => const TravelToolsScreen()),
   // DrawerItem(icon: Icons.redeem, title: 'Rewards & Challenges', iconColor: Colors.pink, screenBuilder: (context) =>  RewardsScreen()),
    //DrawerItem(icon: Icons.hotel, title: 'Hotel Booking', iconColor: Colors.blue, screenBuilder: (context) => const HotelBookingScreen()),
    DrawerItem(icon: Icons.card_travel, title: 'Packages', iconColor: Colors.teal, screenBuilder: (context) => const  TravelPackagesScreen()),
    DrawerItem(icon: Icons.inventory_2, title: 'Document Vault', iconColor: Colors.grey.shade700, screenBuilder: (context) => const DocumentVaultScreen()),
   DrawerItem(icon: Icons.logout, title: 'Sign out', iconColor: Colors.grey.shade600, screenBuilder: (context) => const RoleSelectionScreen()),
  DrawerItem(
      icon: Icons.info_outline, 
      title: 'About Us', 
      iconColor: Colors.pink, // Choosing a distinct color
      screenBuilder: (context) => const AboutUsScreen() // Navigate to the new screen
    ),];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFF6F8FC),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: _buildProfileHeader(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildThemeToggle(),
                      const SizedBox(height: 8),
                      ..._drawerItems.map((item) => _buildMenuItem(item)).toList(),
                    ],
                  ),
                ),
              ),
            ),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SizedBox(
      height: 180,
      child: GestureDetector(
        onTap: () {
           Navigator.of(context).pop();
           // *** YOUR PROFILE SCREEN NAVIGATION CALL ***
          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
        },
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(30)),
             // only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0), Color(0xFF673AB7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text('SC', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 15, height: 15,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Aditya Gudhate', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text('Premium Explorer', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                          ],
                        ),
                         const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildBadge(Icons.leaderboard, '12', Colors.blue),
                            const SizedBox(width: 8),
                            _buildBadge(Icons.emoji_events, '850', Colors.amber),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Icon(Icons.person_outline, color: Colors.white),
                ],
              ),
            ),
             Positioned(
              top: 40,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white.withOpacity(0.8)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 0.5)
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildThemeToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.nightlight_round, color: Colors.purple),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Light Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Toggle theme', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _isLightTheme,
            onChanged: (value) => setState(() => _isLightTheme = value),
            activeColor: Colors.purple,
          )
        ],
      ),
    );
  }

  Widget _buildMenuItem(DrawerItem item) {
    return ListTile(
      leading: Icon(item.icon, color: item.iconColor),
      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: () async {
        if(item.title == 'Sign out'){
          {
              await AuthService().logOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (Route<dynamic> route) => false,
              );
            }
        }else{
        Navigator.of(context).pop();
        // *** YOUR NAVIGATION CALL FOR '${item.title}' ***
        Navigator.of(context).push(MaterialPageRoute(builder: item.screenBuilder));}
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextButton.icon(
        onPressed: () {
           Navigator.of(context).pop();
           // *** YOUR LOGOUT LOGIC HERE ***
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

