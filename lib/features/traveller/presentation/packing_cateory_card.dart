// packing_category_card.dart

import 'package:flutter/material.dart';
import 'data.dart';

class PackingCategoryCard extends StatefulWidget {
  final PackingCategory category;
  // Rename to be explicit about when it's called
  final VoidCallback onCheckToggled; // Change type to VoidCallback

  const PackingCategoryCard({
    super.key,
    required this.category,
    required this.onCheckToggled, // Update parameter name
  });

  @override
  State<PackingCategoryCard> createState() => _PackingCategoryCardState();
}

class _PackingCategoryCardState extends State<PackingCategoryCard> {


  void _toggleItem(PackingItem item) {
    setState(() {
      item.isChecked = !item.isChecked;
    });
    // Immediately notify the parent *after* local state is updated
    widget.onCheckToggled();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Category Header code remains the same)
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFE0F7FA),
                  child: Icon(widget.category.icon, color: Color(0xFF00BCD4)),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.category.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // List of Items
            ...widget.category.items.map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 0,
                title: Text(
                  item.name + (item.quantity != null ? ' ${item.quantity}' : ''),
                  style: TextStyle(
                    fontSize: 16,
                    decoration: item.isChecked ? TextDecoration.lineThrough : null,
                    color: item.isChecked ? Colors.black54 : Colors.black87,
                  ),
                ),
                leading: Checkbox(
                  value: item.isChecked,
                  onChanged: (bool? newValue) {
                    _toggleItem(item); // Use the new toggle method
                  },
                  activeColor: Color(0xFF673AB7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                onTap: () {
                  _toggleItem(item); // Use the new toggle method
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}