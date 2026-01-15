/*import 'package:flutter/material.dart';

// --- DATA MODELS ---

// Represents a destination shown in the explore list.
class Destination {
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final double distance;
  final List<String> tags;
  final int price;
  final int durationDays;

  Destination({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    required this.tags,
    required this.price,
    required this.durationDays,
  });
}

// --- MAIN SCREEN WIDGET ---

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  // --- STATE VARIABLES ---
  int _selectedCategoryIndex = 1; // "Beaches" is initially selected
  bool _isGridView = false;

  // --- MOCK DATA ---
  final List<Destination> _destinations = [
    Destination(
      name: 'Bali, Indonesia',
      description: 'Tropical paradise with stunning beaches and rich culture',
      imageUrl: 'https://picsum.photos/seed/bali_beach/800/600',
      rating: 4.8,
      distance: 2.5,
      tags: ['Beaches', 'Temples', 'Culture'],
      price: 1200,
      durationDays: 7,
    ),
    Destination(
      name: 'Swiss Alps, Switzerland',
      description: 'Breathtaking alpine scenery and world-class skiing',
      imageUrl: 'https://picsum.photos/seed/alps/800/600',
      rating: 4.9,
      distance: 1.8,
      tags: ['Skiing', 'Hiking', 'Views'],
      price: 2800,
      durationDays: 10,
    ),
     Destination(
      name: 'Tokyo, Japan',
      description: 'Modern metropolis blending tradition and innovation',
      imageUrl: 'https://picsum.photos/seed/tokyo/800/600',
      rating: 4.7,
      distance: 0.5,
      tags: ['Culture', 'Food', 'Tech'],
      price: 1800,
      durationDays: 5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildCategoryFilters(),
          const SizedBox(height: 20),
          _buildResultsHeader(),
          const SizedBox(height: 16),
          _buildDestinationsList(),
        ],
      ),
     // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      
      title: const Text('Explore', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
        IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87), onPressed: () {}),
      ],
    );
  }
  
  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search destinations by name or photo',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Icon(Icons.filter_list, color: Colors.grey.shade600),
            const SizedBox(width: 12),
          ],
        )
      ),
    );
  }
  
  Widget _buildCategoryFilters() {
    final categories = ['All', 'Beaches', 'Mountains', 'Cities', 'Cultural'];
    final icons = [Icons.grid_view_rounded, Icons.beach_access, Icons.terrain, Icons.location_city, Icons.camera_alt];
    
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E2A3B) : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Icon(icons[index], color: isSelected ? Colors.white : Colors.grey.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_destinations.length} destinations found',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _isGridView = true),
                icon: Icon(Icons.grid_view, color: _isGridView ? Colors.blue.shade700 : Colors.grey),
              ),
              IconButton(
                onPressed: () => setState(() => _isGridView = false),
                icon: Icon(Icons.view_list, color: !_isGridView ? Colors.blue.shade700 : Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildDestinationsList() {
    // This is a placeholder. For a real app, you would filter the list.
    // In a real app with grid view, you would use GridView.builder here.
    return ListView.separated(
      itemCount: _destinations.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildDestinationCard(_destinations[index]);
      },
    );
  }

  Widget _buildDestinationCard(Destination dest) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                dest.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error)),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _buildInfoChip(
                  '★ ${dest.rating}',
                  Colors.green.withOpacity(0.8),
                ),
              ),
               Positioned(
                bottom: 12,
                left: 12,
                child: _buildInfoChip(
                  '${dest.distance}km',
                  Colors.blue.withOpacity(0.8),
                  icon: Icons.send,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  children: [
                    _buildIconButton(Icons.favorite_border),
                    const SizedBox(width: 8),
                    _buildIconButton(Icons.share_outlined),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dest.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(dest.description, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: dest.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Colors.grey.shade200,
                  )).toList(),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Text('\$${dest.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 4),
                    Text('${dest.durationDays} days', style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('explore more'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent, // Handled by gradient container
                        ),
                      )._withGradient(), // Custom extension method for gradient
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_today_outlined),
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, color: Colors.white, size: 14), const SizedBox(width: 4)],
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
  
  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: () {},
      ),
    );
  }
  
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue.shade700,
      unselectedItemColor: Colors.grey.shade500,
      currentIndex: 2, // Set 'Explore' as active
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Trip'),
        BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Social'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Transport'),
      ],
    );
  }
}

// Custom extension method to apply a gradient to a widget.
extension GradientExtension on Widget {
  Widget _withGradient() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E2DE2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: this,
    );
  }
}
*/


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

