
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'guide_model.dart';
import 'package_model.dart';
import 'guide_card.dart';
import 'package_card.dart';

class HomeScreen extends StatefulWidget {
   const HomeScreen({super.key});
  // String guideEmail = '';
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showGuides = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
   
  List<Guide> guides = [];
  List<Guide> requestedGuides = [];
  List<TourPackage> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    try {
      await _fetchGuides();
      await _fetchPackages();
    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchGuides() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final guidesSnap = await _firestore.collection('Guide').get();

    List<Guide> available = [];
    List<Guide> requested = [];

    for (var doc in guidesSnap.docs) {
      final data = doc.data();
      final guideEmail = doc.id;
     


      final guide = Guide(
        name: data['fullName'] ?? 'Unknown Guide',
        location: data['location'] ?? 'Location not available',
        rating: (data['rating'] ?? 4.5).toDouble(),
        reviewCount: data['reviewCount'] ?? 10,
        rate: data['rate'] ?? '\$80',
        experience: data['experience'] ?? 5,
        about: data['bio'] ??
            'Passionate guide with great knowledge about the local area.',
        imageUrl: data['imageUrl'] ??
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&q=80',
        specialties: List<String>.from(data['specialties'] ?? [
          'City Tours',
          'Cultural Experience',
          'Adventure Trails'
        ]),
        languages: List<String>.from(data['languages'] ?? ['English']),
        email: guideEmail,
      );

      // Check if this guide has a request by current user
      final requestDoc = await _firestore
          .collection('Guide')
          .doc(guideEmail)
          .collection('request')
          .doc(user.email)
          .get();

      if (requestDoc.exists) {
        final status = requestDoc.data()?['status'] ?? 'pending';
        requested.add(Guide(
          name: guide.name,
          location: guide.location,
          rating: guide.rating,
          reviewCount: guide.reviewCount,
          rate: guide.rate,
          experience: guide.experience,
          about: guide.about,
          imageUrl: guide.imageUrl,
          specialties: guide.specialties,
          languages: guide.languages,
          email: guide.email,
          status: status, // Custom field for showing request status
        ));
      } else {
        available.add(guide);
      }
    }

    setState(() {
      guides = available;
      requestedGuides = requested;
    });
  }

  Future<void> _fetchPackages() async {
    List<TourPackage> fetchedPackages = [];
    final guidesSnap = await _firestore.collection('Guide').get();

    for (var guideDoc in guidesSnap.docs) {
      final packagesSnap = await _firestore
          .collection('Guide')
          .doc(guideDoc.id)
          .collection('packages')
          .get();

      for (var pkgDoc in packagesSnap.docs) {
        final data = pkgDoc.data();
        final title = data['title'] ?? 'Unknown Adventure';

        // Fetch Unsplash image
        final imageUrl = await _fetchUnsplashImage(title);

       final package = TourPackage(
  title: title,
  location: data['location'] ?? 'Unknown Location',
  rating: (data['rating'] ?? 4.5).toDouble(),
  reviewCount: data['reviewCount'] ?? 10,
  days: data['days'] ?? 3,
  price: data['price'] ?? '499',
  imageUrl: imageUrl,
  groupSize: data['groupSize'] ?? '5-10',
  highlights: List<String>.from(
      data['highlights'] ?? ['Sightseeing', 'Local Cuisine', 'Nature']),
  guideEmail: guideDoc.id, // âœ… store the guideâ€™s email
);




        fetchedPackages.add(package);
      }
    }

    setState(() => packages = fetchedPackages);
  }

  Future<String> _fetchUnsplashImage(String query) async {
    try {
      final url =
          'https://api.unsplash.com/search/photos?query=$query&client_id=YOUR_UNSPLASH_ACCESS_KEY&per_page=1';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'].isNotEmpty) {
          return data['results'][0]['urls']['regular'];
        }
      }
    } catch (e) {
      debugPrint("Error fetching Unsplash image: $e");
    }
    return 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&q=80';
  }

  Future<void> _bookGuide(Guide guide) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final travelerDoc =
        await _firestore.collection('Traveler').doc(user.email).get();
    final userFullName = travelerDoc.data()?['fullName'] ?? 'Traveler User';

    await _firestore
        .collection('Guide')
        .doc(guide.email)
        .collection('request')
        .doc(user.email)
        .set({
      'status': 'pending',
      'fullName': userFullName,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking request sent to ${guide.name}')),
    );

    await _fetchGuides();
  }
  Widget _buildPackagesList() {
  return ListView.builder(
    itemCount: packages.length,
    itemBuilder: (context, index) {
      final TourPackage package = packages[index]; // âœ… Define it here
      return PackageCard(
        guideEmail: package.guideEmail, // âœ… Use the stored guide email
        tourPackage: package,           // âœ… Pass the package object
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search guides, locations, or specialties...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 20),
          // Toggle Buttons
          _buildToggleButtons(),
          const SizedBox(height: 10),
          // Content List
          Expanded(
            child: _showGuides ? _buildGuidesList() : _buildPackagesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showGuides = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showGuides ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _showGuides
                      ? [BoxShadow(color: Colors.grey.withValues(alpha:0.3), spreadRadius: 1, blurRadius: 5)]
                      : [],
                ),
                child: const Center(child: Text('Guides', style: TextStyle(fontWeight: FontWeight.bold))),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showGuides = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showGuides ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                   boxShadow: !_showGuides
                      ? [BoxShadow(color: Colors.grey.withValues(alpha:0.3), spreadRadius: 1, blurRadius: 5)]
                      : [],
                ),
                child: const Center(child: Text('Packages', style: TextStyle(fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidesList() {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Available Guides", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...guides.map((guide) {
          return GuideCard(
            guide: guide,
            onBookNow: () => _bookGuide(guide),
          );
        }),
        if (requestedGuides.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Requested Guides", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...requestedGuides.map((guide) {
            return GuideCard(
              guide: guide,
              showStatusInsteadOfButton: true,
            );
          }),
        ],
      ],
    );
  }

 
}
