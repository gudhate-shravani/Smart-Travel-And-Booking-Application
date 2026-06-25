// lib/models/package_model.dart

class TourPackage {
  final String title;
  final String location;
  final double rating;
  final int reviewCount;
  final int days;
  final String price;
  final String imageUrl;
  final String groupSize;
  final List<String> highlights;
  final String guideEmail; // ✅ Add this line

  TourPackage({
    required this.title,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.days,
    required this.price,
    required this.imageUrl,
    required this.groupSize,
    required this.highlights,
    required this.guideEmail, // ✅ Add this
  });
}
