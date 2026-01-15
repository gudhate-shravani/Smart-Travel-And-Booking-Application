// lib/widgets/guide_card.dart
/*
import 'package:flutter/material.dart';
import 'guide_model.dart';
import 'guide_detail_screen.dart';
import 'specialty_tag.dart';
import 'rating_stars.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;
  const GuideCard({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuideDetailScreen(guide: guide),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(guide.imageUrl),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(guide.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(guide.location, style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 4),
                        RatingStars(rating: guide.rating, reviewCount: guide.reviewCount),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                guide.about,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: guide.specialties.take(3).map((s) => SpecialtyTag(label: s)).toList(),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Experience: ${guide.experience} Years'),
                  Text(
                    '${guide.rate}/hour',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}*/


// lib/screens/guide_card.dart
import 'package:flutter/material.dart';
import 'guide_model.dart';

class GuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback? onBookNow; // ✅ Added optional callback
  final bool showStatusInsteadOfButton; // ✅ Added to handle Requested Guides

  const GuideCard({
    super.key,
    required this.guide,
    this.onBookNow, // ✅ new
    this.showStatusInsteadOfButton = false, // ✅ default false
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Guide Image & Name ---
            Row(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(guide.imageUrl),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(guide.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(guide.location,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${guide.rating} (${guide.reviewCount} reviews)'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // --- About Section ---
            Text(
              guide.about,
              style: const TextStyle(color: Colors.black87),
            ),
            const SizedBox(height: 10),

            // --- Languages & Specialties ---
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ...guide.languages
                    .map((lang) => _buildTag(lang, Colors.blueAccent)),
                ...guide.specialties
                    .map((spec) => _buildTag(spec, Colors.green)),
              ],
            ),
            const SizedBox(height: 12),

            // --- Rate + Button or Status ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rate: ${guide.rate}/day',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),

                // ✅ Conditionally show button or status
                showStatusInsteadOfButton
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: guide.status == 'accepted'
                              ? Colors.green
                              : guide.status == 'rejected'
                                  ? Colors.red
                                  : Colors.orange,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          guide.status?.toUpperCase() ?? 'PENDING',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onBookNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Book Guide'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12),
      ),
    );
  }
}
