


import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert'; // For JSON decoding

// ==============================================================================
// 1. API KEY & SERVICE
// ==============================================================================

// IMPORTANT: Replace this with your actual Gemini API Key
// In a real app, use environment variables for security.
const String _GEMINI_API_KEY = " Replace this with your actual Gemini API Key";

class GeminiService {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-2.5-flash', // A model good for structured text generation
    apiKey: _GEMINI_API_KEY,
  );

  /// Generates a structured trip itinerary using the Gemini API.
  Future<Map<String, dynamic>?> generateItinerary({
    required String destination,
    required int days,
    required List<String> interests,
  }) async {
    if (_GEMINI_API_KEY == "YOUR_API_KEY_HERE" || _GEMINI_API_KEY.isEmpty) {
      // Return a structured error response or throw an exception
      print("Gemini API key is not set. Please update _GEMINI_API_KEY.");
      return null;
    }

    // The detailed prompt for structured JSON output
    final String prompt = '''
      You are an expert travel agent AI. Generate a detailed, $days-day trip itinerary for $destination,
      focusing on the user's interests: ${interests.join(', ')}.

      The output MUST be a valid JSON object that strictly adheres to the following structure.
      DO NOT include any text outside the JSON block.

      JSON Structure:
      {
        "tripTitle": "A concise title for the trip (e.g., Kyoto Nature and Culture)",
        "itinerary": [
          {
            "day": 1,
            "theme": "Day's theme (e.g., Historic Sites and Temples)",
            "attractions": [
              {
                "name": "Attraction Name (e.g., Kiyomizu-dera Temple)",
                "time": "Time slot (e.g., 9:00 AM - 11:00 AM)",
                "description": "Brief, engaging description of the activity/place (max 20 words)",
                "duration": "e.g., 2 hours"
              },
              {
                "name": "Attraction Name 2",
                "time": "Time slot 2",
                "description": "Brief description 2",
                "duration": "Duration 2"
              }
              // ... up to 3 attractions per day
            ]
          }
          // ... repeat for $days days
        ]
      }
      ''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      
      String jsonText = response.text!.trim();
      
      // Clean up markdown fences if present
      if (jsonText.startsWith('```json')) {
        jsonText = jsonText.substring(7);
      }
      if (jsonText.endsWith('```')) {
        jsonText = jsonText.substring(0, jsonText.length - 3);
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(jsonText);
      return jsonResponse;
    } catch (e) {
      print("Gemini API Error: $e");
      return null;
    }
  }
}




class TripPlannerApp extends StatelessWidget {
  const TripPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Trip Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        extensions: <ThemeExtension<dynamic>>[
          GradientColors(
            startColor: const Color(0xFF6A82FB),
            endColor: const Color(0xFFFC5C7D),
          ),
        ],
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartScreen(),
        '/planning': (context) => const PlanningChatScreen(),
        // The /generating and /ready routes are now handled dynamically
      },
    );
  }
}

// ==============================================================================
// 2. THEME EXTENSIONS & CUSTOM WIDGETS
// ==============================================================================

class GradientColors extends ThemeExtension<GradientColors> {
  const GradientColors({
    required this.startColor,
    required this.endColor,
  });

  final Color startColor;
  final Color endColor;

  @override
  ThemeExtension<GradientColors> copyWith({
    Color? startColor,
    Color? endColor,
  }) {
    return GradientColors(
      startColor: startColor ?? this.startColor,
      endColor: endColor ?? this.endColor,
    );
  }

  @override
  ThemeExtension<GradientColors> lerp(
      covariant ThemeExtension<GradientColors>? other, double t) {
    if (other is! GradientColors) {
      return this;
    }
    return GradientColors(
      startColor: Color.lerp(startColor, other.startColor, t)!,
      endColor: Color.lerp(endColor, other.endColor, t)!,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed; 
  final double height;

  const GradientButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed, 
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = Theme.of(context).extension<GradientColors>()!;
    final double opacity = onPressed == null ? 0.5 : 1.0; 
    
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [gradientColors.startColor, gradientColors.endColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed, 
          borderRadius: BorderRadius.circular(30),
          child: Opacity( 
            opacity: opacity,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// 3. StartScreen
// ==============================================================================

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = Theme.of(context).extension<GradientColors>()!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientColors.startColor.withOpacity(0.1),
              gradientColors.endColor.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.airplanemode_active,
                  size: 48,
                  color: gradientColors.startColor,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars, color: gradientColors.startColor),
                  const Text(
                    'AI Trip Planner',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.stars, color: gradientColors.endColor),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Plan Smart. Travel Better.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              GradientButton(
                text: 'Start Planning',
                icon: Icons.rocket_launch,
                onPressed: () {
                  Navigator.pushNamed(context, '/planning');
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// 4. PlanningChatScreen
// ==============================================================================

class PlanningChatScreen extends StatefulWidget {
  const PlanningChatScreen({super.key});

  @override
  State<PlanningChatScreen> createState() => _PlanningChatScreenState();
}

class _PlanningChatScreenState extends State<PlanningChatScreen> {
  String? destination;
  int? days;
  List<String> interests = [];
  int currentStep = 0; // 0: Destination, 1: Days, 2: Interests

  final List<String> availableInterests = [
    'Adventure',
    'Culture',
    'Relaxation',
    'Food',
    'Nature',
    'History'
  ];

  void _nextStep() {
    setState(() {
      currentStep++;
    });
  }

  void _generateTrip() {
    if (destination != null && days != null && interests.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneratingTripScreen(
            destination: destination!,
            days: days!,
            interests: interests,
          ),
        ),
      );
    }
  }

  Widget _buildChatBubble(String text, bool isUser, {Widget? trailing}) {
    final bubbleColor = isUser ? const Color(0xFF6A82FB) : const Color(0xFFF3F4F6);
    final textColor = isUser ? Colors.white : Colors.black87;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final iconColor = isUser ? Colors.white : Theme.of(context).extension<GradientColors>()!.startColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.stars, color: iconColor, size: 24),
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    text,
                    style: TextStyle(color: textColor, fontSize: 16),
                  ),
                ),
              ),
              if (isUser)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.stars, color: iconColor, size: 24),
                ),
            ],
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildProgressStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: List.generate(3, (index) {
          final isComplete = index < currentStep;
          final isActive = index == currentStep;
          return Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: isComplete || isActive
                    ? LinearGradient(
                        colors: [
                          Theme.of(context).extension<GradientColors>()!.startColor,
                          Theme.of(context).extension<GradientColors>()!.endColor
                        ],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade300],
                      ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Trip'),
        centerTitle: false,
        automaticallyImplyLeading: false, 
      ),
      body: Column(
        children: [
          _buildProgressStepper(),
          Expanded(
            child: ListView(
              children: [
                _buildChatBubble('Hi traveler! 🌎 Where do you want to go?', false),
                if (destination != null)
                  _buildChatBubble(destination!, true),
                if (destination != null)
                  _buildChatBubble('How many days are you planning to stay?', false),
                if (days != null)
                  _buildChatBubble('$days days', true),
                if (days != null)
                  _buildChatBubble('Any preferences? Pick what excites you!', false),
                if (interests.isNotEmpty && currentStep == 3)
                  _buildChatBubble(interests.join(', '), true),
              ],
            ),
          ),
          // Input Area at the bottom
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: currentStep == 0
                ? _buildDestinationInput()
                : currentStep == 1
                    ? _buildDaysInput()
                    : _buildInterestsSelection(),
          ),
        ],
      ),
    );
  }

  // --- Step 1: Destination Input ---
  Widget _buildDestinationInput() {
    TextEditingController controller = TextEditingController();
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'e.g., Kyoto, Japan',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
          ),
        ),
        const SizedBox(height: 10),
        GradientButton(
          text: 'Continue',
          icon: Icons.send,
          height: 50,
          onPressed: () {
            if (controller.text.isNotEmpty) {
              setState(() {
                destination = controller.text;
                _nextStep();
              });
            }
          },
        ),
      ],
    );
  }

  // --- Step 2: Days Input ---
  Widget _buildDaysInput() {
    TextEditingController controller = TextEditingController();
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'e.g., 5',
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
          ),
        ),
        const SizedBox(height: 10),
        GradientButton(
          text: 'Continue',
          icon: Icons.send,
          height: 50,
          onPressed: () {
            final daysValue = int.tryParse(controller.text);
            if (daysValue != null && daysValue > 0) {
              setState(() {
                days = daysValue;
                _nextStep();
              });
            }
          },
        ),
      ],
    );
  }

  // --- Step 3: Interests Selection ---
  Widget _buildInterestsSelection() {
    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: availableInterests.map((interest) {
            final isSelected = interests.contains(interest);
            return FilterChip(
              label: Text(interest),
              avatar: Icon(_getIconForInterest(interest), size: 18),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    interests.add(interest);
                  } else {
                    interests.remove(interest);
                  }
                });
              },
              backgroundColor: const Color(0xFFF3F4F6),
              selectedColor: Theme.of(context).extension<GradientColors>()!.startColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).extension<GradientColors>()!.startColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isSelected ? Theme.of(context).extension<GradientColors>()!.startColor : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        GradientButton(
          text: 'Generate My Trip',
          icon: Icons.send,
          height: 50,
          onPressed: interests.isNotEmpty ? _generateTrip : null,
        ),
      ],
    );
  }

  IconData _getIconForInterest(String interest) {
    switch (interest) {
      case 'Adventure':
        return Icons.hiking;
      case 'Culture':
        return Icons.museum;
      case 'Relaxation':
        return Icons.spa;
      case 'Food':
        return Icons.restaurant;
      case 'Nature':
        return Icons.forest;
      case 'History':
        return Icons.history_edu;
      default:
        return Icons.favorite;
    }
  }
}

// ==============================================================================
// 5. GeneratingTripScreen
// ==============================================================================

class GeneratingTripScreen extends StatefulWidget {
  final String destination;
  final int days;
  final List<String> interests;

  const GeneratingTripScreen({
    super.key,
    required this.destination,
    required this.days,
    required this.interests,
  });

  @override
  State<GeneratingTripScreen> createState() => _GeneratingTripScreenState();
}

class _GeneratingTripScreenState extends State<GeneratingTripScreen> {
  final GeminiService _geminiService = GeminiService();
  
  final List<String> steps = [
    'Analyzing your destination...',
    'Requesting itinerary...',
    'Processing and structuring...',
    'Your trip is ready!',
  ];
  int currentStepIndex = 0;
  bool _isGenerating = true;
  Map<String, dynamic>? _itineraryData;

  @override
  void initState() {
    super.initState();
    _startGenerationProcess();
  }

  void _startGenerationProcess() async {
    // 1. Simulate API call for visual progression up to step 2
    for (int i = 0; i < steps.length - 1; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          currentStepIndex = i + 1;
        });
      }
    }

    // 2. Call Gemini API
    _itineraryData = await _geminiService.generateItinerary(
      destination: widget.destination,
      days: widget.days,
      interests: widget.interests,
    );
    
    // 3. Complete visual steps
    if (mounted) {
      setState(() {
        currentStepIndex = steps.length;
        _isGenerating = false;
      });
    }

    // 4. Navigate to the Ready Screen if data is valid
    if (_itineraryData != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TripReadyScreen(
              destination: widget.destination,
              days: widget.days,
              interests: widget.interests,
              itineraryData: _itineraryData!,
            ),
          ),
        );
      }
    } else {
      // Handle API or key error: reset state and show error message
      if (mounted) {
        setState(() {
          currentStepIndex = 0; // Reset progress
          _isGenerating = false;
        });
        // Show an error message (e.g., dialog or SnackBar)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error generating trip. Check API key or network.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradientColors = Theme.of(context).extension<GradientColors>()!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.travel_explore,
                size: 80,
                color: gradientColors.startColor,
              ),
              const SizedBox(height: 30),
              const Text(
                'Creating Your Perfect Trip',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ...steps.asMap().entries.map((entry) {
                int index = entry.key;
                String step = entry.value;
                bool isCompleted = index < currentStepIndex;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.radio_button_off,
                        color: isCompleted ? Colors.green : Colors.grey.shade400,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        step,
                        style: TextStyle(
                          fontSize: 16,
                          color: isCompleted ? Colors.black87 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 40),
              // Simple Linear Progress Bar
              LinearProgressIndicator(
                value: _isGenerating ? currentStepIndex / steps.length : 1.0,
                valueColor: AlwaysStoppedAnimation<Color>(gradientColors.startColor),
                backgroundColor: Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// 6. TripReadyScreen
// ==============================================================================

class TripReadyScreen extends StatelessWidget {
  final String destination;
  final int days;
  final List<String> interests;
  final Map<String, dynamic> itineraryData;

  const TripReadyScreen({
    super.key,
    required this.destination,
    required this.days,
    required this.interests,
    required this.itineraryData,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = Theme.of(context).extension<GradientColors>()!;
    final String tripTitle = itineraryData['tripTitle'] ?? '$destination Adventure';
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientColors.startColor.withOpacity(0.1),
              gradientColors.endColor.withOpacity(0.1)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.check_circle, size: 70, color: Colors.green),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Trip Ready! ',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(Icons.emoji_objects, color: Colors.amber),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your perfect $days-day trip to $destination awaits!',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [gradientColors.startColor, gradientColors.endColor],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tripTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '📅 $days Days of Exploration',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Your Interests',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8.0,
                              children: interests.map((interest) => Chip(label: Text(interest))).toList(),
                            ),
                            const Divider(height: 30),
                            _buildCheckRow('AI-Generated Itinerary', Colors.green),
                            _buildCheckRow('Personalized to Interests', Colors.green),
                            _buildCheckRow('Ready for Travel', Colors.green),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed bottom buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 20.0, right: 20.0),
              child: Column(
                children: [
                  GradientButton(
                    text: 'Start Your Trip',
                    icon: Icons.rocket_launch,
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItineraryScreen(
                            itineraryData: itineraryData,
                            destination: destination,
                            days: days,
                            interests: interests,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share, color: Colors.grey),
                    label: const Text('Share Plan', style: TextStyle(color: Colors.grey)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: color),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

// ==============================================================================
// 7. ItineraryScreen
// ==============================================================================

class ItineraryScreen extends StatelessWidget {
  final String destination;
  final int days;
  final List<String> interests;
  final Map<String, dynamic> itineraryData;

  const ItineraryScreen({
    super.key,
    required this.destination,
    required this.days,
    required this.interests,
    required this.itineraryData,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = Theme.of(context).extension<GradientColors>()!;
    final List<dynamic> itineraryList = itineraryData['itinerary'] ?? [];
    final String tripTitle = itineraryData['tripTitle'] ?? 'Your Trip Itinerary';
    
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0, 
                collapsedHeight: 120.0, 
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(bottom: 16, left: 16),
                  title: Column( 
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: gradientColors.startColor, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            destination,
                            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          const Chip(
                            label: Text('Ready', style: TextStyle(fontSize: 12, color: Colors.white)),
                            backgroundColor: Colors.green,
                            labelPadding: EdgeInsets.zero,
                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      Text(
                        '$days-day trip: ${tripTitle}',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      FittedBox( 
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 16), 
                              label: const Text('Edit Plan', style: TextStyle(fontSize: 12)), 
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                minimumSize: Size.zero, 
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download, size: 16), 
                              label: const Text('Export PDF', style: TextStyle(fontSize: 12)), 
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                minimumSize: Size.zero, 
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap, 
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  centerTitle: false,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [gradientColors.startColor.withOpacity(0.1), gradientColors.endColor.withOpacity(0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, dayIndex) {
                    if (dayIndex >= itineraryList.length) return null;
                    final dayData = itineraryList[dayIndex];
                    return _buildDaySection(context, dayData);
                  },
                  childCount: itineraryList.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for the floating button
            ],
          ),
          // Floating "Continue to Summary" Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GradientButton(
                text: 'Continue to Summary',
                icon: Icons.arrow_forward,
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySection(BuildContext context, Map<String, dynamic> dayData) {
    final List<dynamic> attractionsList = dayData['attractions'] ?? [];
    
    return Padding(
      padding: const EdgeInsets.only(left: 32.0, right: 16.0, top: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).extension<GradientColors>()!.startColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Day ${dayData['day']} - ${dayData['theme'] ?? 'Explore'}',
              style: TextStyle(
                color: Theme.of(context).extension<GradientColors>()!.startColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          ...attractionsList.asMap().entries.map((entry) {
            final index = entry.key;
            final attraction = entry.value as Map<String, dynamic>;
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      // Timeline dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Theme.of(context).extension<GradientColors>()!.endColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Timeline line
                      if (index < attractionsList.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: _buildAttractionCard(context, attraction),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAttractionCard(BuildContext context, Map<String, dynamic> attraction) {
    
    // Defaulting fields that might not be in the simple AI JSON response
    final String weather = attraction['weather'] ?? 'Check App'; 
    final String duration = attraction['duration'] ?? 'N/A';
    
    final imagePlaceholder = Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
      ),
      child: const Center(child: Text('Image Placeholder')),
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with name and time overlay
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              imagePlaceholder,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attraction['name'] ?? 'Unknown Attraction',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          attraction['time'] ?? 'Time TBD',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attraction['description'] ?? 'No description provided.'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny, color: Colors.orange, size: 16),
                        const SizedBox(width: 4),
                        Text(weather),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(duration),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}