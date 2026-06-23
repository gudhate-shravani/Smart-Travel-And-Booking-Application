
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart' show 
  GenerativeModel, 
  GenerationConfig, // <-- Corrected name from GenerateContentConfig
  Schema, 
  SchemaType, 
  Content, 
  GenerativeAIException; 

class BudgetPlannerApp extends StatelessWidget {
  const BudgetPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Budget Planner',
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
        '/': (context) => const BudgetStartScreen(),
        '/chat': (context) => const BudgetChatScreen(), 
      },
    );
  }
}

// This class represents the structured output we expect from the model.
class BudgetEstimate {
  final String total;
  final Map<String, String> breakdown;

  BudgetEstimate({required this.total, required this.breakdown});

  factory BudgetEstimate.fromJson(Map<String, dynamic> json) {
    return BudgetEstimate(
      total: json['total'] as String,
      // Cast the Map to the expected generic types
      breakdown: (json['breakdown'] as Map).cast<String, String>(),
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('Budget Estimate:\n');
    buffer.write('  Total: $total\n');
    buffer.write('  Breakdown:\n');
    breakdown.forEach((key, value) {
      buffer.write('    $key: $value\n');
    });
    return buffer.toString();
  }
}

// -----------------------------------------------------------------

class GeminiService {
  // Use a private final field for the GenerativeModel instance
  final GenerativeModel _model; 

  GeminiService({required String apiKey, String modelName = 'gemini-2.5-flash'}) 
      : _model = GenerativeModel(
            model: modelName,
            apiKey: apiKey,
          );

