/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// ✅ REPLACE WITH YOUR SECURELY STORED KEY (don’t hardcode in production)
const String GEMINI_API_KEY = "AIzaSyDH-g28cH0QrS_Qru4CAn8RvZgjCC_jE20";

// --- 1. DATA MODELS ---
class Destination {
  final String name;
  final String location;
  final String description;
  final double rating;
  final String imageUrl;

  Destination({
    required this.name,
    required this.location,
    required this.description,
    required this.rating,
    required this.imageUrl,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    final query = (json['name'] as String).replaceAll(' ', '+');
    final imageUrl = 'https://source.unsplash.com/featured/400x300/?$query';
    return Destination(
      name: json['name'] ?? 'Unknown Place',
      location: json['location'] ?? 'Unknown Location',
      description: json['description'] ?? 'A wonderful place to visit!',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
      imageUrl: imageUrl,
    );
  }
}

class QuizAnswer {
  final String key;
  final String value;
  final IconData icon;
  QuizAnswer(this.key, this.value, this.icon);
}

// --- 2. LOCATION + GEMINI LOGIC ---

Future<Position?> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }
  }

  try {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  } catch (e) {
    print("Error getting location: $e");
    return null;
  }
}

Future<List<Destination>> generateAiRecommendation(
  Map<String, String> answers, {
  bool useCurrentLocation = false,
}) async {
  if (GEMINI_API_KEY.isEmpty) throw Exception("Missing Gemini API key");

  String locationHint = '';
  String locationDetails = '';

  if (useCurrentLocation) {
    Position? position = await _determinePosition();
    if (position != null) {
      locationHint =
          'User is currently near latitude ${position.latitude.toStringAsFixed(2)}, longitude ${position.longitude.toStringAsFixed(2)}. '
          'This location is the trip’s starting point.';
      locationDetails =
          'Suggest real destinations reachable from here within their selected duration. '
          'Example: Weekend → within 100 km, 3–5 days → within 300 km, 1+ week → up to 1500 km. '
          'Use nearby cities, beaches, or natural escapes accessible by car, train, or short flight. or you can sugest any place like temple waterfall fort or any small place but suitable accordin to user preferences';
    } else {
      locationHint =
          'Location access failed. Suggest nearby or regional destinations appropriate to their trip length only in india specifically maharashtra.';
    }
  } else {
    final region = answers['location'] == 'india' ? 'within India' : 'internationally';
    locationHint = 'User prefers to travel $region.';
  }

  // 🧠 Stronger distance-aware prompt
  final prompt = '''
You are an AI travel planner.
Generate **5 realistic and reachable travel destinations** that fit the user's preferences.

$locationHint
$locationDetails

🧭 User Preferences:
- Companions: ${answers['travelers']}
- Duration: ${answers['duration']}
- Budget: ${answers['budget']}
- Mood: ${answers['mood']}
- Type of Spots: ${answers['spots']}

Rules:
according to user mood suggest the places if user mood is adventure suggest mountain trekking places if relaxation suggest beach places if nature suggest forest waterfall places if city life suggest urban metro city if romantic suggest couple friendly places if cultural suggest heritage places
1. Recommend *real-world places* suitable for the given trip duration (short = nearby, long = far).
2. Provide diversity — beaches, mountains, heritage, or urban experiences matching the mood or any place.
3. Each destination must have:
   - name
   - location (City, Country)
   - short description (< 20 words)
   - rating (4.0 – 5.0 realistic)
4. Output a **valid JSON array only**. No text outside JSON.
''';

  final apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$GEMINI_API_KEY';

  final schema = {
    "type": "ARRAY",
    "items": {
      "type": "OBJECT",
      "properties": {
        "name": {"type": "STRING"},
        "location": {"type": "STRING"},
        "description": {"type": "STRING"},
        "rating": {"type": "NUMBER", "format": "float"}
      },
      "required": ["name", "location", "description", "rating"]
    }
  };

  final payload = {
    "contents": [
      {
        "parts": [
          {"text": prompt}
        ]
      }
    ],
    "generationConfig": {
      "responseMimeType": "application/json",
      "responseSchema": schema,
    },
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      final List<dynamic> list = json.decode(text);
      return list.map((e) => Destination.fromJson(e)).toList();
    } else {
      print('Gemini API error: ${response.body}');
      throw Exception('Gemini API error');
    }
  } catch (e) {
    print('Error: $e');
    return [
      Destination(
        name: "Fallback Beach",
        location: "Goa, India",
        description: "Sunny beach with palm trees.",
        rating: 4.6,
        imageUrl: "https://source.unsplash.com/featured/400x300/?goa,beach",
      ),
      Destination(
        name: "Fallback Hills",
        location: "Shimla, India",
        description: "Peaceful mountain retreat.",
        rating: 4.4,
        imageUrl: "https://source.unsplash.com/featured/400x300/?shimla,hills",
      ),
    ];
  }
}

