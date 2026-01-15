// lib/screens/guide_model.dart
class Guide {
  final String name;
  final String location;
  final double rating;
  final int reviewCount;
  final String rate;
  final int experience;
  final String about;
  final String imageUrl;
  final List<String> specialties;
  final List<String> languages;
  final String? email;     // added for identifying guide from Firestore
  final String? status;    // added for showing request status (pending/accepted/rejected)

  Guide({
    required this.name,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.rate,
    required this.experience,
    required this.about,
    required this.imageUrl,
    required this.specialties,
    required this.languages,
    this.email,
    this.status,           // optional parameter
  });
}