// --- DATA MODEL ---
class Destination {
  final String name;
  final String description;
  final String imageUrl;
  final double rating;
  final double distance;

  Destination({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rating,
    required this.distance,
  });
}

// --- MAIN SCREEN ---
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<Destination> _destinations = [];
  int _selectedCategoryIndex = 0;
  bool _isGridView = false;

  // --- Replace with your Unsplash Access Key ---
  static const String unsplashAccessKey = 'a4WGz3AndhdDhQzZL0TBeKdTTAfUwgh1M2_vLp85iPw';

  // --- Get current user location ---
  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // --- Search destination using Unsplash API ---
  Future<void> _searchDestinations(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
          'https://api.unsplash.com/search/photos?query=$query&per_page=10&client_id=$unsplashAccessKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List results = data['results'];

        _destinations = results.map((item) {
          return Destination(
            name: query,
            description: 'Explore the beautiful sights of $query',
            imageUrl: item['urls']['regular'],
            rating: (4.5 + (item['likes'] % 10) / 10),
            distance: (2.0 + (item['likes'] % 100) / 10),
          );
        }).toList();
      } else {
        _destinations = [];
      }
    } catch (e) {
      debugPrint('Error fetching Unsplash data: $e');
    }

    setState(() => _isLoading = false);
  }

  // --- Open Google Maps Navigation ---
  Future<void> _openGoogleMaps(String placeName) async {
    try {
      final Position position = await _getCurrentLocation();
      final String origin = '${position.latitude},${position.longitude}';
      final String destination = Uri.encodeComponent(placeName);
      final String googleMapsUrl =
          'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';
      final Uri url = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open Google Maps.';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening maps: $e')),
      );
    }
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildCategoryFilters(),
          const SizedBox(height: 20),
          _buildResultsHeader(),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildDestinationsList(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text('Explore',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {}),
        IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black87),
            onPressed: () {}),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onSubmitted: _searchDestinations,
      decoration: InputDecoration(
        hintText: 'Search any place...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send, color: Colors.black54),
          onPressed: () => _searchDestinations(_searchController.text),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['All', 'Beaches', 'Mountains', 'Cities', 'Cultural'];
    final icons = [
      Icons.grid_view_rounded,
      Icons.beach_access,
      Icons.terrain,
      Icons.location_city,
      Icons.camera_alt
    ];

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E2A3B) : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Icon(icons[index],
                      color:
                          isSelected ? Colors.white : Colors.grey.shade700,
                      size: 20),
                  const SizedBox(width: 8),
                  Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_destinations.length} destinations found',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _isGridView = true),
                icon: Icon(Icons.grid_view,
                    color: _isGridView
                        ? Colors.blue.shade700
                        : Colors.grey),
              ),
              IconButton(
                onPressed: () => setState(() => _isGridView = false),
                icon: Icon(Icons.view_list,
                    color: !_isGridView
                        ? Colors.blue.shade700
                        : Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationsList() {
    if (_destinations.isEmpty) {
      return const Center(
          child: Text('Search for any place to explore attractions!',
              style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      itemCount: _destinations.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildDestinationCard(_destinations[index]);
      },
    );
  }

  Widget _buildDestinationCard(Destination dest) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                dest.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) =>
                    const Center(child: Icon(Icons.error)),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _buildInfoChip(
                  '★ ${dest.rating.toStringAsFixed(1)}',
                  Colors.green.withOpacity(0.8),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: _buildInfoChip(
                  '${dest.distance.toStringAsFixed(1)} km',
                  Colors.blue.withOpacity(0.8),
                  icon: Icons.send,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dest.name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(dest.description,
                    style: TextStyle(color: Colors.grey.shade600)),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openGoogleMaps(dest.name),
                        icon: const Icon(Icons.navigation_outlined),
                        label: const Text('Navigate'),
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.transparent,
                        ),
                      )._withGradient(),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (icon != null)
            ...[Icon(icon, color: Colors.white, size: 14), const SizedBox(width: 4)],
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

// --- GRADIENT EXTENSION ---
extension GradientExtension on Widget {
  Widget _withGradient() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E2DE2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: this,
    );
  }
}
