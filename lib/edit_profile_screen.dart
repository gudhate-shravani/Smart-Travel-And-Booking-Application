/*import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController =
      TextEditingController(text: "Rajesh Kumar");
  final TextEditingController bioController = TextEditingController(
      text:
          "Professional heritage guide with 10+ years of experience. Passionate about sharing India's rich cultural history.");
  final TextEditingController locationController =
      TextEditingController(text: "New Delhi, India");
  final TextEditingController emailController =
      TextEditingController(text: "rajesh.kumar@example.com");
  final TextEditingController phoneController =
      TextEditingController(text: "+91 98765 43210");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Profile",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Iconsax.edit, color: Colors.black87),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== Top Header =====
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 130,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A5AE0), Color(0xFF8E7CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 70,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: AssetImage("assets/avatar_female.png"),
                      ),
                      Container(
                        height: 28,
                        width: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6A5AE0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Iconsax.camera, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // ===== Name =====
            Text(
              nameController.text,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // ===== Input Fields =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextBox(bioController, maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(Iconsax.location, locationController),
                  const SizedBox(height: 12),
                  _buildTextField(Iconsax.sms, emailController),
                  const SizedBox(height: 12),
                  _buildTextField(Iconsax.call, phoneController),
                  const SizedBox(height: 20),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A5AE0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Changes Saved")),
                        );
                      },
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ===== Tabs (Achievements / Reviews) =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _tabButton("Achievements", true),
                    _tabButton("Reviews", false),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== Achievement Cards =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _achievementCard(Iconsax.cup, "100 Tours", "Unlocked", Colors.deepPurple),
                  _achievementCard(Iconsax.star1, "5-Star Guide", "Unlocked", Colors.amber.shade700),
                  _achievementCard(Iconsax.building, "Heritage Expert", "Unlocked", Colors.indigo),
                  _achievementCard(Iconsax.medal, "Top Rated", "Locked", Colors.grey.shade400, isLocked: true),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===== Custom Widgets =====

  Widget _buildTextBox(TextEditingController controller, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _tabButton(String text, bool isActive) {
    return Expanded(
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _achievementCard(IconData icon, String title, String status,
      Color color, {bool isLocked = false}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade200 : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLocked ? Colors.grey.shade300 : color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: isLocked ? Colors.grey : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
*/


// main.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const EditProfileScreen(),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController =
      TextEditingController(text: "Rajesh Kumar");
  final TextEditingController bioController = TextEditingController(
      text:
          "Professional heritage guide with 10+ years of experience. Passionate about sharing India's rich cultural history.");
  final TextEditingController locationController =
      TextEditingController(text: "New Delhi, India");
  final TextEditingController emailController =
      TextEditingController(text: "rajesh.kumar@example.com");
  final TextEditingController phoneController =
      TextEditingController(text: "+91 98765 43210");

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Fetch the logged-in guide info from Firestore
    _loadGuideInfo();
  }

  Future<void> _loadGuideInfo() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        // No logged-in user -- just keep defaults or blanks
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No logged-in user found.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final docId = user.email!;
      final doc = await FirebaseFirestore.instance
          .collection('Guide')
          .doc(docId)
          .get();

      if (!doc.exists) {
        // Document doesn't exist — keep controllers as they are (or clear them)
        // Per your request: if not available keep blank. But you had default text:
        // We'll keep current controller values if you already seeded them,
        // but if you prefer blank, uncomment the next block.

        // nameController.text = '';
        // bioController.text = '';
        // locationController.text = '';
        // emailController.text = docId; // keep email prefilled
        // phoneController.text = '';

        // However to follow: fill available fields and leave missing blank:
        setState(() {
          emailController.text = docId;
        });

        setState(() => _isLoading = false);
        return;
      }

      final data = doc.data()!;

      // Fill controllers with available fields; if missing keep blank
      setState(() {
        nameController.text = (data['fullName'] as String?) ?? '';
        bioController.text = (data['bio'] as String?) ?? '';
        locationController.text = (data['location'] as String?) ?? '';
        emailController.text = (data['email'] as String?) ?? docId;
        phoneController.text = (data['phone'] as String?) ?? '';
      });
    } catch (e) {
      // Something went wrong while fetching
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveGuideInfo() async {
    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No logged-in user found.')),
        );
        setState(() => _isSaving = false);
        return;
      }

      final docId = user.email!;
      // Prepare map of fields to save. We will include all fields (even if blank)
      // because user can clear a field and we want Firestore to reflect that.
      final Map<String, Object?> updatedData = {
        'fullName': nameController.text.trim(),
        'bio': bioController.text.trim(),
        'location': locationController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Merge: true will add new fields and update existing ones
      await FirebaseFirestore.instance
          .collection('Guide')
          .doc(docId)
          .set(updatedData, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Changes Saved")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    locationController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Profile",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Iconsax.edit, color: Colors.black87),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ===== Top Header =====
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 130,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF6A5AE0), Color(0xFF8E7CFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                       // top: 70,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  AssetImage("assets/avatar_female.png"),
                            ),
                            Container(
                              height: 28,
                              width: 28,
                              decoration: const BoxDecoration(
                                color: Color(0xFF6A5AE0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.camera,
                                  color: Colors.white, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // ===== Name =====
                  Text(
                    nameController.text,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // ===== Input Fields =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildTextBox(bioController, maxLines: 3),
                        const SizedBox(height: 12),
                        _buildTextField(Iconsax.location, locationController),
                        const SizedBox(height: 12),
                        _buildTextField(Iconsax.sms, emailController),
                        const SizedBox(height: 12),
                        _buildTextField(Iconsax.call, phoneController),
                        const SizedBox(height: 20),
                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A5AE0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isSaving ? null : _saveGuideInfo,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    "Save Changes",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ===== Tabs (Achievements / Reviews) =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _tabButton("Achievements", true),
                          _tabButton("Reviews", false),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== Achievement Cards =====
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _achievementCard(Iconsax.cup, "100 Tours", "Unlocked",
                            Colors.deepPurple),
                        _achievementCard(Iconsax.star1, "5-Star Guide",
                            "Unlocked", Colors.amber.shade700),
                        _achievementCard(Iconsax.building, "Heritage Expert",
                            "Unlocked", Colors.indigo),
                        _achievementCard(Iconsax.medal, "Top Rated", "Locked",
                            Colors.grey.shade400,
                            isLocked: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ===== Custom Widgets =====

  Widget _buildTextBox(TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) {
        // update the name shown in header when controller changes
        setState(() {});
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildTextField(IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade700),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _tabButton(String text, bool isActive) {
    return Expanded(
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _achievementCard(IconData icon, String title, String status,
      Color color,
      {bool isLocked = false}) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isLocked ? Colors.grey.shade200 : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isLocked ? Colors.grey.shade300 : color),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              color: isLocked ? Colors.grey : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