// --- 3. MAIN APP SETUP ---
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Planner AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StartJourneyScreen(),
    );
  }
}

// --- 4. START SCREEN (unchanged) ---
class StartJourneyScreen extends StatelessWidget {
  const StartJourneyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.flight, size: 40, color: Colors.blueAccent),
                  Icon(Icons.landscape, size: 40, color: Colors.amber),
                  Icon(Icons.location_on, size: 40, color: Colors.green),
                  Icon(Icons.explore, size: 40, color: Colors.purple),
                ],
              ),
              const SizedBox(height: 50),
              const Text(
                'Find Your Perfect Travel Destination',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4C5866)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Answer a few quick questions and let AI plan your next adventure.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 250,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(SharedAxisTransitionPageBuilder(
                      page: const QuizScreen(),
                      transitionType: SharedAxisTransitionType.horizontal,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text('Start Journey',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('5 Questions • 2 Minutes • AI-Powered',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class SharedAxisTransitionPageBuilder<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SharedAxisTransitionType transitionType;
  SharedAxisTransitionPageBuilder({required this.page, required this.transitionType})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SharedAxisTransition(animation: animation, secondaryAnimation: secondaryAnimation, transitionType: transitionType, child: child),
        );
}

// --- 5. QUIZ + RESULTS (your existing UI remains the same) ---
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _userAnswers = {};
  bool _isLoading = false;
  bool _useCurrentLocation = false;

  final List<Map<String, dynamic>> _quizStructure = [
    {
      'key': 'location_pref',
      'question': 'Do you want to use your current location for recommendations?',
      'options': [
        QuizAnswer('yes', 'Use Current Location', Icons.my_location),
        QuizAnswer('no', 'Choose Travel Region', Icons.map),
      ],
      'is_initial': true,
    },
    {
      'key': 'location',
      'question': 'Where do you prefer to travel?',
      'options': [
        QuizAnswer('india', 'Within India', Icons.flag),
        QuizAnswer('international', 'International', Icons.public),
      ],
    },
    {
      'key': 'travelers',
      'question': 'Who are you traveling with?',
      'options': [
        QuizAnswer('solo', 'Solo', Icons.work),
        QuizAnswer('couple', 'Couple', Icons.favorite),
        QuizAnswer('family', 'Family', Icons.family_restroom),
        QuizAnswer('friends', 'Friends', Icons.people),
      ],
    },
    {
      'key': 'duration',
      'question': 'How long is your trip?',
      'options': [
        QuizAnswer('weekend', 'Weekend', Icons.flash_on),
        QuizAnswer('3-5days', '3–5 Days', Icons.calendar_today),
        QuizAnswer('1week', '1 Week', Icons.calendar_view_week),
        QuizAnswer('2+weeks', '2+ Weeks', Icons.public),
      ],
    },
    {
      'key': 'budget',
      'question': 'What\'s your budget?',
      'options': [
        QuizAnswer('budget', 'Budget-Friendly', FontAwesomeIcons.sackDollar),
        QuizAnswer('medium', 'Medium', FontAwesomeIcons.moneyBillWave),
        QuizAnswer('luxury', 'Luxury', FontAwesomeIcons.gem),
        QuizAnswer('nolimit', 'No Limit', FontAwesomeIcons.trophy),
      ],
    },
    {
      'key': 'mood',
      'question': 'What\'s your travel mood?',
      'options': [
        QuizAnswer('adventure', 'Adventure', FontAwesomeIcons.mountain),
        QuizAnswer('relaxation', 'Relaxation', FontAwesomeIcons.umbrellaBeach),
        QuizAnswer('nature', 'Nature', FontAwesomeIcons.tree),
        QuizAnswer('citylife', 'City Life', FontAwesomeIcons.city),
        QuizAnswer('romantic', 'Romantic', FontAwesomeIcons.heart),
        QuizAnswer('cultural', 'Cultural', FontAwesomeIcons.landmark),
      ],
    },
    {
      'key': 'spots',
      'question': 'Do you prefer popular spots or hidden gems?',
      'options': [
        QuizAnswer('popular', 'Popular Tourist Spots', FontAwesomeIcons.camera),
        QuizAnswer('hidden', 'Hidden Gems', FontAwesomeIcons.gem),
        QuizAnswer('mix', 'Mix of Both', FontAwesomeIcons.mask),
      ],
    },
  ];

  List<Map<String, dynamic>> get _currentQuizFlow {
    if (!_userAnswers.containsKey('location_pref')) {
      return [_quizStructure.first];
    } else if (_userAnswers['location_pref'] == 'yes') {
      return _quizStructure.sublist(2);
    } else {
      return _quizStructure.sublist(1);
    }
  }

  int _getQuestionNumberForProgress(String questionKey) {
    if (questionKey == 'location_pref') return 1;
    if (_userAnswers['location_pref'] == 'yes') {
      final keys = _quizStructure.sublist(2).map((q) => q['key']).toList();
      return keys.indexOf(questionKey) + 2;
    } else if (_userAnswers['location_pref'] == 'no') {
      final keys = _quizStructure.sublist(1).map((q) => q['key']).toList();
      return keys.indexOf(questionKey) + 2;
    }
    return 1;
  }

  void _handleAnswer(String questionKey, String selectedValue) {
    _userAnswers[questionKey] = selectedValue;
    setState(() {
      if (questionKey == 'location_pref') {
        _useCurrentLocation = (selectedValue == 'yes');
        _currentQuestionIndex = 0;
      } else {
        final currentFlow = _currentQuizFlow;
        if (_currentQuestionIndex < currentFlow.length - 1) {
          _currentQuestionIndex++;
        } else {
          _submitQuiz();
        }
      }
    });
  }

  void _submitQuiz() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final recommendations = await generateAiRecommendation(
        _userAnswers,
        useCurrentLocation: _useCurrentLocation,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          SharedAxisTransitionPageBuilder(
            page: ResultsScreen(recommendations: recommendations),
            transitionType: SharedAxisTransitionType.horizontal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Could not get recommendations. $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFlow = _currentQuizFlow;
    if (_currentQuestionIndex >= currentFlow.length) {
      _currentQuestionIndex = 0;
    }
    final currentQuestion = currentFlow[_currentQuestionIndex];
    final questionKey = currentQuestion['key'] as String;
    final options = currentQuestion['options'] as List<QuizAnswer>;
    final questionNumber = _getQuestionNumberForProgress(questionKey);
    const int maxQuestions = 7;
    final progress = questionNumber / maxQuestions;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 100,
              left: 30,
              child: Opacity(
                  opacity: 0.3,
                  child: Icon(Icons.luggage,
                      size: 80, color: Colors.purple.shade200))),
          Positioned(
              bottom: 50,
              right: 30,
              child: Opacity(
                  opacity: 0.3,
                  child: Icon(Icons.beach_access,
                      size: 80, color: Colors.green.shade200))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text('$questionNumber/$maxQuestions',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(const Color(0xFF0072FF),
                                const Color(0xFF00C6FF), progress)!,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text('${(progress * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: progress * 0.1).animate(
                          CurvedAnimation(
                            parent: AlwaysStoppedAnimation(progress),
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: const Icon(Icons.airplanemode_active,
                            color: Color(0xFF00C6FF)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: PageTransitionSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (child, animation, secondaryAnimation) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType:
                                SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                        child: Container(
                          key: ValueKey(
                              questionKey + _currentQuestionIndex.toString()),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(currentQuestion['question'] as String,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4C5866)),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 20),
                              ...options.map((option) {
                                final isSelected =
                                    _userAnswers[questionKey] == option.key;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: QuizOptionTile(
                                    icon: option.icon,
                                    text: option.value,
                                    isSelected: isSelected,
                                    onTap: () =>
                                        _handleAnswer(questionKey, option.key),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.95),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public,
                        size: 100, color: Color(0xFF00C6FF)),
                    const SizedBox(height: 30),
                    const Text('AI is consulting the world map...',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF4C5866))),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF00C6FF)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuizOptionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const QuizOptionTile({
    super.key,
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF00C6FF) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00C6FF).withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFF00C6FF)
                    : Colors.grey.shade500),
            const SizedBox(width: 20),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF4C5866)
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final List<Destination> recommendations;
  const ResultsScreen({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations Ready'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Perfect Destinations',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C6FF))),
            const SizedBox(height: 8),
            const Text(
                'Based on your preferences, the AI has generated these top destinations.',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            ...recommendations
                .map((destination) =>
                    DestinationCard(destination: destination))
                .toList(),
            const SizedBox(height: 30),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const StartJourneyScreen()));
                },
                icon: const Icon(Icons.refresh, color: Color(0xFF00C6FF)),
                label: const Text('Try Again',
                    style: TextStyle(
                        color: Color(0xFF00C6FF),
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;
  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  destination.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey.shade300,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF00C6FF),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.red.shade100,
                      child: const Center(
                          child: Text('Image Unavailable',
                              style: TextStyle(color: Colors.red))),
                    );
                  },
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(destination.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star,
                          color: Colors.amber, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(destination.name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C5866))),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(destination.location,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(destination.description,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF4C5866)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Tapped for more details on ${destination.name}')),
                      );
                    },
                    icon: const Icon(Icons.info_outline,
                        size: 18, color: Color(0xFF00C6FF)),
                    label: const Text('View Details',
                        style: TextStyle(color: Color(0xFF00C6FF))),
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Color(0xFF00C6FF), width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
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
}
*/



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animations/animations.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

