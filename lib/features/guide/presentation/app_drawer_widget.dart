import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:travelapplication/main.dart';
import 'translator.dart';
import 'edit_profile_screen.dart';
import 'ai_script_generator_screen.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ===== Drawer Header =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5E5CE6), Color(0xFF3D5CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundImage: AssetImage('assets/avatar.png'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Rajesh Kumar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Professional Guide',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star, color: Colors.amberAccent, size: 16),
                    SizedBox(width: 4),
                    Text('4.9 Rating',
                        style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCard('124', 'Tours'),
                    _buildStatCard('98', 'Reviews'),
                    _buildStatCard('#12', 'Rank'),
                  ],
                ),
              ],
            ),
          ),

          // ===== Drawer Items =====
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _drawerItem(Iconsax.edit, "Edit Profile", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                }),
                _drawerItem(Iconsax.magicpen, "AI Script Generator", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AIScriptGeneratorScreen()));
                }),
                _drawerItem(Iconsax.translate, "Language Translator", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TranslatorScreen()));
                }),
                SwitchListTile(
                  title: const Text(
                    "Dark Mode",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  secondary: const Icon(Iconsax.moon),
                  value: isDarkMode,
                  onChanged: (value) {
                    setState(() => isDarkMode = value);
                  },
                  activeColor: const Color(0xFF3D5CFF),
                ),
                const Divider(height: 20),
                _drawerItem(Iconsax.logout, "Sign Out", () async {
                    {
              await AuthService().logOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (Route<dynamic> route) => false,
              );
            }
                }, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Drawer Item Widget
  Widget _drawerItem(IconData icon, String title, VoidCallback onTap,
      {Color color = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  // Static stat card widget for header
  static Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
