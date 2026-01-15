// lib/translator_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'translator_controller.dart';

class TranslatorScreen extends StatelessWidget {
  const TranslatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TranslatorController controller = Get.put(TranslatorController());
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final iconColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 241, 247), // Light blue
      appBar: AppBar(
        title: const Text('Smart Translator'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: true, // Shows back button if possible
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              _buildLanguageSelectionCard(controller, cardColor, theme),
              const SizedBox(height: 16),
              _buildImageTranslationCard(controller, cardColor, theme, iconColor),
              const SizedBox(height: 16),
              _buildInputTextCard(controller, cardColor, theme),
              const SizedBox(height: 16),
              _buildTranslationResultCard(controller, cardColor, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.translate_rounded,
            color: theme.primaryColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Smart Translator',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Voice • Text • Image Translation',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child, Color? color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }

  Widget _buildLanguageSelectionCard(
      TranslatorController c, Color? cardColor, ThemeData theme) {
    return _buildCard(
      color: cardColor,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _languageDropdown('From', c.sourceLanguage, c, theme),
            IconButton(
              icon: const Icon(Icons.swap_horiz_rounded, size: 28),
              onPressed: c.swapLanguages,
              color: theme.primaryColor,
            ),
            _languageDropdown('To', c.targetLanguage, c, theme),
          ],
        ),
      ),
    );
  }

  Widget _languageDropdown(
      String title, RxString selected, TranslatorController c, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: theme.textTheme.labelMedium?.copyWith(color: Colors.grey)),
        const SizedBox(height: 4),
        DropdownButton<String>(
          value: selected.value,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: c.languages.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              selected.value = value;
            }
          },
        ),
      ],
    );
  }

  Widget _buildImageTranslationCard(
      TranslatorController c, Color? cardColor, ThemeData theme, Color iconColor) {
    return _buildCard(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text('Image Translation', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => c.processImage(ImageSource.gallery),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Upload Image'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: () => c.processImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputTextCard(
      TranslatorController c, Color? cardColor, ThemeData theme) {
    return _buildCard(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.text_fields_rounded, color: Colors.black54, size: 20),
              const SizedBox(width: 8),
              Text('Input Text', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: c.inputTextController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Type, speak, or upload an image to translate...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: c.translateText,
                  icon: Obx(() => c.isTranslating.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.translate_rounded, size: 20)),
                  label: const Text('Translate'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Obx(() => IconButton(
                    onPressed: c.toggleListening,
                    icon: Icon(c.isListening.value ? Icons.mic_off_rounded : Icons.mic_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: c.isListening.value ? theme.primaryColor.withOpacity(0.2) : Colors.grey.shade200,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(14),
                    ),
              )),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTranslationResultCard(
      TranslatorController c, Color? cardColor, ThemeData theme) {
    return _buildCard(
      color: cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.black54, size: 20),
              const SizedBox(width: 8),
              Text('Translation Result', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: c.resultTextController,
              readOnly: true,
              maxLines: null, // Allows multiline
              decoration: const InputDecoration(
                hintText: 'Translation will appear here...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: c.copyToClipboard,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: c.speakResult,
                icon: const Icon(Icons.volume_up_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}