// ✅ REPLACE WITH YOUR SECURELY STORED KEY (don’t hardcode in production)
const String GEMINI_API_KEY = "Gemini API key — replace with your own from Google AI Studio";

// --- Unsplash API Key (placeholder) ---
const String UNSPLASH_ACCESS_KEY = "Unsplash API Key ";

// --- 1. DATA MODELS ---
class Destination {
  final String name;
  final String location;
  final String description;
  final double rating;
  final String imageUrl; // kept for backward compatibility / primary image
  final List<String> galleryImages; // new — multiple images from Unsplash

  Destination({
    required this.name,
    required this.location,
    required this.description,
    required this.rating,
    required this.imageUrl,
    this.galleryImages = const [],
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    final query = (json['name'] as String).replaceAll(' ', '+');
    final imageUrl = 'https://source.unsplash.com/featured/400x300/?$query';
    return Destination(
      name: json['name'] ?? 'Unknown Place',
      location: json['location'] ?? 'Unknown Location',
      description: json['description'] ?? 'A wonderful place to visit!',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.0,
      imageUrl: imageUrl,
      galleryImages: const [],
    );
  }

  Destination copyWith({
    String? name,
    String? location,
    String? description,
    double? rating,
    String? imageUrl,
    List<String>? galleryImages,
  }) {
    return Destination(
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
    );
  }
}

class QuizAnswer {
  final String key;
  final String value;
  final IconData icon;
  QuizAnswer(this.key, this.value, this.icon);
}

// --- 2. LOCATION + GEMINI LOGIC ---

Future<Position?> _determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return null;

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return null;
    }
  }

  try {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  } catch (e) {
    print("Error getting location: $e");
    return null;
  }
}

