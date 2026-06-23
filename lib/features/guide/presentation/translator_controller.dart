// lib/translator_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_translator/google_translator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:clipboard/clipboard.dart';
import 'package:translator/translator.dart';

class TranslatorController extends GetxController {
  // Text Editing Controllers
  final inputTextController = TextEditingController();
  final resultTextController = TextEditingController();

  // Language Selection
  final RxString sourceLanguage = 'en'.obs; // English
  final RxString targetLanguage = 'hi'.obs; // Hindi
  final Map<String, String> languages = {
    'en': 'English',
    'hi': 'Hindi',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'ja': 'Japanese',
    'ru': 'Russian',
    'ar': 'Arabic',
  };

  // Functional Dependencies
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final GoogleTranslator _translator = GoogleTranslator(); // Add this

  // State Variables
  final RxBool isTranslating = false.obs;
  final RxBool isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    _speechToText.initialize();
  }

  // --- Core Translation Logic ---
  void translateText() async {
    if (inputTextController.text.isEmpty) return;

    isTranslating.value = true;
    try {
      final translation = await _translator.translate(
        inputTextController.text,
        from: sourceLanguage.value,
        to: targetLanguage.value,
      );
      resultTextController.text = translation.text;
    } catch (e) {
      Get.snackbar('Error', 'Translation failed. Please try again.');
    } finally {
      isTranslating.value = false;
    }
  }

  // --- Image to Text (OCR) ---
  void processImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image == null) return;

      final InputImage inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      
      inputTextController.text = recognizedText.text;
      translateText(); // Automatically translate after extracting text
    } catch (e) {
      Get.snackbar('Error', 'Failed to process image. Please try again.');
    }
  }

  // --- Speech to Text ---
  void toggleListening() {
    if (isListening.value) {
      _speechToText.stop();
      isListening.value = false;
    } else {
      isListening.value = true;
      _speechToText.listen(
        onResult: (result) {
          inputTextController.text = result.recognizedWords;
          if (result.finalResult) {
            isListening.value = false;
            translateText(); // Translate when speech is final
          }
        },
      );
    }
  }

  // --- Text to Speech ---
  void speakResult() async {
    if (resultTextController.text.isNotEmpty) {
      await _flutterTts.setLanguage(targetLanguage.value);
      await _flutterTts.speak(resultTextController.text);
    }
  }

  // --- Utility Functions ---
  void swapLanguages() {
    final temp = sourceLanguage.value;
    sourceLanguage.value = targetLanguage.value;
    targetLanguage.value = temp;
  }

  void copyToClipboard() {
    if (resultTextController.text.isNotEmpty) {
      FlutterClipboard.copy(resultTextController.text).then((_) {
        Get.snackbar('Success', 'Copied to clipboard!',
            snackPosition: SnackPosition.BOTTOM);
      });
    }
  }

  @override
  void onClose() {
    inputTextController.dispose();
    resultTextController.dispose();
    _textRecognizer.close();
    super.onClose();
  }
}