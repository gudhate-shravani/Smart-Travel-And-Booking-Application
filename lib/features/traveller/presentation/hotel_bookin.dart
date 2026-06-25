import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter.blur

// A simple data model for a Hotel.
class Hotel {
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final double distance;
  final int price;
  final int originalPrice;
  final List<String> amenities;
  final String? tag; // e.g., 'Special Deal', 'Luxury', 'Budget Pick'
  final Color tagColor;

  Hotel({
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.price,
    required this.originalPrice,
    required this.amenities,
    this.tag,
    this.tagColor = Colors.red,
  });
}

// Main screen widget for Hotel Booking.
class HotelBookingScreen extends StatefulWidget {
  const HotelBookingScreen({super.key});

  @override
  State<HotelBookingScreen> createState() => _HotelBookingScreenState();
}

class _HotelBookingScreenState extends State<HotelBookingScreen> {
  // Mock data that matches the content from the screenshots.
  final List<Hotel> _hotels = [
    Hotel(
      name: 'Grand Central Hotel',
      location: 'Midtown Manhattan',
      imageUrl: 'https://picsum.photos/seed/hotel1/800/600',
      rating: 4.8,
      reviewCount: 1240,
      distance: 0.5,
      price: 299,
      originalPrice: 350,
      amenities: ['Free Wifi', 'Gym', 'Restaurant', 'Room Service'],
      tag: 'Special Deal',
      tagColor: Colors.redAccent,
    ),
    Hotel(
      name: 'Brooklyn Heights Inn',
      location: 'Brooklyn Heights',
      imageUrl: 'https://picsum.photos/seed/hotel2/800/600',
      rating: 4.6,
      reviewCount: 890,
      distance: 2.1,
      price: 189,
      originalPrice: 220,
      amenities: ['Free Wifi', 'Parking', 'Breakfast'],
    ),
     Hotel(
      name: 'Luxury Plaza Suites',
      location: 'Upper East Side',
      imageUrl: 'https://picsum.photos/seed/hotel3/800/600',
      rating: 4.9,
      reviewCount: 1500,
      distance: 1.2,
      price: 450,
      originalPrice: 520,
      amenities: ['Free Wifi', 'Gym', 'Pool', 'Spa'],
      tag: 'Luxury',
      tagColor: Colors.amber.shade800,
    ),
    Hotel(
      name: 'Budget Comfort Lodge',
      location: 'Queens',
      imageUrl: 'https://picsum.photos/seed/hotel4/800/600',
      rating: 4.2,
      reviewCount: 456,
      distance: 8.5,
      price: 89,
      originalPrice: 110,
      amenities: ['Free Wifi', 'Breakfast', 'Parking'],
      tag: 'Budget Pick',
      tagColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchCard(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildResultsHeader(),
                  const SizedBox(height: 16),
                  _buildFilterChips(),
                  const SizedBox(height: 16),
                  _buildHotelList(),
                  const SizedBox(height: 16),
                  _buildLastMinuteDealsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Builds the top AppBar.
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
     
      title: const Text(
        'Hotel Booking',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  // Builds the purple gradient card for searching hotels.
  Widget _buildSearchCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E2DE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          _buildTextField(Icons.location_on_outlined, 'New York, USA'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField(Icons.calendar_today_outlined, 'Check-in')),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(Icons.calendar_today_outlined, 'Check-out')),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(Icons.person_outline, '2 Adults'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.search),
            label: const Text('Search Hotels'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.deepPurple, backgroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper to build the text fields in the search card.
  Widget _buildTextField(IconData icon, String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
        prefixIcon: Icon(icon, color: Colors.white, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
  
  // Builds the header row above the hotel list.
  Widget _buildResultsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_hotels.length} Hotels Found',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            const Text('All Prices', style: TextStyle(color: Colors.grey)),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        )
      ],
    );
  }

  // Builds the horizontal list of filter chips.
  Widget _buildFilterChips() {
    final filters = ['Free Wifi', 'Free Parking', 'Breakfast'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(filters[index]),
              avatar: Icon(_getIconForFilter(filters[index]), size: 18),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForFilter(String filter) {
    switch (filter) {
      case 'Free Wifi': return Icons.wifi;
      case 'Free Parking': return Icons.local_parking;
      case 'Breakfast': return Icons.free_breakfast;
      default: return Icons.help_outline;
    }
  }

  // Builds the main list of hotel cards.
  Widget _buildHotelList() {
    return ListView.separated(
      itemCount: _hotels.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildHotelCard(_hotels[index]);
      },
    );
  }
  
  // Builds a single card for a hotel.
  Widget _buildHotelCard(Hotel hotel) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(
                hotel.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error)),
              ),
              if (hotel.tag != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: hotel.tagColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      hotel.tag!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
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
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${hotel.rating} (${hotel.reviewCount} reviews)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${hotel.distance} km from center'),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: hotel.amenities.map((amenity) => _buildAmenityChip(amenity)).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                             Text(
                              '\$${hotel.price}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${hotel.originalPrice}',
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hotel.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                         Text(
                          hotel.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1), // Dark blue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Book Now'),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  
  // Helper to build icon buttons with blurred background on the image.
  Widget _buildIconButton(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black.withValues(alpha: 0.3),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  // Helper to build a single amenity chip.
  Widget _buildAmenityChip(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconForFilter(amenity), size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 4),
          Text(amenity, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
        ],
      ),
    );
  }
  
  // Builds the green gradient card for last-minute deals.
  Widget _buildLastMinuteDealsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF00BFA5), Color(0xFF00796B)],
           begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Book Last-Minute Deals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
           Text(
            'Save up to 40% on hotels available tonight',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.teal.shade900, backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('View Tonight\'s Deals'),
          )
        ],
      ),
    );
  }
}