// packing_list_screen.dart (FIXED and UPDATED)

import 'package:flutter/material.dart';
import 'data.dart'; 
import 'packing_cateory_card.dart';

class PackingListScreen extends StatefulWidget {
  final String destination;
  final List<PackingCategory> packingList; // <-- NEW: Accept the generated list
  
  const PackingListScreen({
    super.key,
    required this.destination,
    required this.packingList,
  });

  @override
  State<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends State<PackingListScreen> {
  double _overallCompletion = 0.0;
  
  late final int _totalCheckableItems;

  @override
  void initState() {
    super.initState();
    // Calculate total items based on the passed-in list
    _totalCheckableItems = widget.packingList.fold<int>(
      0,
      (sum, category) => sum + category.items.length,
    );
    // Initial calculation for correct display on first load (without setState)
    _calculateOverallCompletion(shouldSetState: false);
  }

  void _calculateOverallCompletion({bool shouldSetState = true}) {
    if (_totalCheckableItems == 0) return;

    // Count the total number of checked items across all categories
    int checkedCount = widget.packingList.fold<int>(
      0,
      (sum, category) => sum + category.items.where((item) => item.isChecked).length,
    );

    final newCompletion = (checkedCount / _totalCheckableItems);

    if (shouldSetState) {
      // Call setState only when triggered by a check/uncheck action
      setState(() {
        _overallCompletion = newCompletion;
      });
    } else {
      // Set the initial value directly during initState
      _overallCompletion = newCompletion;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // ... (AppBar content remains the same)
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Color(0xFF00BCD4)),
                const SizedBox(width: 4),
                Text(
                  'Packing for ${widget.destination.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${(_overallCompletion * 100).toInt()}% Complete',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF673AB7),
                fontWeight: FontWeight.w600,
              ),
            ),
            // Progress Bar
            Container(
              height: 5,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade300,
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _overallCompletion,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Color(0xFF673AB7),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView(
          padding: const EdgeInsets.only(top: 10, bottom: 20),
          // Use the generated packingList
          children: widget.packingList.map((category) {
            return PackingCategoryCard(
              category: category,
              onCheckToggled: () {
                _calculateOverallCompletion(shouldSetState: true);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}