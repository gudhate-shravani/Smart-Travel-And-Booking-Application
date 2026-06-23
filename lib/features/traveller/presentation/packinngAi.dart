
import 'package:flutter/material.dart';
import 'welcome_screen.dart';

const String _apiKey = "YOUR_API_KEY"; 
void main() {
  // 1. Initialize the AI client
  if (_apiKey.isEmpty || _apiKey == 'YOUR_API_KEY') {
    throw Exception("ERROR: GEMINI_API_KEY not set. Please set your key.");
  }
  
  runApp(const PackMateApp());
}

// ... (PackMateApp class remains the same)

class PackMateApp extends StatelessWidget {
  const PackMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PackMate App UI',
      theme: ThemeData(
        primaryColor: const Color(0xFF673AB7), // Purple
        scaffoldBackgroundColor: Colors.grey[50], // Very light grey background
        fontFamily: 'Roboto', // A clean, common font
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}