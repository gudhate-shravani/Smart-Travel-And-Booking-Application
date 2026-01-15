import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'all_in_one_ai.dart';
import 'taj_mahal.dart';
import 'package:url_launcher/url_launcher.dart';
import 'explore.dart';
import 'virtual_tour.dart';
import 'all_in_one_ai.dart';

// You might need to add this to your pubspec.yaml for the icons:
// dependencies:
//   flutter:
//     sdk: flutter
//   cupertino_icons: ^1.0.2

class TravelDashboardBody extends StatefulWidget {
  const TravelDashboardBody({super.key});

  @override
  State<TravelDashboardBody> createState() => _TravelDashboardBodyState();
}

class _TravelDashboardBodyState extends State<TravelDashboardBody> {
  // State to toggle between 'Destinations' and 'Social Feed'
  bool _showSocialFeed = false;
    final Set<String> likedPosts = {}; // stores locally liked posts


  @override
  Widget build(BuildContext context) {
    // Using SingleChildScrollView to make the column of content scrollable
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Section (Search Bar + Profile Icon)
            _buildHeader(context),
            const SizedBox(height: 24),

            // 2. AI Trip Assistant Card
            _buildAiTripAssistantCard(),
            const SizedBox(height: 24),

            // 3. Virtual Tours Card
            _buildVirtualToursCard(context),
            const SizedBox(height: 24),

            // 4. Toggle Buttons
            _buildToggleButtons(),
            const SizedBox(height: 24),

            // 5. Conditional Content (Destinations or Social Feed)
            _showSocialFeed ? _buildSocialFeed() : _buildDestinationsSection(),
          ],
        ),
      ),
    );
  }

  // Header Widget
 Widget _buildHeader(BuildContext context) { // Add BuildContext for navigation
  return Row(
    children: [
      Expanded(
        // We replace the TextField with a GestureDetector for navigation
        child: GestureDetector(
          onTap: () {
            // This is the navigation logic that triggers on tap
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const ExploreScreen(),
            ));
          },
          // This Container is styled to look exactly like your original TextField
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8.0),
                Text(
                  'Search destinations...',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      const CircleAvatar(
        // Replace with a user profile image
        backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
        radius: 22,
      ),
    ],
  );
}
  // AI Trip Assistant Card Widget
  Widget _buildAiTripAssistantCard() {
    return GestureDetector(child:  Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF8477E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              const Text(
                'AI Trip Assistant',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Let AI help you plan the perfect trip with personalized recommendations and smart insights.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              _buildFeatureChip('Destination Planning'),
              _buildFeatureChip('Trip Itinerary'),
              _buildFeatureChip('Budget Estimation'),
              _buildFeatureChip('Packing Lists'),
            ],
          )
        ],
      ),
    
    ),onTap: () =>  Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const AIHomeScreen(),
            )),);
  }

  // A small helper for the chips inside the AI card
  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  // Virtual Tours Card Widget
  Widget _buildVirtualToursCard(BuildContext context) {
  return GestureDetector( // <-- 1. WRAPPED WITH GESTUREDETECTOR
    onTap: () {
      // <-- 2. ADDED NAVIGATION LOGIC
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>  TajMahalStreetViewApp(),
      ));
    },
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUBxvaEkIuv5kx2AMZOSzZ2Ce2A_jLjhbhKw&s',
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            // Add loading and error builders for a better user experience
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 150,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
               return Container(
                height: 150,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey, size: 48),
              );
            },
          ),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          // Using a Column with MainAxisSize.min to ensure it doesn't take up the full stack height
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Virtual Tours',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Experience destinations in immersive 360°',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              // This container is just for looks now, the whole card is tappable
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow, color: Colors.black),
                    SizedBox(width: 4),
                    Text(
                      'Start Exploring',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  // Toggle Buttons Widget
  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showSocialFeed = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showSocialFeed ? const Color(0xFF6A5AE0) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'Destinations',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: !_showSocialFeed ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showSocialFeed = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showSocialFeed ? const Color(0xFF6A5AE0) : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    'Social Feed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _showSocialFeed ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section for Popular Destinations
  Widget _buildDestinationsSection() {
    // Dummy data for destinations
    final List<Map<String, String>> destinations = [
      {'name': 'Santorini', 'country': 'Greece', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZochKkqAdu6keIhOkx4T4jwwkhvS2Tx6Xug&s'},
      {'name': 'Swiss Alps', 'country': 'Switzerland', 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=600&q=60'},
      {'name': 'Bali', 'country': 'Indonesia', 'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=600&q=60'},
      {'name': 'Eiffel Tower', 'country': 'Paris', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT_WDQDTfXaCWokNKxd8mLaIw1AacBJYmEuCg&s'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Destinations',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          // Important: to prevent scrolling conflicts inside SingleChildScrollView
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            final dest = destinations[index];
            return _buildDestinationCard(dest['name']!, dest['country']!, dest['image']!,dest['name']!, context);
          },
        )
      ],
    );
  }

  Widget _buildDestinationCard(String name, String country, String imageUrl, String destinationName, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      image: DecorationImage(
        image: NetworkImage(imageUrl),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Stack(
          children: [
            // Destination name and country
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    country,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Navigation icon (bottom-right)
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 28),
                onPressed: () async {
                  try {
                    // Ensure location service is enabled
                    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                    if (!serviceEnabled) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location services are disabled.')),
                      );
                      return;
                    }

                    // Check and request permission
                    LocationPermission permission = await Geolocator.checkPermission();
                    if (permission == LocationPermission.denied) {
                      permission = await Geolocator.requestPermission();
                      if (permission == LocationPermission.denied) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location permission denied.')),
                        );
                        return;
                      }
                    }

                    if (permission == LocationPermission.deniedForever) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location permission permanently denied.')),
                      );
                      return;
                    }

                    // Get user's current position
                    Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );

                    final userLat = position.latitude;
                    final userLng = position.longitude;

                    // Encode the destination name for Google Maps URL
                    final String encodedDestination = Uri.encodeComponent(destinationName);

                    // Construct Google Maps URL
                    final Uri googleMapsUrl = Uri.parse(
                      'https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLng&destination=$encodedDestination&travelmode=driving',
                    );

                    if (await canLaunchUrl(googleMapsUrl)) {
                      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
                    } else {
                      throw 'Could not launch Google Maps';
                    }
                  } catch (e) {
                    debugPrint('Error opening map: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error opening map: $e')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}/*
  // Section for the Social Feed
  Widget _buildSocialFeed() {
    // Dummy data for social feed posts
    final List<Map<String, dynamic>> posts = [
      {
        'user': 'Sarah Johnson',
        'avatar': 'https://i.pravatar.cc/150?img=1',
        'image': 'https://images.unsplash.com/photo-1506929562872-bb421503ef21?auto=format&fit=crop&w=600&q=60',
        'likes': 1248,
        'caption': 'Watching the sunset from the beach. This place never gets old. #Santorini #Greece #Sunset',
      },
      {
        'user': 'Alex Chen',
        'avatar': 'https://i.pravatar.cc/150?img=2',
        'image': 'https://images.unsplash.com/photo-1513407030348-c983a97b98d8?auto=format&fit=crop&w=600&q=60',
        'likes': 892,
        'caption': 'Lost in the vibrant streets of Tokyo! 🏮 #Japan #Tokyo',
      },
    ];

    return ListView.builder(
      // Important: to prevent scrolling conflicts inside SingleChildScrollView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildSocialPostCard(
          user: post['user'],
          avatarUrl: post['avatar'],
          imageUrl: post['image'],
          likes: post['likes'],
          caption: post['caption'],
        );
      },
    );
  }

  Widget _buildSocialPostCard({
    required String user,
    required String avatarUrl,
    required String imageUrl,
    required int likes,
    required String caption,
  }) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
                const SizedBox(width: 12),
                Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),
          Image.network(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border, size: 28),
                    const SizedBox(width: 16),
                    const Icon(Icons.chat_bubble_outline, size: 28),
                    const SizedBox(width: 16),
                    const Icon(Icons.send_outlined, size: 28),
                    const Spacer(),
                    const Icon(Icons.bookmark_border, size: 28),
                  ],
                ),
                const SizedBox(height: 12),
                Text('$likes likes', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: '$user ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: caption),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }*/


