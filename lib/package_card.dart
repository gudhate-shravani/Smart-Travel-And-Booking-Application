// lib/widgets/package_card.dart
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package_model.dart';
import 'package_detail_screen.dart';
import 'rating_stars.dart';
import 'guide_home.dart'as HomeScreen;

class PackageCard extends StatelessWidget {
  final TourPackage tourPackage;
  final String guideEmail;

  const PackageCard({super.key, required this.tourPackage, required this.guideEmail});
  

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PackageDetailScreen(guideEmail:guideEmail ,packageName:tourPackage.title , tourPackage: tourPackage)),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  tourPackage.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text('${tourPackage.days} Days'),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tourPackage.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(tourPackage.location, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  RatingStars(rating: tourPackage.rating, reviewCount: tourPackage.reviewCount),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.group, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Text('Group size: ${tourPackage.groupSize} people'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'From: \$${tourPackage.price}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                           Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PackageDetailScreen(guideEmail:guideEmail ,packageName: tourPackage.title, tourPackage: tourPackage)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('View More Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}