  Future<BudgetEstimate> getBudgetEstimate({
    required String destination,
    required int durationDays,
    required String travelStyle,
  }) async {
    
    // 1. Define the Schema for structured JSON output (now without the prefix)
    final jsonSchema = Schema(
      SchemaType.object,
      requiredProperties: const ['total', 'breakdown'], 
      properties: {
        'total': Schema(
          SchemaType.string,
          description: 'The estimated total budget, including a currency symbol (e.g., "Ã¢â€šÂ¹1,89,000").'
        ),
        'breakdown': Schema(
          SchemaType.object, 
          requiredProperties: const ['Flights', 'Accommodation', 'Food & Dining', 'Activities', 'Local Transport'], 
          description: 'A map of budget categories to their estimated costs as strings with currency.',
          properties: {
            'Flights': Schema(SchemaType.string, description: 'Cost of round-trip flights from maharashtra to that place ifno flight then 0 cost.'),
            'Accommodation': Schema(SchemaType.string, description: 'Cost of lodging.'),
            'Food & Dining': Schema(SchemaType.string, description: 'Cost of meals and drinks.'),
            'Activities': Schema(SchemaType.string, description: 'Cost of excursions and sightseeing.'),
            'Local Transport': Schema(SchemaType.string, description: 'Cost of local travel (e.g., taxi, train).'),
          },
        ),
      },
    );
    
    // 2. Craft the Prompt
    final prompt = '''
      You are an expert travel budget estimator. 
      Generate a budget estimate for a trip to: "$destination"
      Duration: "$durationDays days"
      Travel Style: "$travelStyle"
      
      The budget must be estimated in Indian Rupees (Ã¢â€šÂ¹) and should be realistic for the specified style and destination.
      Provide the result strictly in the requested JSON format.
    ''';

    // 3. Define the GenerationConfig object (name corrected)
    final contentConfig = GenerationConfig( // <-- Corrected name
        responseMimeType: 'application/json',
        responseSchema: jsonSchema,
    );

    // 4. Make the API call
    try {
      final response = await _model.generateContent( 
        [Content.text(prompt)], // Content also without the prefix
        generationConfig: contentConfig, 
      );

      // 5. Handle response and parse JSON
      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Gemini returned an empty response.');
      }

      // The model response is expected to be a valid JSON string
      final jsonString = response.text!.trim();
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return BudgetEstimate.fromJson(jsonMap); 
    } on GenerativeAIException catch (e) { // GenerativeAIException also without the prefix
        // Log the specific Gemini API error
        debugPrint('Gemini API Error: ${e.message}');
        throw Exception('Gemini API Error: ${e.message}');
    } catch (e) {
      // Catch all other exceptions (like jsonDecode failure)
      debugPrint('An unexpected error occurred: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

// ...
// ==============================================================================
// 4. SHARED THEME & CUSTOM WIDGETS
// ==============================================================================

/// Theme extension to hold the app's primary gradient colors.
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

/// The reusable button with the primary gradient.
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
// 5. BUDGET START SCREEN
// ==============================================================================

class BudgetStartScreen extends StatelessWidget {
  const BudgetStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gradientColors = Theme.of(context).extension<GradientColors>()!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              gradientColors.startColor.withValues(alpha: 0.9),
              gradientColors.endColor.withValues(alpha: 0.9)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Decorative background icons matching the visual style
            Positioned(top: 50, right: 30, child: Icon(Icons.wallet_travel, size: 80, color: Colors.white.withValues(alpha: 0.1))),
            Positioned(bottom: 50, left: 30, child: Icon(Icons.calculate, size: 80, color: Colors.white.withValues(alpha: 0.1))),

            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Center Icon
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.star, 
                      size: 48,
                      color: gradientColors.startColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'AI Budget Estimator',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Plan your dream trip with confidence',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  // Start Button
                  GradientButton(
                    text: 'Estimate Budget',
                    icon: Icons.calculate,
                    height: 50,
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat');
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ==============================================================================
// 6. BUDGET CHAT SCREEN (HANDLING STATE AND API CALL)
// ==============================================================================

class BudgetChatScreen extends StatefulWidget {
  const BudgetChatScreen({super.key});

  @override
  State<BudgetChatScreen> createState() => _BudgetChatScreenState();
}

class _BudgetChatScreenState extends State<BudgetChatScreen> {
  String? destination;
  int? durationDays;
  String? travelStyle;
  
  // 0: Destination, 1: Duration, 2: Style, 3: Show Button, 4: Loading, 5: Results, 6: Error
  int currentStep = 0; 
  bool _isLoading = false;
  bool _showBreakdown = false; 
  String? _errorMessage;

  BudgetEstimate? _budgetData;

  final GeminiService _geminiService = GeminiService(apiKey: 'gemini api key'); // Instantiate the service
  final List<String> availableStyles = ['Economy', 'Mid-Range', 'Luxury'];

  void _nextStep() {
    setState(() {
      currentStep++;
    });
  }

  void _startEstimation() async {
    if (destination != null && durationDays != null && travelStyle != null) {
      setState(() {
        currentStep = 4; // Loading state
        _isLoading = true;
        _errorMessage = null; // Clear previous errors
      });

      try {
        final estimate = await _geminiService.getBudgetEstimate(
          destination: destination!,
          durationDays: durationDays!,
          travelStyle: travelStyle!,
        );

        setState(() {
          _budgetData = estimate;
          currentStep = 5; // Results state
        });
      } catch (e) {
        debugPrint('Gemini Error: $e');
        setState(() {
          _errorMessage = 'Estimation failed. Please check your API key and try again.';
          currentStep = 6; // Error state
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method to build the common chat bubble style
  Widget _buildChatBubble(String text, bool isUser) {
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
                  child: Icon(Icons.star, color: iconColor, size: 24),
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
                  child: Icon(Icons.person, color: iconColor, size: 24), // Using person icon for user
                ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Input Widgets ---

  Widget _buildTextFieldInput({
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required Function(String) onSubmit,
    required bool enabled,
  }) {
    TextEditingController controller = TextEditingController();
    
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 50,
          width: 50,
          child: GradientButton(
            text: '',
            icon: Icons.send,
            height: 50,
            onPressed: enabled ? () {
              if (controller.text.isNotEmpty) {
                onSubmit(controller.text);
              }
            } : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStyleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          children: availableStyles.map((style) {
            final isSelected = travelStyle == style;
            return FilterChip(
              label: Text(style),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  travelStyle = selected ? style : null;
                  if (selected) {
                    currentStep = 3; // Enable button
                  } else {
                    currentStep = 2;
                  }
                });
              },
              backgroundColor: const Color(0xFFF3F4F6),
              selectedColor: Theme.of(context).extension<GradientColors>()!.startColor.withValues(alpha: 0.2),
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
      ],
    );
  }

  // --- Result Widgets ---

  Widget _buildBudgetCard() {
    if (_budgetData == null) return Container();

    final gradientColors = Theme.of(context).extension<GradientColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [gradientColors.startColor, gradientColors.endColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.endColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Approximate Budget',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _budgetData!.total,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Based on $durationDays days in $destination, $travelStyle style.',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 20),
                // Breakdown Button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showBreakdown = !_showBreakdown;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                  child: Text(
                    _showBreakdown ? 'Hide Detailed Breakdown' : 'View Detailed Breakdown',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          // Animated Breakdown Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _showBreakdown ? (_budgetData!.breakdown.length * 50) + 70 : 0, 
            child: SingleChildScrollView(
              physics: _showBreakdown ? null : const NeverScrollableScrollPhysics(), 
              child: _buildCostBreakdown(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostBreakdown() {
    final Map<String, String> breakdown = _budgetData!.breakdown;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Cost Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          ...breakdown.entries.map((entry) => _buildBreakdownRow(
                entry.key, 
                entry.value, 
                _getIconForCategory(entry.key),
              )),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String category, String amount, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).extension<GradientColors>()!.startColor.withValues(alpha: 0.1),
            child: Icon(icon, size: 20, color: Theme.of(context).extension<GradientColors>()!.startColor),
          ),
          const SizedBox(width: 12),
          Text(category, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Flights': return Icons.flight;
      case 'Accommodation': return Icons.bed;
      case 'Food & Dining': return Icons.restaurant;
      case 'Activities': return Icons.hiking;
      case 'Local Transport': return Icons.directions_bus;
      default: return Icons.money;
    }
  }


  // --- Main Build Method ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Estimator'),
        centerTitle: false,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                // AI Initial Prompt
                _buildChatBubble('Hello! I can help you estimate the cost of your trip. Please tell me the **Destination**, **Duration**, and **Travel Style**.', false),
                
                // User Input/Reply flow
                if (destination != null) _buildChatBubble(destination!, true),
                if (currentStep > 0 && destination != null) 
                  _buildChatBubble('Got it. And how many days will you be traveling?', false),
                
                if (durationDays != null) _buildChatBubble('$durationDays days', true),
                if (currentStep > 1 && durationDays != null) 
                  _buildChatBubble('Which travel style best fits your budget?', false),
                
                if (travelStyle != null) _buildChatBubble(travelStyle!, true),

                // Error Message
                if (currentStep == 6 && _errorMessage != null) 
                  _buildChatBubble('Error: $_errorMessage', false),

                // Results Card
                if (currentStep == 5) _buildBudgetCard(),
              ],
            ),
          ),
          
          // Input/CTA Area at the bottom
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: currentStep == 0
                ? _buildTextFieldInput(
                    hint: 'e.g., Tokyo, Japan',
                    icon: Icons.location_on,
                    keyboardType: TextInputType.text,
                    enabled: !_isLoading,
                    onSubmit: (text) {
                      setState(() {
                        destination = text;
                        _nextStep();
                      });
                    },
                  )
                : currentStep == 1
                    ? _buildTextFieldInput(
                        hint: 'e.g., 5 days (enter number)',
                        icon: Icons.calendar_today,
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading,
                        onSubmit: (text) {
                          final days = int.tryParse(text);
                          if (days != null && days > 0) {
                            setState(() {
                              durationDays = days;
                              _nextStep();
                            });
                          }
                        },
                      )
                    : currentStep == 2
                        ? _buildStyleSelection()
                        : currentStep == 3
                            ? GradientButton(
                                text: 'Estimate Budget',
                                icon: Icons.send,
                                onPressed: _startEstimation,
                              )
                            : currentStep == 4
                                ? LinearProgressIndicator(
                                    value: null, 
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).extension<GradientColors>()!.startColor),
                                    minHeight: 8,
                                  )
                                : currentStep == 5 || currentStep == 6 // Result or Error, allow restart
                                  ? GradientButton(
                                      text: 'Start New Estimate',
                                      icon: Icons.refresh,
                                      onPressed: () {
                                        // Reset state to start a new conversation
                                        setState(() {
                                          destination = null;
                                          durationDays = null;
                                          travelStyle = null;
                                          _budgetData = null;
                                          _errorMessage = null;
                                          currentStep = 0; 
                                          _showBreakdown = false;
                                        });
                                      },
                                    )
                                  : Container(),
          ),
          // Loading text shown under the progress bar
          if (currentStep == 4)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Calculating global exchange rates and travel costs...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }
}
