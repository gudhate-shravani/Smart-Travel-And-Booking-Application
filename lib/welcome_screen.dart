// welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart' show 
  GenerativeModel, 
  GenerationConfig, // <-- Corrected name from GenerateContentConfig
  Schema, 
  SchemaType, 
  Content, 
  GenerativeAIException; 

import 'packing_list_screen.dart';
import 'data.dart';
// Note: Ensure _apiKey is available if you kept it in main.dart or pass it here

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _destinationController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  
  // The client must be initialized globally or accessed via a Singleton/Provider
  // For simplicity, we create it here, assuming the API key is accessible.
  // In a production app, use Dependency Injection.
  late final GenerativeModel _model;
  
  @override
  void initState() {
    super.initState();
    // Assuming the API key is accessible here (e.g., via environment variable or passed through)
    // Using gemini-2.5-flash for fast response and good JSON generation.
    _model = GenerativeModel(
        model: 'gemini-2.5-flash', 
        apiKey: 'AIzaSyBFSi_4N951bnJFgh8XofLqRwYZGZE3Ndk', // IMPORTANT: Replace or ensure _apiKey is accessible
    );
  }

  Future<void> _generatePackingList() async {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a destination.';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // 1. Craft the detailed, structured prompt
    const systemInstruction = "You are a travel packing list generator. Given a destination, your task is to generate a comprehensive packing list categorized by type. Respond ONLY with a valid JSON array of categories. DO NOT include any text, markdown explanation, or conversational dialogue outside of the JSON block.";

    final userPrompt = "Generate a packing list for a 7-day trip to '$destination'. The output must be a JSON array. Each object in the array must have two keys: 'category' (string) and 'items' (array). Each item in 'items' must have 'name' (string) and 'quantity' (string, e.g., '(3-5)', '(2 pairs)', or null if none).";

    try {
      final response = await _model.generateContent(
        [Content.text(userPrompt)],
        generationConfig: GenerationConfig(
         // Instruction: systemInstruction,
          // Force JSON output for reliable parsing
          responseMimeType: "application/json", 
          responseSchema: Schema(
             SchemaType.array,
            items: Schema(
               SchemaType.object,
              properties: {
                'category': Schema( SchemaType.string, description: 'e.g., Clothing, Essentials, Electronics'),
                'items': Schema(
                   SchemaType.array,
                  items: Schema(
                     SchemaType.object,
                    properties: {
                      'name': Schema( SchemaType.string, description: 'e.g., T-shirts, Phone Charger'),
                      'quantity': Schema( SchemaType.string, description: 'Suggested quantity, e.g., (3-5), (2 pairs), or null'),
                    },
                  ),
                ),
              },
            ),
          ),
        ),
      );

      final jsonText = response.text;
      if (jsonText == null || jsonText.isEmpty) {
        throw Exception("API returned an empty list.");
      }

      // 2. Parse the JSON response into our Flutter model
      final generatedList = PackingCategory.fromJsonString(jsonText);

      if (generatedList.isEmpty) {
        throw Exception("Could not parse the generated list.");
      }

      // 3. Navigate to the list screen with the new data
      // Using pushReplacement to prevent going back to the welcome screen with the back button
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PackingListScreen(
            destination: destination,
            packingList: generatedList, // Pass the generated list
          ),
        ),
      );
      
    } catch (e) {
      print('Gemini API Error: $e');
      setState(() {
        _errorMessage = 'Failed to generate list. Please try again or check your API key.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // ... (Static UI elements like Icon and Text)
              const Icon(
                Icons.airplanemode_active,
                size: 80,
                color: Color(0xFF673AB7),
              ),
              const SizedBox(height: 16),
              const Text(
                'Welcome to PackMate',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              // ... (Other static text)
              const SizedBox(height: 40),
              
              // Location Input Field
              // ... (Input Field Label)
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _destinationController, // Use controller
                  decoration: const InputDecoration(
                    hintText: 'e.g., Paris, Tokyo, New York...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              if (_errorMessage.isNotEmpty) 
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              const SizedBox(height: 30),
              
              // Generate Button (Gradient inspired by video)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextButton(
                  // Disable button while loading
                  onPressed: _isLoading ? null : _generatePackingList,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Generate My Packing List',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}