// --- Unsplash helper: fetch multiple images for a query (destination name) ---
Future<List<String>> fetchUnsplashImages(String query, {int perPage = 6}) async {
  try {
    final encoded = Uri.encodeQueryComponent(query);
    final url =
        'https://api.unsplash.com/search/photos?query=$encoded&per_page=$perPage&client_id=$UNSPLASH_ACCESS_KEY';
    final response = await http.get(Uri.parse(url), headers: {'Accept-Version': 'v1'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final results = (data['results'] as List<dynamic>? ) ?? [];
      final List<String> urls = [];
      for (final r in results) {
        // pick a reasonable sized image (regular or small)
        final urlsMap = r['urls'] as Map<String, dynamic>?;
        if (urlsMap != null) {
          final String? imageUrl = urlsMap['regular'] ?? urlsMap['small'] ?? urlsMap['thumb'];
          if (imageUrl != null) urls.add(imageUrl);
        }
      }
      return urls;
    } else {
      print('Unsplash API error: ${response.statusCode} ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error fetching Unsplash images: $e');
    return [];
  }
}

Future<List<Destination>> generateAiRecommendation(
  Map<String, String> answers, {
  bool useCurrentLocation = false,
}) async {
  if (GEMINI_API_KEY.isEmpty) throw Exception("Missing Gemini API key");

  String locationHint = '';
  String locationDetails = '';

  if (useCurrentLocation) {
    Position? position = await _determinePosition();
    if (position != null) {
      locationHint =
          'User is currently near latitude ${position.latitude.toStringAsFixed(2)}, longitude ${position.longitude.toStringAsFixed(2)}. '
          'This location is the trip’s starting point.';
      locationDetails =
          'Suggest real destinations reachable from here within their selected duration. '
          'Example: Weekend → within 100 km, 3–5 days → within 300 km, 1+ week → up to 1500 km. '
          'Use nearby cities, beaches, or natural escapes accessible by car, train, or short flight. or you can sugest any place like temple waterfall fort or any small place but suitable accordin to user preferences';
    } else {
      locationHint =
          'Location access failed. Suggest nearby or regional destinations appropriate to their trip length only in india specifically maharashtra.';
    }
  } else {
    final region = answers['location'] == 'india' ? 'within India' : 'internationally';
    locationHint = 'User prefers to travel $region.';
  }

  // 🧠 Stronger distance-aware prompt
  final prompt = '''
You are an AI travel planner.
Generate **5 realistic and reachable travel destinations** that fit the user's preferences.

$locationHint
$locationDetails

🧭 User Preferences:
- Companions: ${answers['travelers']}
- Duration: ${answers['duration']}
- Budget: ${answers['budget']}
- Mood: ${answers['mood']}
- Type of Spots: ${answers['spots']}

Rules:
according to user mood suggest the places if user mood is adventure suggest mountain trekking places if relaxation suggest beach places if nature suggest forest waterfall places if city life suggest urban metro city if romantic suggest couple friendly places if cultural suggest heritage places
1. Recommend *real-world places* suitable for the given trip duration (short = nearby, long = far).
2. Provide diversity — beaches, mountains, heritage, or urban experiences matching the mood or any place.
3. Each destination must have:
   - name
   - location (City, Country)
   - short description (< 20 words)
   - rating (4.0 – 5.0 realistic)
4. Output a **valid JSON array only**. No text outside JSON.
''';

  final apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent?key=$GEMINI_API_KEY';

  final schema = {
    "type": "ARRAY",
    "items": {
      "type": "OBJECT",
      "properties": {
        "name": {"type": "STRING"},
        "location": {"type": "STRING"},
        "description": {"type": "STRING"},
        "rating": {"type": "NUMBER", "format": "float"}
      },
      "required": ["name", "location", "description", "rating"]
    }
  };

  final payload = {
    "contents": [
      {
        "parts": [
          {"text": prompt}
        ]
      }
    ],
    "generationConfig": {
      "responseMimeType": "application/json",
      "responseSchema": schema,
    },
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final text = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
      final List<dynamic> list = json.decode(text);
      final List<Destination> raw = list.map((e) => Destination.fromJson(e)).toList();

      // --- NEW: enrich each destination with Unsplash gallery images (non-blocking per-destination) ---
      // We'll fetch images sequentially here (keeps behavior predictable). You can parallelize if desired.
      final List<Destination> enriched = [];
      for (final d in raw) {
        final query = d.name; // search by destination name
        List<String> images = [];
        if (UNSPLASH_ACCESS_KEY.isNotEmpty && UNSPLASH_ACCESS_KEY != "YOUR_UNSPLASH_ACCESS_KEY") {
          images = await fetchUnsplashImages(query, perPage: 6);
        } else {
          // If no key provided, keep the existing fallback image and empty gallery.
          images = [];
        }

        // If Unsplash returned at least one image, set imageUrl to first; otherwise keep existing imageUrl.
        final primary = images.isNotEmpty ? images.first : d.imageUrl;
        enriched.add(d.copyWith(imageUrl: primary, galleryImages: images));
      }

      return enriched;
    } else {
      print('Gemini API error: ${response.body}');
      throw Exception('Gemini API error');
    }
  } catch (e) {
    print('Error: $e');
    return [
      Destination(
        name: "Fallback Beach",
        location: "Goa, India",
        description: "Sunny beach with palm trees.",
        rating: 4.6,
        imageUrl: "https://source.unsplash.com/featured/400x300/?goa,beach",
        galleryImages: [],
      ),
      Destination(
        name: "Fallback Hills",
        location: "Shimla, India",
        description: "Peaceful mountain retreat.",
        rating: 4.4,
        imageUrl: "https://source.unsplash.com/featured/400x300/?shimla,hills",
        galleryImages: [],
      ),
    ];
  }
}

// --- 3. MAIN APP SETUP ---
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Planner AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const StartJourneyScreen(),
    );
  }
}

