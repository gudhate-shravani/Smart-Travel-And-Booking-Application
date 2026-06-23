

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ✅ ADDED
import 'package:travelapplication/driverdashboard.dart';
import 'guidedashboard.dart';
import 'userdashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _navigateToAuth(BuildContext context, String role, AuthType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthScreen(role: role, authType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: _backgroundGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(height: 30),

                        // Icon and Main Title
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.language, size: 60, color: _primaryBlue),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Let's Explore",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E272E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Discover. Connect. Travel Smarter.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          "Welcome! Continue as",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Role Selection Cards
                        _RoleCard(
                          icon: Icons.person_outline,
                          color: _primaryBlue,
                          title: 'Traveler',
                          subtitle: 'Discover amazing destinations',
                          onTap: () => _navigateToAuth(context, 'Traveler', AuthType.signUp),
                        ),
                        _RoleCard(
                          icon: Icons.explore_outlined,
                          color: Colors.orange,
                          title: 'Guide',
                          subtitle: 'Share your local expertise',
                          onTap: () => _navigateToAuth(context, 'Guide', AuthType.signUp),
                        ),
                        _RoleCard(
                          icon: Icons.drive_eta_outlined,
                          color: Colors.deepPurple,
                          title: 'Rental Driver',
                          subtitle: 'Connect travelers to places',
                          onTap: () => _navigateToAuth(context, 'Rental Driver', AuthType.signUp),
                        ),

                        // Already have an account? Login
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Start Your Journey With Us. ',
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

// --- AUTH ROUTER AND SCREENS ---

enum AuthType { login, signUp }

class AuthScreen extends StatefulWidget {
  final String role;
  final AuthType authType;

  const AuthScreen({super.key, required this.role, required this.authType});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late AuthType _currentAuthType;

  @override
  void initState() {
    super.initState();
    _currentAuthType = widget.authType;
  }

  void _toggleAuthType() {
    setState(() {
      _currentAuthType = _currentAuthType == AuthType.login ? AuthType.signUp : AuthType.login;
    });
  }

  void _onAuthSuccess() async {
  final authService = AuthService();
  final role = await authService.getUserRole();

  Widget nextScreen;
  switch (role) {
    case 'Traveler':
      nextScreen = const UserDashboard();
      break;
    case 'Guide':
      nextScreen = const GuideHubApp();
      break;
    case 'Rental Driver':
      nextScreen = const DriverDashboard();
      break;
    default:
      nextScreen = const RoleSelectionScreen();
  }

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => nextScreen),
    (route) => false,
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      _buildAuthHeader(
                        context,
                        isLogin: _currentAuthType == AuthType.login,
                        role: widget.role,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _currentAuthType == AuthType.signUp
                              ? SignUpForm(
                                  key: const ValueKey('signUpForm'),
                                  role: widget.role,
                                  onToggle: _toggleAuthType,
                                  onSuccess: _onAuthSuccess,
                                )
                              : LoginForm(
                                  key: const ValueKey('loginForm'),
                                  role: widget.role,
                                  onToggle: _toggleAuthType,
                                  onSuccess: _onAuthSuccess,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAuthHeader(BuildContext context, {required bool isLogin, required String role}) {
    final String title = isLogin ? 'Welcome Back' : 'Create Account';
    final String subtitle = isLogin ? '$role Login' : role;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.language, size: 40, color: _primaryBlue),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E272E),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- LOGIN SCREEN (Panel 3) ---

class LoginForm extends StatefulWidget {
  final String role;
  final VoidCallback onToggle;
  final VoidCallback onSuccess; // Added success callback
  const LoginForm({super.key, required this.role, required this.onToggle, required this.onSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Use real service
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        await _authService.logIn(_emailController.text, _passwordController.text, widget.role);
        widget.onSuccess(); // Call success navigation
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().contains('Invalid email or password')
              ? 'Invalid email or password.'
              : e.toString().replaceFirst('Exception: ', ''); // Clean up error message
        });
        print('Login Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Email/Phone Input
            const Text('Email / Phone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email or phone',
                prefixIcon: Icon(Icons.email_outlined, color: _primaryBlue),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email or phone.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password Input
            const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: Icon(Icons.lock_outline, color: _primaryBlue),
                suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.grey),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  // Implement Forgot Password logic
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: _primaryBlue, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            // Login Button
            _GradientButton(
              onPressed: _isLoading ? () {} : _handleLogin,
              text: 'Login',
              isLoading: _isLoading,
            ),
            const SizedBox(height: 40),

            // Don't have an account? Sign Up
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                GestureDetector(
                  onTap: widget.onToggle,
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      color: _primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- SIGN UP SCREEN (Panel 2) ---

class SignUpForm extends StatefulWidget {
  final String role;
  final VoidCallback onToggle;
  final VoidCallback onSuccess; // Added success callback
  const SignUpForm({super.key, required this.role, required this.onToggle, required this.onSuccess});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService(); // Use real service
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        await _authService.signUp(
          _fullNameController.text,
          _emailController.text,
          _passwordController.text,
          widget.role,
        );
        widget.onSuccess(); // Call success navigation
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', ''); // Clean up error message
        });
        print('Sign Up Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Full Name Input
            const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outline, color: _primaryBlue),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Email/Phone Input
            const Text('Email / Phone', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Enter your email or phone',
                prefixIcon: Icon(Icons.email_outlined, color: _primaryBlue),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email or phone.';
                }
                // Simple email/phone validation check
                final isEmail = value.contains('@');
                if (!isEmail && !RegExp(r'^\+?[0-9]{7,}$').hasMatch(value)) {
                  return 'Please enter a valid email or phone number.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password Input
            const Text('Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Create a password',
                prefixIcon: Icon(Icons.lock_outline, color: _primaryBlue),
                suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.grey),
              ),
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Confirm Password Input
            const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Confirm your password',
                prefixIcon: Icon(Icons.lock_outline, color: _primaryBlue),
                suffixIcon: Icon(Icons.visibility_off_outlined, color: Colors.grey),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),

            // Create Account Button
            _GradientButton(
              onPressed: _isLoading ? () {} : _handleSignUp,
              text: 'Create Account',
              isLoading: _isLoading,
            ),
            const SizedBox(height: 40),

            // Already have an account? Login
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account? ',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                GestureDetector(
                  onTap: widget.onToggle,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      color: _primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE BUTTON WIDGET ---

class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;

  const _GradientButton({
    required this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: _buttonGradient,
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed, // Disable tap when loading
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}





void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('posts');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

// --- FIREBASE AUTH SERVICE ---

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // ✅ ADDED
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userRoleKey = 'userRole';

  // --- SIGN UP ---
  Future<void> signUp(String fullName, String email, String password, String role) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName(fullName);

      // ✅ Store login state + role locally
      await _setLoginState(true, role);

      // ✅ ADD USER DATA TO FIRESTORE
      await _saveUserToFirestore(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );

      print('SUCCESS: ${userCredential.user?.displayName} signed up as $role');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('An account already exists for that email.');
      }
      throw Exception('Sign Up Failed: ${e.message}');
    }
  }

