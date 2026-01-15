import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class LanguageTranslatorScreen extends StatefulWidget {
  const LanguageTranslatorScreen({super.key});

  @override
  State<LanguageTranslatorScreen> createState() =>
      _LanguageTranslatorScreenState();
}

class _LanguageTranslatorScreenState extends State<LanguageTranslatorScreen> {
  String fromLanguage = "English";
  String toLanguage = "Hindi";
  final TextEditingController textController = TextEditingController();

  final List<Map<String, String>> commonPhrases = [
    {
      "en": "Welcome! How can I help you?",
      "hi": "स्वागत है! मैं आपकी कैसे मदद कर सकता हूं?"
    },
    {
      "en": "This monument was built in...",
      "hi": "यह स्मारक ... में बनाया गया था"
    },
    {
      "en": "Please follow me",
      "hi": "कृपया मेरे पीछे आएं"
    },
  ];

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
          "Language Translator",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Language Selector Card =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _languageDropdown("GB", fromLanguage, true),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F67F8).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.arrow_swap_horizontal,
                        color: Color(0xFF7F67F8), size: 20),
                  ),
                  _languageDropdown("IN", toLanguage, false),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== Source Text Card =====
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Source Text",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Enter text to translate...",
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Iconsax.microphone_2,
                            color: Color(0xFF7F67F8)),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "0/500",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey, letterSpacing: 0.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ===== Translate Button =====
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F67F8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text(
                  "Translate",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ===== Common Phrases =====
            const Text(
              "Common Phrases",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 14),
            Column(
              children: commonPhrases.map((phrase) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phrase["en"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                          color: Color(0xFF7F67F8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        phrase["hi"]!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageDropdown(String flag, String language, bool isFrom) {
    return GestureDetector(
      onTap: () => _showLanguagePicker(isFrom),
      child: Row(
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: Colors.grey.shade200,
            child: Text(flag,
                style: const TextStyle(fontSize: 10, color: Colors.black87)),
          ),
          const SizedBox(width: 8),
          Text(
            language,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.5,
              color: Colors.black87,
            ),
          ),
          const Icon(Iconsax.arrow_down_1, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  void _showLanguagePicker(bool isFrom) {
    final languages = [
      "English",
      "Hindi",
      "Marathi",
      "Spanish",
      "French",
      "German"
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(languages[index]),
          onTap: () {
            setState(() {
              if (isFrom) {
                fromLanguage = languages[index];
              } else {
                toLanguage = languages[index];
              }
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
