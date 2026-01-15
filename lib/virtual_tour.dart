import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter.blur

// --- DATA MODELS ---

// Represents a single virtual tour.
class VirtualTour {
  final String title;
  final String subtitle;
  final String imageUrl;
  final double rating;
  final String reviews;
  final String duration;
  final int price;
  final List<String> tags;
  final bool isFeatured;

  VirtualTour({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.duration,
    required this.price,
    required this.tags,
    this.isFeatured = false,
  });
}

// --- MAIN SCREEN WIDGET ---

class VirtualToursScreen extends StatefulWidget {
  const VirtualToursScreen({super.key});

  @override
  State<VirtualToursScreen> createState() => _VirtualToursScreenState();
}

class _VirtualToursScreenState extends State<VirtualToursScreen> {
  // --- STATE VARIABLES ---
  int _selectedCategoryIndex = 0;

  // --- MOCK DATA ---
  final List<VirtualTour> _tours = [
    VirtualTour(
      title: 'Ancient Rome: Colosseum',
      subtitle: 'Experience the glory of ancient Rome',
      imageUrl: 'https://picsum.photos/seed/rome/800/600',
      rating: 4.9,
      reviews: '1.2k',
      duration: '45 min',
      price: 199,
      tags: ['Gladiator battles', 'Emperor\'s box', 'Underground chambers'],
      isFeatured: true,
    ),
    VirtualTour(
      title: 'Machu Picchu Sunrise',
      subtitle: 'Witness the breathtaking sunrise over the ancient Inca citadel',
      imageUrl: 'https://picsum.photos/seed/machupicchu/800/600',
      rating: 4.8,
      reviews: '992',
      duration: '30 min',
      price: 249,
      tags: ['Sunrise views', 'Inca architecture', 'Mountain scenery'],
      isFeatured: true,
    ),
    VirtualTour(
      title: 'Tokyo Street Culture',
      subtitle: 'Explore the vibrant streets of Shibuya and modern Japanese culture',
      imageUrl: 'https://picsum.photos/seed/tokyo_street/800/600',
      rating: 4.7,
      reviews: '1.5k',
      duration: '60 min',
      price: 179,
      tags: ['Shibuya Crossing', 'Traditional vs modern', 'Local culture'],
    ),
    VirtualTour(
      title: 'Egyptian Pyramids Mystery',
      subtitle: 'Uncover the secrets of the Great Pyramid with cutting-edge AR',
      imageUrl: 'https://picsum.photos/seed/pyramids/800/600',
      rating: 4.9,
      reviews: '2.1k',
      duration: '75 min',
      price: 299,
      tags: ['Pyramid interior', 'Pharaoh\'s chamber', 'Ancient mysteries'],
    ),
    VirtualTour(
      title: 'Amazon Rainforest Expedition',
      subtitle: 'Journey deep into the world\'s largest tropical rainforest',
      imageUrl: 'https://picsum.photos/seed/amazon/800/600',
      rating: 4.6,
      reviews: '907',
      duration: '90 min',
      price: 229,
      tags: ['Exotic wildlife', 'Canopy walk', 'Survival skills'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final featuredTours = _tours.where((t) => t.isFeatured).toList();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilters(),
            const SizedBox(height: 24),
            _buildFeaturedSection(featuredTours),
            const SizedBox(height: 16),
            _buildAllToursSection(),
          ],
        ),
      ),
    //  bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF4F6FC),
      elevation: 0,
      //leading: const IconButton(icon: Icon(Icons.menu, color: Colors.black87), onPressed: null),
      title: const Text('TravelMate', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://picsum.photos/seed/avatar/100/100'),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Image.network(
            'https://placehold.co/100x100/8E2DE2/FFFFFF?text=VT', 
            height: 80,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.public, size: 80, color: Colors.grey),
          ), // Placeholder icon
          const SizedBox(height: 16),
          const Text('Virtual Tours', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Explore the world from anywhere with immersive experiences',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 20),
          const TextField(
            decoration: InputDecoration(
              hintText: 'Search destinations, cultures, or historical sites...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['Popular', 'Historical', 'Cultural', 'Nature', 'All Tours'];
    final colors = [Colors.red, Colors.orange, Colors.purple, Colors.green, Colors.blue];
    
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.only(left: 16),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryIndex = index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? colors[index] : Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFeaturedSection(List<VirtualTour> tours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Featured Tours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tours.length,
            padding: const EdgeInsets.only(left: 16),
            itemBuilder: (context, index) {
              return _buildFeaturedTourCard(tours[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedTourCard(VirtualTour tour) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(tour.imageUrl, fit: BoxFit.cover),
            Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.black.withOpacity(0.7), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter))),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                        child: const Text('FEATURED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                        child: Text('\$${tour.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(tour.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                       const SizedBox(height: 8),
                       ElevatedButton.icon(
                         onPressed: (){},
                         icon: const Icon(Icons.play_arrow),
                         label: const Text('Start Tour'),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.white.withOpacity(0.3),
                           foregroundColor: Colors.white,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                         ),
                       )
                     ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAllToursSection() {
     return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           const Text('All Virtual Tours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
           const SizedBox(height: 16),
           ListView.separated(
             itemCount: _tours.length,
             shrinkWrap: true,
             physics: const NeverScrollableScrollPhysics(),
             separatorBuilder: (context, index) => const SizedBox(height: 12),
             itemBuilder: (context, index) {
               return _buildTourCard(_tours[index]);
             },
           ),
         ],
       ),
     );
  }
  
  Widget _buildTourCard(VirtualTour tour) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Stack(
            children: [
              Image.network(tour.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(tour.duration, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ),
               Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                  child: Text('\$${tour.price}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tour.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(tour.subtitle, style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(' ${tour.rating} (${tour.reviews} reviews)'),
                    const Spacer(),
                    Icon(Icons.language, color: Colors.grey, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: tour.tags.map((tag) => Chip(
                    label: Text(tag, style: TextStyle(fontSize: 12)),
                    backgroundColor: Colors.grey.shade200,
                  )).toList(),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Tour'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )._withGradient(), // Using gradient extension
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    // This is a placeholder for your actual app's navigation bar
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 1, // Example index
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'People'),
        BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), label: 'Transport'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
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

