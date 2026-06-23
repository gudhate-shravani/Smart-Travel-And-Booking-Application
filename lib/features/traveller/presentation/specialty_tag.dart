// lib/widgets/specialty_tag.dart
import 'package:flutter/material.dart';

class SpecialtyTag extends StatelessWidget {
  final String label;
  const SpecialtyTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey[700], fontSize: 12),
      ),
    );
  }
}