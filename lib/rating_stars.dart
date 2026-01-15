// lib/widgets/rating_stars.dart
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double iconSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.iconSize = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: iconSize),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: iconSize - 2),
        ),
        if (reviewCount > 0)
          Text(
            ' ($reviewCount reviews)',
            style: TextStyle(color: Colors.grey, fontSize: iconSize - 4),
          ),
      ],
    );
  }
}