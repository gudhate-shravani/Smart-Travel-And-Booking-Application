

import 'dart:ui'; // Required for ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:travelapplication/features/traveller/presentation/budget.dart';
import 'aidestination.dart';
import 'packinngAi.dart';
import 'tripplanerai.dart';

class AIHomeScreen extends StatefulWidget {
  const AIHomeScreen({super.key});

  @override
  State<AIHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<AIHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  final String compassImage =
      'https://images.pexels.com/photos/1083822/pexels-photo-1083822.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';
  final String packingImage =
      'https://images.pexels.com/photos/1111304/pexels-photo-1111304.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';
  final String tripImage =
      'https://images.pexels.com/photos/163064/play-stone-network-network-log-163064.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';
  final String budgetImage =
      'https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1';
  // ------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White background
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), 
                    _buildTopBar(),
                    const SizedBox(height: 30),
                    _buildAvatar(),
                    const SizedBox(height: 20),
                    _buildAskBar(),
                    const SizedBox(height: 30),
                    _buildFeatureCard(
                      title: 'AI Destination Suggestor',
                      subtitle:
                          'Discover your perfect getaway with personalized recommendations',
                      imageUrl: compassImage,
                      icon: Icons.explore,
                      iconColor: Colors.orange,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const StartJourneyScreen(),
                        ));
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureCard(
                      title: 'AI Packing List Generator',
                      subtitle:
                          'Never forget essentials — smart packing for any trip',
                      imageUrl: packingImage,
                      icon: Icons.backpack,
                      iconColor: Colors.redAccent,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const PackMateApp(),
                        ));
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureCard(
                      title: 'AI Trip Planner',
                      subtitle:
                          'Plan your dream trip in minutes with AI-powered itineraries',
                      imageUrl: tripImage,
                      icon: Icons.map,
                      iconColor: Colors.blueAccent,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const TripPlannerApp(),
                        ));
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildFeatureCard(
                      title: 'AI Budget Estimator',
                      subtitle:
                          'Get accurate cost estimates for your next adventure',
                      imageUrl: budgetImage,
                      icon: Icons.attach_money,
                      iconColor: Colors.green,
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const BudgetPlannerApp(),
                        ));
                      },
                    ),
                    const SizedBox(height: 40),
                    const Center(
                      child: Text(
                        'Powered by advanced AI to make your travels smarter',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Your AI Travel Companions',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return const Center(
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.black12,
        child: Icon(Icons.face_retouching_natural,
            size: 50, color: Colors.black54),
      ),
    );
  }

  Widget _buildAskBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ask your AI to help with travel',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // changed to white
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.25),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.black54, size: 40),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor),
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
                      title,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Try Now',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
