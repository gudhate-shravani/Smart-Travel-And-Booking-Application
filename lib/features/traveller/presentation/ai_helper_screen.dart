// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';



class AICoGuideScreen extends StatefulWidget {
  const AICoGuideScreen({super.key});

  @override
  State<AICoGuideScreen> createState() => _AICoGuideScreenState();
}

class _AICoGuideScreenState extends State<AICoGuideScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  bool _loading = false;

  String _answer = '';
  String _imageAnswer = '';
  File? _pickedImage;

  final String apiKey = 'Put your Gemini API key here';
  String _extractTextFromResponse(dynamic json) {
    if (json == null) return '';
    try {
      if (json is Map && json.containsKey('candidates')) {
        final cands = json['candidates'];
        if (cands is List && cands.isNotEmpty) {
          final first = cands[0];
          // Typical shapes:
          // 1) {"content": {"parts": [{"text":"..."}]}}
          if (first is Map && first.containsKey('content')) {
            final content = first['content'];
            if (content is Map && content.containsKey('parts')) {
              final parts = content['parts'];
              if (parts is List && parts.isNotEmpty) {
                for (var p in parts) {
                  if (p is Map && p.containsKey('text') && (p['text'] as String).trim().isNotEmpty) {
                    return (p['text'] as String).trim();
                  }
                }
              }
            }
            // fallback: search recursively inside 'content'
            final found = _searchForString(first['content']);
            if (found.isNotEmpty) return found;
          }
        }
      }
    } catch (_) {}
    return _searchForString(json);
  }

  String _searchForString(dynamic node) {
    if (node == null) return '';
    if (node is String) {
      final s = node.trim();
      if (s.length >= 6) return s;
      return '';
    }
    if (node is Map) {
      for (final v in node.values) {
        final found = _searchForString(v);
        if (found.isNotEmpty) return found;
      }
    }
    if (node is List) {
      for (final v in node) {
        final found = _searchForString(v);
        if (found.isNotEmpty) return found;
      }
    }
    return '';
  }

  Future<String> _callGeminiForText(String prompt) async {
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$apiKey',
    );

    final requestBody = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "You are an expert travel guide. Answer concisely and informatively for tourists. Question: $prompt"
            }
          ]
        }
      ]
    };

    final r = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody));

    if (r.statusCode != 200) {
      throw Exception('Gemini API error (${r.statusCode}): ${r.body}');
    }

    final data = jsonDecode(r.body);
    final text = _extractTextFromResponse(data);
    return text;
  }

  // --- Call Gemini with inline image data (base64) to identify place in image ---
  Future<String> _callGeminiForImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final base64Data = base64Encode(bytes);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$apiKey',
    );

    final requestBody = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text":
                  "You are an expert travel guide and image recognizer. Identify the monument/place in the image, give its name, location, short history and why it's famous."
            },
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": base64Data,
              }
            }
          ]
        }
      ]
    };

    final r = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody));

    if (r.statusCode != 200) {
      throw Exception('Gemini API error (${r.statusCode}): ${r.body}');
    }

    final data = jsonDecode(r.body);
    final text = _extractTextFromResponse(data);
    return text;
  }

  // --- UI actions ---
  Future<void> _askQuestion() async {
    final q = _questionController.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _answer = '';
    });

    try {
      final reply = await _callGeminiForText(q);
      setState(() => _answer = reply.isEmpty ? "No useful reply. Try rephrasing or add country." : reply);
    } catch (e) {
      setState(() => _answer = 'Error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _searchPlaceTyped() async {
    final q = _placeController.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _imageAnswer = '';
    });
    try {
      final reply = await _callGeminiForText("Tell me about $q (history, location, significance).");
      setState(() => _imageAnswer = reply.isEmpty ? "No useful reply. Try adding country or specifics." : reply);
    } catch (e) {
      setState(() => _imageAnswer = 'Error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImageAndIdentify() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    setState(() {
      _pickedImage = file;
      _loading = true;
      _imageAnswer = '';
    });

    try {
      final reply = await _callGeminiForImage(file);
      setState(() => _imageAnswer = reply.isEmpty ? "Couldn't recognize place; try clearer photo." : reply);
    } catch (e) {
      setState(() => _imageAnswer = 'Error: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    await _tts.setLanguage('en-IN');
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  Future<void> _openMapFor(String place) async {
    if (place.trim().isEmpty) return;
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(place)}';
    final uri = Uri.parse(url);
    if (!await canLaunchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open maps')));
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Co-Guide'), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Card 1
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Ask AI About Any Place', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: 'Ask about a monument, city, or place',
                    suffixIcon: IconButton(icon: const Icon(Icons.send, color: Colors.teal), onPressed: _askQuestion),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                if (_loading) const Center(child: CircularProgressIndicator()) else if (_answer.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(_answer),
                  ),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton.icon(onPressed: () => _speak(_answer), icon: const Icon(Icons.volume_up), label: const Text('Speak')),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(onPressed: () => _openMapFor(_questionController.text), icon: const Icon(Icons.location_on), label: const Text('Show on Map')),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // Card 2
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Identify a Monument or Place', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton.icon(onPressed: _pickImageAndIdentify, icon: const Icon(Icons.image), label: const Text('Upload Photo')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _placeController,
                      decoration: InputDecoration(
                        hintText: 'Enter Place Name',
                        suffixIcon: IconButton(icon: const Icon(Icons.search, color: Colors.teal), onPressed: _searchPlaceTyped),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                if (_pickedImage != null) ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_pickedImage!, height: 160, fit: BoxFit.cover)),
                const SizedBox(height: 10),
                if (_imageAnswer.isNotEmpty)
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)), child: Text(_imageAnswer)),
              ]),
            ),
          ),

          const SizedBox(height: 18),
          const Text('Powered by AI Co-Guide', style: TextStyle(color: Colors.grey)),
        ]),
      ),
    );
  }
}