Widget _buildSocialFeed() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Traveler').snapshots(),
      builder: (context, travelerSnapshot) {
        if (!travelerSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final travelerDocs = travelerSnapshot.data!.docs;
        if (travelerDocs.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }

        // Get all post subcollections
        final futures = travelerDocs.map((t) => t.reference.collection('post').get()).toList();

        return FutureBuilder<List<QuerySnapshot>>(
          future: Future.wait(futures),
          builder: (context, postsSnapshots) {
            if (!postsSnapshots.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<Map<String, dynamic>> allPosts = [];

            for (int i = 0; i < postsSnapshots.data!.length; i++) {
              final snapshot = postsSnapshots.data![i];
              final travelerId = travelerDocs[i].id;

              for (final doc in snapshot.docs) {
                final data = doc.data() as Map<String, dynamic>? ?? {};

                final postId = '${travelerId}_${doc.id}'; // unique post identifier
                final name = data['name'] ?? 'Unknown';
                final description = data['description'] ?? '';
                final imageurl = data['imageUrl'] ?? '';
                final likes = (data['likes'] is int) ? data['likes'] : 0;
                final location = doc.id; // document ID = location

                allPosts.add({
                  'travelerId': travelerId,
                  'postDocId': doc.id,
                  'postId': postId,
                  'user': name,
                  'avatar': 'https://i.pravatar.cc/150?u=$travelerId',
                  'image': imageurl,
                  'likes': likes,
                  'caption': description,
                  'location': location,
                });
              }
            }

            if (allPosts.isEmpty) {
              return const Center(child: Text('No posts available'));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                final post = allPosts[index];
                return _buildSocialPostCard(
                  travelerId: post['travelerId'],
                  postDocId: post['postDocId'],
                  postId: post['postId'],
                  user: post['user'],
                  avatarUrl: post['avatar'],
                  imageUrl: post['image'],
                  likes: post['likes'],
                  caption: post['caption'],
                  location: post['location'],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSocialPostCard({
    required String travelerId,
    required String postDocId,
    required String postId,
    required String user,
    required String avatarUrl,
    required String imageUrl,
    required int likes,
    required String caption,
    required String location,
  }) {
    final isLiked = likedPosts.contains(postId);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
                const SizedBox(width: 12),
                Text(user, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                const Icon(Icons.more_horiz),
              ],
            ),
          ),
          Image.network(
            imageUrl,
            height: 250,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Toggle local like color immediately
                        setState(() {
                          if (isLiked) {
                            likedPosts.remove(postId);
                          } else {
                            likedPosts.add(postId);
                          }
                        });

                        // Update Firestore likes count safely
                        final postRef = FirebaseFirestore.instance
                            .collection('Traveler')
                            .doc(travelerId)
                            .collection('post')
                            .doc(postDocId);

                        await FirebaseFirestore.instance.runTransaction((tx) async {
                          final snapshot = await tx.get(postRef);
                          if (!snapshot.exists) return;
                          final currentLikes = (snapshot['likes'] is int)
                              ? snapshot['likes'] as int
                              : 0;
                          final newLikes = isLiked
                              ? (currentLikes - 1).clamp(0, 999999)
                              : (currentLikes + 1);
                          tx.update(postRef, {'likes': newLikes});
                        });
                      },
                      child: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 28,
                        color: isLiked ? Colors.red : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.chat_bubble_outline, size: 28),
                    const SizedBox(width: 16),
                    const Icon(Icons.send_outlined, size: 28),
                    const Spacer(),
                    const Icon(Icons.bookmark_border, size: 28),
                  ],
                ),
                const SizedBox(height: 12),
                Text('$likes likes', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: '$user ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: caption),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '📍 $location',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
}