// --- 4. START SCREEN (unchanged) ---
class StartJourneyScreen extends StatelessWidget {
  const StartJourneyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.flight, size: 40, color: Colors.blueAccent),
                  Icon(Icons.landscape, size: 40, color: Colors.amber),
                  Icon(Icons.location_on, size: 40, color: Colors.green),
                  Icon(Icons.explore, size: 40, color: Colors.purple),
                ],
              ),
              const SizedBox(height: 50),
              const Text(
                'Find Your Perfect Travel Destination',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4C5866)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Answer a few quick questions and let AI plan your next adventure.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 250,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(SharedAxisTransitionPageBuilder(
                      page: const QuizScreen(),
                      transitionType: SharedAxisTransitionType.horizontal,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Center(
                      child: Text('Start Journey',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text('5 Questions • 2 Minutes • AI-Powered',
                  style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class SharedAxisTransitionPageBuilder<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SharedAxisTransitionType transitionType;
  SharedAxisTransitionPageBuilder({required this.page, required this.transitionType})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              SharedAxisTransition(animation: animation, secondaryAnimation: secondaryAnimation, transitionType: transitionType, child: child),
        );
}

// --- 5. QUIZ + RESULTS (your existing UI remains the same) ---
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});
  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<String, String> _userAnswers = {};
  bool _isLoading = false;
  bool _useCurrentLocation = false;

  final List<Map<String, dynamic>> _quizStructure = [
    {
      'key': 'location_pref',
      'question': 'Do you want to use your current location for recommendations?',
      'options': [
        QuizAnswer('yes', 'Use Current Location', Icons.my_location),
        QuizAnswer('no', 'Choose Travel Region', Icons.map),
      ],
      'is_initial': true,
    },
    {
      'key': 'location',
      'question': 'Where do you prefer to travel?',
      'options': [
        QuizAnswer('india', 'Within India', Icons.flag),
        QuizAnswer('international', 'International', Icons.public),
      ],
    },
    {
      'key': 'travelers',
      'question': 'Who are you traveling with?',
      'options': [
        QuizAnswer('solo', 'Solo', Icons.work),
        QuizAnswer('couple', 'Couple', Icons.favorite),
        QuizAnswer('family', 'Family', Icons.family_restroom),
        QuizAnswer('friends', 'Friends', Icons.people),
      ],
    },
    {
      'key': 'duration',
      'question': 'How long is your trip?',
      'options': [
        QuizAnswer('weekend', 'Weekend', Icons.flash_on),
        QuizAnswer('3-5days', '3–5 Days', Icons.calendar_today),
        QuizAnswer('1week', '1 Week', Icons.calendar_view_week),
        QuizAnswer('2+weeks', '2+ Weeks', Icons.public),
      ],
    },
    {
      'key': 'budget',
      'question': 'What\'s your budget?',
      'options': [
        QuizAnswer('budget', 'Budget-Friendly', FontAwesomeIcons.sackDollar),
        QuizAnswer('medium', 'Medium', FontAwesomeIcons.moneyBillWave),
        QuizAnswer('luxury', 'Luxury', FontAwesomeIcons.gem),
        QuizAnswer('nolimit', 'No Limit', FontAwesomeIcons.trophy),
      ],
    },
    {
      'key': 'mood',
      'question': 'What\'s your travel mood?',
      'options': [
        QuizAnswer('adventure', 'Adventure', FontAwesomeIcons.mountain),
        QuizAnswer('relaxation', 'Relaxation', FontAwesomeIcons.umbrellaBeach),
        QuizAnswer('nature', 'Nature', FontAwesomeIcons.tree),
        QuizAnswer('citylife', 'City Life', FontAwesomeIcons.city),
        QuizAnswer('romantic', 'Romantic', FontAwesomeIcons.heart),
        QuizAnswer('cultural', 'Cultural', FontAwesomeIcons.landmark),
      ],
    },
    {
      'key': 'spots',
      'question': 'Do you prefer popular spots or hidden gems?',
      'options': [
        QuizAnswer('popular', 'Popular Tourist Spots', FontAwesomeIcons.camera),
        QuizAnswer('hidden', 'Hidden Gems', FontAwesomeIcons.gem),
        QuizAnswer('mix', 'Mix of Both', FontAwesomeIcons.mask),
      ],
    },
  ];

  List<Map<String, dynamic>> get _currentQuizFlow {
    if (!_userAnswers.containsKey('location_pref')) {
      return [_quizStructure.first];
    } else if (_userAnswers['location_pref'] == 'yes') {
      return _quizStructure.sublist(2);
    } else {
      return _quizStructure.sublist(1);
    }
  }

  int _getQuestionNumberForProgress(String questionKey) {
    if (questionKey == 'location_pref') return 1;
    if (_userAnswers['location_pref'] == 'yes') {
      final keys = _quizStructure.sublist(2).map((q) => q['key']).toList();
      return keys.indexOf(questionKey) + 2;
    } else if (_userAnswers['location_pref'] == 'no') {
      final keys = _quizStructure.sublist(1).map((q) => q['key']).toList();
      return keys.indexOf(questionKey) + 2;
    }
    return 1;
  }

  void _handleAnswer(String questionKey, String selectedValue) {
    _userAnswers[questionKey] = selectedValue;
    setState(() {
      if (questionKey == 'location_pref') {
        _useCurrentLocation = (selectedValue == 'yes');
        _currentQuestionIndex = 0;
      } else {
        final currentFlow = _currentQuizFlow;
        if (_currentQuestionIndex < currentFlow.length - 1) {
          _currentQuestionIndex++;
        } else {
          _submitQuiz();
        }
      }
    });
  }

  void _submitQuiz() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final recommendations = await generateAiRecommendation(
        _userAnswers,
        useCurrentLocation: _useCurrentLocation,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          SharedAxisTransitionPageBuilder(
            page: ResultsScreen(recommendations: recommendations),
            transitionType: SharedAxisTransitionType.horizontal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: Could not get recommendations. $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentFlow = _currentQuizFlow;
    if (_currentQuestionIndex >= currentFlow.length) {
      _currentQuestionIndex = 0;
    }
    final currentQuestion = currentFlow[_currentQuestionIndex];
    final questionKey = currentQuestion['key'] as String;
    final options = currentQuestion['options'] as List<QuizAnswer>;
    final questionNumber = _getQuestionNumberForProgress(questionKey);
    const int maxQuestions = 7;
    final progress = questionNumber / maxQuestions;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 100,
              left: 30,
              child: Opacity(
                  opacity: 0.3,
                  child: Icon(Icons.luggage,
                      size: 80, color: Colors.purple.shade200))),
          Positioned(
              bottom: 50,
              right: 30,
              child: Opacity(
                  opacity: 0.3,
                  child: Icon(Icons.beach_access,
                      size: 80, color: Colors.green.shade200))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text('$questionNumber/$maxQuestions',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 15),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color.lerp(const Color(0xFF0072FF),
                                const Color(0xFF00C6FF), progress)!,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text('${(progress * 100).toInt()}%',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 5),
                      RotationTransition(
                        turns: Tween(begin: 0.0, end: progress * 0.1).animate(
                          CurvedAnimation(
                            parent: AlwaysStoppedAnimation(progress),
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: const Icon(Icons.airplanemode_active,
                            color: Color(0xFF00C6FF)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: PageTransitionSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (child, animation, secondaryAnimation) {
                          return SharedAxisTransition(
                            animation: animation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType:
                                SharedAxisTransitionType.horizontal,
                            child: child,
                          );
                        },
                        child: Container(
                          key: ValueKey(
                              questionKey + _currentQuestionIndex.toString()),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(currentQuestion['question'] as String,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4C5866)),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 20),
                              ...options.map((option) {
                                final isSelected =
                                    _userAnswers[questionKey] == option.key;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: QuizOptionTile(
                                    icon: option.icon,
                                    text: option.value,
                                    isSelected: isSelected,
                                    onTap: () =>
                                        _handleAnswer(questionKey, option.key),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.white.withOpacity(0.95),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.public,
                        size: 100, color: Color(0xFF00C6FF)),
                    const SizedBox(height: 30),
                    const Text('AI is consulting the world map...',
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF4C5866))),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: 100,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF00C6FF)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class QuizOptionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const QuizOptionTile({
    super.key,
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F7FA) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF00C6FF) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00C6FF).withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected
                    ? const Color(0xFF00C6FF)
                    : Colors.grey.shade500),
            const SizedBox(width: 20),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? const Color(0xFF4C5866)
                    : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Part 2: Results + Destination Card (with horizontal gallery) ---
class ResultsScreen extends StatelessWidget {
  final List<Destination> recommendations;
  const ResultsScreen({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recommendations Ready'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Perfect Destinations',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00C6FF))),
            const SizedBox(height: 8),
            const Text(
                'Based on your preferences, the AI has generated these top destinations.',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            ...recommendations
                .map((destination) =>
                    DestinationCard(destination: destination))
                .toList(),
            const SizedBox(height: 30),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const StartJourneyScreen()));
                },
                icon: const Icon(Icons.refresh, color: Color(0xFF00C6FF)),
                label: const Text('Try Again',
                    style: TextStyle(
                        color: Color(0xFF00C6FF),
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;
  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 3,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE AREA: now supports galleryImages (horizontal scroll) while preserving original sizing and styling
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: destination.galleryImages.isNotEmpty
                      // horizontal gallery (scrollable)
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: destination.galleryImages.length,
                          itemBuilder: (context, index) {
                            final img = destination.galleryImages[index];
                            return SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Image.network(
                                img,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: Colors.grey.shade300,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        color: const Color(0xFF00C6FF),
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: Colors.red.shade100,
                                    child: const Center(
                                        child: Text('Image Unavailable',
                                            style: TextStyle(color: Colors.red))),
                                  );
                                },
                              ),
                            );
                          },
                        )
                      // fallback to single image (existing behavior)
                      : Image.network(
                          destination.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.grey.shade300,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: const Color(0xFF00C6FF),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.red.shade100,
                              child: const Center(
                                  child: Text('Image Unavailable',
                                      style: TextStyle(color: Colors.red))),
                            );
                          },
                        ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(destination.rating.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star,
                          color: Colors.amber, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(destination.name,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C5866))),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(destination.location,
                        style: const TextStyle(
                            fontSize: 16, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(destination.description,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF4C5866)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Tapped for more details on ${destination.name}')) ,
                      );
                    },
                    icon: const Icon(Icons.info_outline,
                        size: 18, color: Color(0xFF00C6FF)),
                    label: const Text('View Details',
                        style: TextStyle(color: Color(0xFF00C6FF))),
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: Color(0xFF00C6FF), width: 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
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
}
