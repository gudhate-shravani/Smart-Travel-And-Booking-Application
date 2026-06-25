// ignore_for_file: use_build_context_synchronously

// lib/screens/package_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package_model.dart';
import 'rating_stars.dart';

class PackageDetailScreen extends StatelessWidget {
  final TourPackage tourPackage;

  final String guideEmail;
  final String packageName;

  const PackageDetailScreen({
    required this.guideEmail,
    required this.packageName,
    super.key, required this.tourPackage,
  });
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    tourPackage.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      shadows: [Shadow(blurRadius: 10)],
                    ),
                  ),
                  background: Image.network(
                    tourPackage.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tourPackage.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      RatingStars(rating: tourPackage.rating, reviewCount: tourPackage.reviewCount, iconSize: 20),
                       const SizedBox(height: 8),
                      Text("from \$${tourPackage.price} per person", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    labelColor: Colors.black87,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: "Overview"),
                      Tab(text: "Itinerary"),
                      Tab(text: "Guides"),
                      Tab(text: "Gallery"),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: const TabBarView(
            children: [
              _OverviewTab(),
              _ItineraryTab(),
              _GuidesTab(),
              _GalleryTab(),
            ],
          ),
        ),
      ),



 bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: ()async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    debugPrint(guideEmail);
    debugPrint(packageName);
    debugPrint(user.email);

   // final guideEmail = guideEmail; // from previous page
   // final packageName = packageName;

    final docRef = FirebaseFirestore.instance
        .collection('Guide')
        .doc(guideEmail)
        .collection('packages')
        .doc(packageName)
        .collection('request')
        .doc(user.email);

    await docRef.set({
      'status': 'pending',
      'userEmail': user.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking request sent successfully')),
    );
  },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: Text('Book package', style: const TextStyle(fontSize: 16)),
        ),
      ),




    );
  }
}

// Delegate for the sticky TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// --- Tab Widgets ---

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text("Package Highlights", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _highlightItem(Icons.check_circle, "Summit hiking"),
          _highlightItem(Icons.check_circle, "Wildlife spotting"),
          _highlightItem(Icons.check_circle, "Camping under stars"),
          _highlightItem(Icons.check_circle, "Professional photography"),
          _highlightItem(Icons.check_circle, "Local cuisine"),
          const Divider(height: 40),
           const Text("What's Included", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _highlightItem(Icons.check_circle_outline, "Professional guides"),
          _highlightItem(Icons.check_circle_outline, "All meals"),
          _highlightItem(Icons.check_circle_outline, "Camping equipment"),
           _highlightItem(Icons.check_circle_outline, "Transportation"),
            _highlightItem(Icons.check_circle_outline, "Photography workshop"),
             _highlightItem(Icons.check_circle_outline, "Safety equipment"),
        ],
      ),
    );
  }
   Widget _highlightItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}

class _ItineraryTab extends StatelessWidget {
  const _ItineraryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Day by Day Itinerary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        _itineraryItem("Day 1", "Arrival & Base Camp Setup", "Meet your guides, gear check, and set up base camp. Evening orientation and welcome dinner."),
        _itineraryItem("Day 2", "Valley Trail Exploration", "Full day hiking through scenic valleys with wildlife photography opportunities and packed lunch."),
        _itineraryItem("Day 3", "Summit Attempt", "Early morning summit hike with panoramic views and professional photo session at the peak."),
        _itineraryItem("Day 4", "Wildlife Safari Day", "Dedicated wildlife spotting and photography with expert naturalist guide."),
        _itineraryItem("Day 5", "Departure", "Morning breakfast, pack up, and transfer back to the city."),
      ],
    );
  }
   Widget _itineraryItem(String day, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$day: $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 5),
          Text(description, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}

class _GuidesTab extends StatelessWidget {
  const _GuidesTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children:  [
        Text("Your Guides", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        _guideTile('https://images.unsplash.com/photo-1580489944761-15a19d654956?w=500&q=80', 'John Martinez', 'Mountain Hiking', 'Experienced guide specializing in mountain hiking tours with extensive local knowledge.'),
        _guideTile('https://images.unsplash.com/photo-1580489944761-15a19d654956?w=500&q=80', 'Emma Davis', 'Wildlife Photography', 'Experienced guide specializing in wildlife photography tours with extensive local knowledge.'),
      ],
    );
  }

  static Widget _guideTile(String imageUrl, String name, String specialty, String desc) {
     return Card(
       margin: const EdgeInsets.only(bottom: 15),
       child: Padding(
         padding: const EdgeInsets.all(12.0),
         child: Row(
           children: [
             CircleAvatar(radius: 30, backgroundImage: NetworkImage(imageUrl)),
             const SizedBox(width: 15),
             Expanded(child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                 Text(specialty, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                 const SizedBox(height: 4),
                 Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
               ],
             ))
           ],
         ),
       ),
     );
  }
}

class _GalleryTab extends StatelessWidget {
  const _GalleryTab();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(8),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: [
        'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=500&q=80',
        'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=500&q=80',
        'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=500&q=80',
        'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=500&q=80',
        'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=500&q=80',
        'https://images.unsplash.com/photo-1458668383970-8ddd3927deed?w=500&q=80'
      ].map((url) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(url, fit: BoxFit.cover),
      )).toList(),
    );
  }
}
