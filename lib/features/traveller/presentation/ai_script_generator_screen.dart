
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

class AIScriptGeneratorScreen extends StatefulWidget {
  const AIScriptGeneratorScreen({super.key});

  @override
  State<AIScriptGeneratorScreen> createState() =>
      _AIScriptGeneratorScreenState();
}

class _AIScriptGeneratorScreenState extends State<AIScriptGeneratorScreen> {
  String selectedPlace = '';
  final TextEditingController customInstructionController =
      TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final List<String> places = ['Taj Mahal', 'Jaipur', 'Kerala'];

  // Generated script and state
  String generatedScript = '';
  bool isLoading = false;
  bool isSpeaking = false;

  // TTS
  final FlutterTts flutterTts = FlutterTts();
  static const String geminiApiKey = 'Gemini API key â€” replace with your own from Google AI Studio';

 static const String geminiEndpoint =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent';

  final Map<String, String> languages = {
    'English': 'en-US',
    'Hindi': 'hi-IN',
    'Spanish': 'es-ES',
    'French': 'fr-FR',
    'German': 'de-DE',
  };
  String selectedLanguageLabel = 'English';

  @override
  void initState() {
    super.initState();

    flutterTts.setStartHandler(() {
      setState(() => isSpeaking = true);
    });
    flutterTts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });
    flutterTts.setCancelHandler(() {
      setState(() => isSpeaking = false);
    });
  }

  @override
  void dispose() {
    customInstructionController.dispose();
    searchController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> generateScriptFromGemini({
    required String place,
    required String instruction,
    required String languageLabel,
  }) async {
    setState(() {
      isLoading = true;
      generatedScript = '';
    });

    try {
      final url = Uri.parse('$geminiEndpoint?key=$geminiApiKey');

      final prompt = '''
You are a travel storyteller. Generate a detailed, engaging tour guide script for the place "$place" in ${languageLabel.toLowerCase()} language.
Focus on ${instruction.isEmpty ? "interesting facts, culture, and attractions" : instruction}.
Make it suitable for a tourist guide narration.
''';

      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() => generatedScript = text);
      } else {
        setState(() => generatedScript =
            'Error from Gemini API: ${response.statusCode}\n${response.body}');
      }
    } catch (e) {
      setState(() => generatedScript = 'Error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _onGeneratePressed() async {
    String placeToUse = '';

    if (searchController.text.trim().isNotEmpty) {
      placeToUse = searchController.text.trim();
    } else if (selectedPlace.isNotEmpty) {
      placeToUse = selectedPlace;
    }

    if (placeToUse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a place.')),
      );
      return;
    }

    await generateScriptFromGemini(
      place: placeToUse,
      instruction: customInstructionController.text.trim(),
      languageLabel: selectedLanguageLabel,
    );
  }

  Future<void> _toggleSpeak() async {
    if (generatedScript.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nothing to read.')));
      return;
    }

    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
      return;
    }

    final locale = languages[selectedLanguageLabel] ?? 'en-US';
    await flutterTts.setLanguage(locale);
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(generatedScript);
  }

  Future<void> _onLanguageSelected(String label) async {
    setState(() {
      selectedLanguageLabel = label;
    });

    String currentPlace = searchController.text.trim().isNotEmpty
        ? searchController.text.trim()
        : selectedPlace;

    if (currentPlace.isEmpty) return;

    await generateScriptFromGemini(
      place: currentPlace,
      instruction: customInstructionController.text.trim(),
      languageLabel: selectedLanguageLabel,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Iconsax.search_normal, color: Colors.black54, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: searchController,
              onSubmitted: (val) {
                setState(() {
                  selectedPlace = val.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Type or choose a place (e.g., ${places.join(", ")})',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Iconsax.close_circle, size: 20),
              onPressed: () {
                setState(() {
                  searchController.clear();
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildScriptControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        PopupMenuButton<String>(
          tooltip: 'Select language',
          onSelected: (label) => _onLanguageSelected(label),
          itemBuilder: (context) => languages.keys
              .map((label) => PopupMenuItem(
                    value: label,
                    child: Text(label),
                  ))
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Iconsax.global, size: 18, color: Colors.black54),
                const SizedBox(width: 6),
                Text(
                  selectedLanguageLabel,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_drop_down, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _toggleSpeak,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSpeaking
                  ? const Color(0xFF7F67F8).withValues(alpha: 0.12)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isSpeaking ? Icons.stop_circle : Icons.mic,
              color: isSpeaking ? const Color(0xFF7F67F8) : Colors.black54,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "AI Script Generator",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Iconsax.book, color: Color(0xFF7F67F8), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Select Place",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: places.map((place) {
                      final isSelected = selectedPlace == place;
                      return ChoiceChip(
                        label: Text(place),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            selectedPlace = val ? place : '';
                            searchController.text = val ? place : '';
                          });
                        },
                        backgroundColor: Colors.grey.shade100,
                        selectedColor:
                            const Color(0xFF7F67F8).withValues(alpha: 0.2),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? const Color(0xFF7F67F8)
                              : Colors.black87,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF7F67F8)
                                : Colors.transparent,
                            width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }).toList(),
                  ),
                  _buildSearchBar(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Iconsax.edit_2,
                          color: Color(0xFF7F67F8), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Custom Instructions (Optional)",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: customInstructionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          "Add specific details you want to include (e.g., focus on architecture, history, or local culture)...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _onGeneratePressed,
                icon: const Icon(Iconsax.magicpen, color: Colors.white),
                label: isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text(
                        "Generate Script",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F67F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 35),
            if (generatedScript.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Generated Script',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        _buildScriptControls(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      generatedScript,
                      style: const TextStyle(fontSize: 14, height: 1.4),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

