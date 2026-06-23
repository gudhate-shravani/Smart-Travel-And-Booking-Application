// data.dart - Add the following parsing function

import 'dart:convert';
import 'package:flutter/material.dart'; // Keep the import for IconData

class PackingItem {
  final String name;
  final String? quantity;
  bool isChecked;

  PackingItem(this.name, {this.quantity, this.isChecked = false});
}

class PackingCategory {
  final String name;
  final IconData icon;
  final List<PackingItem> items;

  PackingCategory(this.name, this.icon, this.items);

  // Helper function to map category name to an IconData (for consistent UI)
  static IconData getIconForCategory(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('clothing') || lowerName.contains('apparel')) {
      return Icons.checkroom;
    } else if (lowerName.contains('essentials') || lowerName.contains('docs')) {
      return Icons.inventory_2_outlined;
    } else if (lowerName.contains('electronics') || lowerName.contains('tech')) {
      return Icons.smartphone;
    } else if (lowerName.contains('toiletries') || lowerName.contains('health')) {
      return Icons.sanitizer_outlined;
    } else if (lowerName.contains('adventure') || lowerName.contains('gear')) {
      return Icons.terrain;
    }
    return Icons.category; // Default icon
  }

  // --- NEW STATIC METHOD TO PARSE GEMINI RESPONSE ---
  static List<PackingCategory> fromJsonString(String jsonString) {
    try {
      // 1. Clean the string to ensure it's valid JSON (remove markdown ticks)
      final cleanedString = jsonString
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> jsonList = json.decode(cleanedString);
      
      return jsonList.map((categoryJson) {
        final List<dynamic> itemsJson = categoryJson['items'] ?? [];
        
        // Map items
        final items = itemsJson.map((itemJson) {
          return PackingItem(
            itemJson['name'],
            quantity: itemJson['quantity'],
          );
        }).toList();

        // Create the category
        return PackingCategory(
          categoryJson['category'],
          getIconForCategory(categoryJson['category']),
          items,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error parsing Gemini response to PackingCategory: $e');
      // Return an empty list or a default list on failure
      return []; 
    }
  }
}

// NOTE: You should remove the mockPackingList from data.dart now that we're using the API.
// Or, keep it as a fallback if the API call fails.