  // --- LOG IN ---
  Future<void> logIn(String email, String password, String role) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _setLoginState(true, role);
      print('SUCCESS: User logged in as $role');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw Exception('Invalid email or password.');
      }
      throw Exception('Log In Failed: ${e.message}');
    }
  }

  // --- LOG OUT ---
  Future<void> logOut() async {
    await _auth.signOut();
    await _setLoginState(false, '');
  }

  // --- LOGIN STATE ---
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // --- STORE LOGIN STATE + ROLE ---
  Future<void> _setLoginState(bool isLoggedIn, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
    await prefs.setString(_userRoleKey, role);
  }

  // --- GET USER ROLE ---
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // --- SAVE USER DATA TO FIRESTORE (ADDED) ---
  Future<void> _saveUserToFirestore({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Firestore collection based on role
      final collectionRef = _firestore.collection(role);

      // Store user data as map
      final userData = {
        'fullName': fullName,
        'email': email,
        'password': password, // ⚠️ In real apps, don't store plain text passwords
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add / update document using email as document ID
      await collectionRef.doc(email).set(userData);

      print('Firestore: Added user $email under $role collection');
    } catch (e) {
      print('Firestore Error: Failed to save user $email — $e');
    }
  }
}

// --- ROLE-BASED HOMEPAGES ---

class TravelerHomePage extends StatelessWidget {
  const TravelerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseHomePage(
      title: 'Traveler Dashboard',
      subtitle: 'Plan and explore your next adventure!',
      icon: Icons.flight_takeoff,
      color: Colors.blue,
    );
  }
}

class GuideHomePage extends StatelessWidget {
  const GuideHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseHomePage(
      title: 'Guide Dashboard',
      subtitle: 'Connect with travelers and offer your expertise.',
      icon: Icons.explore,
      color: Colors.orange,
    );
  }
}

class DriverHomePage extends StatelessWidget {
  const DriverHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseHomePage(
      title: 'Driver Dashboard',
      subtitle: 'Help travelers reach destinations safely.',
      icon: Icons.drive_eta,
      color: Colors.deepPurple,
    );
  }
}

// --- REUSABLE BASE HOMEPAGE UI ---

class BaseHomePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const BaseHomePage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logOut();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: color),
              const SizedBox(height: 20),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- ROUTER BASED ON LOGIN STATE + ROLE ---

class SplashOrAuthScreen extends StatelessWidget {
  const SplashOrAuthScreen({super.key});

  Future<Widget> _getInitialScreen() async {
    final authService = AuthService();
    bool isLoggedIn = await authService.isLoggedIn();
    String? role = await authService.getUserRole();

    if (!isLoggedIn || role == null || role.isEmpty) {
      return const RoleSelectionScreen();
    }

    switch (role) {
      case 'Traveler':
        return const UserDashboard();
      case 'Guide':
        return const GuideHubApp();
      case 'Rental Driver':
        return const DriverDashboard();
      default:
        return const RoleSelectionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: _primaryBlue)),
          );
        }
        return snapshot.data!;
      },
    );
  }
}

// --- GLOBAL COLORS / THEME ---

const Color _primaryBlue = Color(0xFF4285F4);
const Color _secondaryBlue = Color(0xFF1E88E5);
const Color _gradientStart = Color(0xFFD4E7F4);
const Color _gradientEnd = Color(0xFFF0E5D7);

const LinearGradient _buttonGradient = LinearGradient(
  colors: [_primaryBlue, _secondaryBlue],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

const LinearGradient _backgroundGradient = LinearGradient(
  colors: [_gradientStart, _gradientEnd],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// --- MAIN APP ---

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: _primaryBlue,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(secondary: _secondaryBlue),
        fontFamily: 'Inter',
      ),
      home: const SplashOrAuthScreen(),
    );
  }
}

