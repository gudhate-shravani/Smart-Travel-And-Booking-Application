/*import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter.blur

// --- DATA MODELS ---

// Data model for an item in the "Must Try" grid.
class MustTryItem {
  final String imageUrl;
  final String title;
  final double rating;
  final String price;

  MustTryItem({
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.price,
  });
}

// Data model for an item in the "All Recommendations" list.
class RecommendationItem {
  final String imageUrl;
  final String title;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  RecommendationItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.tags,
  });
}

// --- MAIN SCREEN WIDGET ---

class MustDoScreen extends StatefulWidget {
  const MustDoScreen({super.key});

  @override
  State<MustDoScreen> createState() => _MustDoScreenState();
}

class _MustDoScreenState extends State<MustDoScreen> {
  // --- STATE VARIABLES ---
  
  String _selectedCity = 'Paris';
  int _selectedCategoryIndex = 0;
  
  // --- MOCK DATA ---
  
  final List<MustTryItem> _mustTryItems = [
    MustTryItem(imageUrl: 'https://picsum.photos/seed/liberty/300/200', title: 'Statue of Liberty', rating: 4.8, price: '\$25-35'),
    MustTryItem(imageUrl: 'https://picsum.photos/seed/timesquare/300/200', title: 'Times Square', rating: 4.5, price: 'Free'),
    MustTryItem(imageUrl: 'https://picsum.photos/seed/pizza/300/200', title: 'New York Style Pizza', rating: 4.9, price: '\$3-8'),
    MustTryItem(imageUrl: 'https://picsum.photos/seed/broadway/300/200', title: 'Broadway Show', rating: 4.9, price: '\$50-300'),
  ];
  
  final List<RecommendationItem> _recommendations = [
     RecommendationItem(
      imageUrl: 'https://picsum.photos/seed/attraction1/600/400',
      title: 'Iconic symbol of freedom and democracy',
      description: 'A colossal neoclassical sculpture on Liberty Island in New York Harbor.',
      rating: 4.8,
      reviewCount: 1250,
      tags: ['attractions', 'Must Try'],
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Light beige background
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopCard(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildCategoryFilters(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Must Try', '${_mustTryItems.length} items'),
                  const SizedBox(height: 16),
                  _buildMustTryGrid(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('All Recommendations', '${_recommendations.length} items'),
                  const SizedBox(height: 16),
                  _buildRecommendationsList(),
                ],
              ),
            )
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- WIDGET BUILDER METHODS ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
     
      title: const Text('Must Do & Try', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.filter_list, color: Colors.black87), onPressed: () {}),
      ],
    );
  }

  Widget _buildTopCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF9772D), Color(0xFFF4511E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.white),
              SizedBox(width: 8),
              Text('Exploring Paris', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Text('Discover local favorites and hidden gems', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          _buildCityChips(),
          const SizedBox(height: 8),
          Slider(
            value: 0.6,
            onChanged: (val) {},
            activeColor: Colors.white,
            inactiveColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCityChips() {
    final cities = ['New York', 'Tokyo', 'Paris', 'London'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCity == cities[index];
          return GestureDetector(
            onTap: () => setState(() => _selectedCity = cities[index]),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cities[index],
                style: TextStyle(
                  color: isSelected ? Colors.deepOrange.shade800 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search attractions, restaurants, events...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ['All', 'Attractions', 'Food & Shows', 'Shopping', 'Nightlife'];
    final icons = [Icons.wb_sunny, Icons.account_balance, Icons.theaters, Icons.shopping_bag, Icons.nightlight_round];

    return SizedBox(
      height: 50,
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
                color: isSelected ? Colors.deepOrange.shade400 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(icons[index], color: isSelected ? Colors.white : Colors.grey.shade600),
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

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count,
            style: TextStyle(color: Colors.deepOrange.shade800, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMustTryGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _mustTryItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildMustTryCard(_mustTryItems[index]);
      },
    );
  }

  Widget _buildMustTryCard(MustTryItem item) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.star, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Must Try', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
           Positioned(
            top: 8,
            right: 8,
            child: Icon(Icons.favorite_border, color: Colors.white, size: 20),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${item.rating}', style: const TextStyle(color: Colors.white)),
                    const Spacer(),
                    Text(item.price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecommendationsList() {
    return ListView.separated(
      itemCount: _recommendations.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildRecommendationCard(_recommendations[index]);
      },
    );
  }

  Widget _buildRecommendationCard(RecommendationItem item) {
    return Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
             Stack(
                children: [
                  Image.network(item.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                  Positioned(
                    top: 12, left: 12,
                    child: Row(
                      children: item.tags.map((tag) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                           color: Colors.amber, borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      )).toList(),
                    ),
                  ),
                   Positioned(
                    top: 12, right: 12,
                    child: Row(
                      children: [
                        _buildBlurredIconButton(Icons.favorite_border),
                        const SizedBox(width: 8),
                         _buildBlurredIconButton(Icons.share_outlined),
                        const SizedBox(width: 8),
                         _buildBlurredIconButton(Icons.bookmark_border),
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
                      Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                       Text(item.description, style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                           const Icon(Icons.star, color: Colors.amber, size: 20),
                           Text(' ${item.rating} (${item.reviewCount} reviews)'),
                           const Spacer(),
                           const Icon(Icons.directions_car_outlined),
                           const SizedBox(width: 4),
                           const Text('1.2 km')
                        ],
                      )
                  ],
                ),
             )
          ],
        ),
    );
  }
  
   Widget _buildBlurredIconButton(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(6),
          color: Colors.black.withOpacity(0.3),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.deepPurple,
      unselectedItemColor: Colors.grey.shade500,
      currentIndex: 2, // Set 'Explore' as active for context.
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Trip'),
        BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Social'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Booking'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Transport'),
      ],
    );
  }
}
*/



/*
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async'; // Required for Future.delayed

// --- 1. DATA MODELS ---

// Data model for an item in the "Must Try" grid.
class MustTryItem {
  final String imageUrl;
  final String title;
  final double rating;
  final String price;

  MustTryItem({
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.price,
  });
}

// Data model for an item in the "All Recommendations" list.
class RecommendationItem {
  final String imageUrl;
  final String title;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  RecommendationItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.tags,
  });

  // Helper method to check if the item contains a tag matching the selected category
  bool hasTag(String category) {
    if (category == 'All') return true;
    return tags.any((tag) => tag.toLowerCase().contains(category.toLowerCase()));
  }
}

// --- 2. MOCK API CLIENT (SIMULATING GEMINI & UNSPLASH) ---

// In a real app, this would be your API service class
class MockTravelApiClient {
  // Mock data for different cities/searches
  final Map<String, List<RecommendationItem>> _cityData = {
    'new york': [
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/attraction-liberty/600/400',
        title: 'Statue of Liberty',
        description: 'Iconic symbol of freedom on Liberty Island in New York Harbor.',
        rating: 4.8,
        reviewCount: 1250,
        tags: ['Attractions', 'Must Try'],
      ),
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/attraction-empirestate/600/400',
        title: 'Empire State Building',
        description: 'Famous 102-story Art Deco skyscraper in Midtown Manhattan.',
        rating: 4.7,
        reviewCount: 950,
        tags: ['Attractions'],
      ),
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/food-pizza/600/400',
        title: 'Authentic New York Pizza Slice',
        description: 'A thin-crust pizza sold in wide slices.',
        rating: 4.9,
        reviewCount: 2100,
        tags: ['Food & Shows'],
      ),
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/shopping-soho/600/400',
        title: 'Shopping in SoHo',
        description: 'Trendy boutiques and art galleries in South of Houston Street.',
        rating: 4.5,
        reviewCount: 600,
        tags: ['Shopping'],
      ),
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/nightlife-rooftop/600/400',
        title: 'Manhattan Rooftop Bar',
        description: 'Enjoy cocktails with a stunning skyline view.',
        rating: 4.6,
        reviewCount: 720,
        tags: ['Nightlife'],
      ),
    ],
    'paris': [
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/attraction-eiffel/600/400',
        title: 'Eiffel Tower',
        description: 'Wrought-iron lattice tower on the Champ de Mars.',
        rating: 4.9,
        reviewCount: 3500,
        tags: ['Attractions', 'Must Try'],
      ),
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/food-croissant/600/400',
        title: 'Classic French Croissant',
        description: 'Flaky, buttery viennoiserie pastry.',
        rating: 4.9,
        reviewCount: 1800,
        tags: ['Food & Shows', 'Must Try'],
      ),
    ],
    'tokyo': [
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/attraction-shibuya/600/400',
        title: 'Shibuya Crossing',
        description: 'The world\'s busiest intersection in Tokyo.',
        rating: 4.7,
        reviewCount: 1500,
        tags: ['Attractions', 'Must Try'],
      ),
    ]
  };

  // Mock function to simulate a call to Gemini/Unsplash API
  Future<List<RecommendationItem>> fetchAttractions(String city, String category) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final lowerCity = city.toLowerCase();
    final allItems = _cityData[lowerCity] ?? _cityData['new york']!;

    // Filter by category (case-insensitive and partial match, e.g., 'Food' matches 'Food & Shows')
    final filteredItems = allItems.where((item) {
      if (category == 'All') return true;

      // Special handling for the CategoryFilter text to match the tags
      String tagToMatch = category;
      if (category == 'Food & Shows') tagToMatch = 'food';

      return item.tags.any((tag) => tag.toLowerCase().contains(tagToMatch.toLowerCase()));
    }).toList();

    return filteredItems;
  }
}

// --- 3. MAIN SCREEN WIDGET ---

class MustDoScreen extends StatefulWidget {
  const MustDoScreen({super.key});

  @override
  State<MustDoScreen> createState() => _MustDoScreenState();
}

class _MustDoScreenState extends State<MustDoScreen> {
  // --- STATE VARIABLES ---
  
  String _selectedCity = 'New York'; // Default city to start the search
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final MockTravelApiClient _apiClient = MockTravelApiClient();

  // Future to hold the recommendation data from the API
  late Future<List<RecommendationItem>> _recommendationsFuture;
  
  // --- CONSTANTS ---

  final List<String> _categories = ['All', 'Attractions', 'Food & Shows', 'Shopping', 'Nightlife'];
  final List<IconData> _categoryIcons = [Icons.wb_sunny, Icons.account_balance, Icons.theaters, Icons.shopping_bag, Icons.nightlight_round];

  @override
  void initState() {
    super.initState();
    _searchController.text = _selectedCity;
    _recommendationsFuture = _fetchRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // --- DATA FETCHING LOGIC ---

  Future<List<RecommendationItem>> _fetchRecommendations() async {
    final currentCategory = _categories[_selectedCategoryIndex];
    // In a real app, you would pass the current city name or search query
    return _apiClient.fetchAttractions(_selectedCity, currentCategory);
  }

  void _onCategorySelected(int index) {
    if (_selectedCategoryIndex != index) {
      setState(() {
        _selectedCategoryIndex = index;
        // Re-fetch data on category change
        _recommendationsFuture = _fetchRecommendations(); 
      });
    }
  }

  void _onCitySearch() {
    // Only search if the text has changed
    if (_selectedCity.toLowerCase() != _searchController.text.trim().toLowerCase()) {
      setState(() {
        _selectedCity = _searchController.text.trim();
        _selectedCategoryIndex = 0; // Reset category filter on new search
        // Re-fetch data on new city search
        _recommendationsFuture = _fetchRecommendations(); 
      });
    }
  }
  
  // --- MOCK DATA FOR MUST TRY (Derived from recommendations) ---
  
  // Since 'Must Try' items are a subset of all recommendations, 
  // we'll compute them from the main list in the FutureBuilder.

  // --- WIDGET BUILDER METHODS (Same as original code) ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      
      title: const Text('Must Do & Try', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.filter_list, color: Colors.black87), onPressed: () {}),
      ],
    );
  }

  Widget _buildTopCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF9772D), Color(0xFFF4511E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 8),
              Text('Exploring $_selectedCity', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Text('Discover local favorites and hidden gems', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          _buildCityChips(),
          const SizedBox(height: 8),
          Slider(
            value: 0.6,
            onChanged: (val) {},
            activeColor: Colors.white,
            inactiveColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCityChips() {
    final cities = ['New York', 'Tokyo', 'Paris', 'London'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          final isSelected = _selectedCity == city;
          return GestureDetector(
            onTap: () {
              // Update search bar text and trigger search
              _searchController.text = city; 
              _onCitySearch();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                city,
                style: TextStyle(
                  color: isSelected ? Colors.deepOrange.shade800 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search attractions, restaurants, events...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: _onCitySearch,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onSubmitted: (_) => _onCitySearch(),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepOrange.shade400 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(_categoryIcons[index], color: isSelected ? Colors.white : Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    _categories[index],
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

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count,
            style: TextStyle(color: Colors.deepOrange.shade800, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
  
  // Convert RecommendationItem to MustTryItem (MustTry items are a subset of all)
  MustTryItem _convertToMustTry(RecommendationItem item) {
    // Mock price for Must Try items
    String price = item.tags.contains('Food & Shows') ? '\$5-20' : '\$15-50';
    if (item.title.contains('Pizza')) price = '\$3-8';
    if (item.title.contains('Croissant')) price = '\$2-5';
    if (item.title.contains('Times Square')) price = 'Free';
    
    return MustTryItem(
      imageUrl: item.imageUrl,
      title: item.title,
      rating: item.rating,
      price: price,
    );
  }

  Widget _buildMustTryGrid(List<MustTryItem> mustTryItems) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: mustTryItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildMustTryCard(mustTryItems[index]);
      },
    );
  }

  Widget _buildMustTryCard(MustTryItem item) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Must Try', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
            Positioned(
            top: 8,
            right: 8,
            child: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${item.rating}', style: const TextStyle(color: Colors.white)),
                    const Spacer(),
                    Text(item.price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(List<RecommendationItem> recommendations) {
    return ListView.separated(
      itemCount: recommendations.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildRecommendationCard(recommendations[index]);
      },
    );
  }

  Widget _buildRecommendationCard(RecommendationItem item) {
    return Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
              Stack(
                children: [
                  Image.network(
                    item.imageUrl, 
                    height: 180, 
                    width: double.infinity, 
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 180, 
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey))
                    ),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: Row(
                      children: item.tags.map((tag) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                           color: tag.toLowerCase().contains('must try') ? Colors.red.shade600 : Colors.amber, 
                           borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      )).toList(),
                    ),
                  ),
                    Positioned(
                    top: 12, right: 12,
                    child: Row(
                      children: [
                        _buildBlurredIconButton(Icons.favorite_border),
                        const SizedBox(width: 8),
                        _buildBlurredIconButton(Icons.share_outlined),
                        const SizedBox(width: 8),
                        _buildBlurredIconButton(Icons.bookmark_border),
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
                      Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(item.description, style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(' ${item.rating} (${item.reviewCount} reviews)'),
                          const Spacer(),
                          const Icon(Icons.directions_car_outlined),
                          const SizedBox(width: 4),
                          const Text('1.2 km')
                        ],
                      )
                  ],
                ),
              )
          ],
        ),
    );
  }
  
    Widget _buildBlurredIconButton(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(6),
          color: Colors.black.withOpacity(0.3),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  // NOTE: BottomNavBar is commented out in original build method, providing it here for completeness.
  // Widget _buildBottomNavBar() {
  //   return BottomNavigationBar(
  //     type: BottomNavigationBarType.fixed,
  //     selectedItemColor: Colors.deepPurple,
  //     unselectedItemColor: Colors.grey.shade500,
  //     currentIndex: 2, // Set 'Explore' as active for context.
  //     items: const [
  //       BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Trip'),
  //       BottomNavigationBarItem(icon: Icon(Icons.camera), label: 'Social'),
  //       BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
  //       BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Booking'),
  //       BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Transport'),
  //     ],
  //   );
  // }

  // --- MAIN BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Light beige background
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopCard(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildCategoryFilters(),
                  const SizedBox(height: 24),
                  // --- Dynamic Content based on API/Future ---
                  FutureBuilder<List<RecommendationItem>>(
                    future: _recommendationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show a loading indicator while fetching data
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: Color(0xFFF9772D)),
                        ));
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('Error loading data for $_selectedCity: ${snapshot.error}', style: TextStyle(color: Colors.red)),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('No recommendations found for "$_selectedCity" under the selected category.', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
                        );
                      }

                      final allRecommendations = snapshot.data!;
                      
                      // Filter Must Try items from the main list
                      final mustTryItems = allRecommendations
                          .where((item) => item.tags.any((tag) => tag.toLowerCase() == 'must try'))
                          .map(_convertToMustTry)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MUST TRY SECTION
                          _buildSectionHeader('Must Try', '${mustTryItems.length} items'),
                          const SizedBox(height: 16),
                          mustTryItems.isNotEmpty
                            ? _buildMustTryGrid(mustTryItems)
                            : const Text('No "Must Try" items in this category yet.', style: TextStyle(color: Colors.grey)),
                          
                          const SizedBox(height: 24),

                          // ALL RECOMMENDATIONS SECTION
                          _buildSectionHeader('All Recommendations', '${allRecommendations.length} items'),
                          const SizedBox(height: 16),
                          _buildRecommendationsList(allRecommendations),
                        ],
                      );
                    },
                  ),
                  // --- End Dynamic Content ---
                ],
              ),
            )
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNavBar(), // Uncomment to use
    );
  }
}

// --- APP ENTRY POINT (for testing) ---
 */



import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:async';
// NOTE: You must add the 'http' package to your pubspec.yaml for real API calls
 import 'package:http/http.dart' as http; 
 import 'dart:convert'; // Required for JSON encoding/decoding

// --- 1. DATA MODELS (Unchanged) ---

// Data model for an item in the "Must Try" grid.
class MustTryItem {
  final String imageUrl;
  final String title;
  final double rating;
  final String price;

  MustTryItem({
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.price,
  });
}

// Data model for an item in the "All Recommendations" list.
class RecommendationItem {
  final String imageUrl;
  final String title;
  final String description;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  RecommendationItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.tags,
  });

  bool hasTag(String category) {
    if (category == 'All') return true;
    return tags.any((tag) => tag.toLowerCase().contains(category.toLowerCase()));
  }
}

// --- 2. API CLIENTS (Real Implementation Ready) ---

// =========================================================================
// !!! IMPORTANT: This is where you will enable the real functionality !!!
// =========================================================================

class TravelApiRealClient {
  // 🔑 REPLACE WITH YOUR ACTUAL KEYS AND ENDPOINTS
  static const String _geminiApiKey = 'gemini api key';
  static const String _unsplashAccessKey = 'unsplash api key';
  static const String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_geminiApiKey';
  static const String _unsplashBaseUrl = 'https://api.unsplash.com/search/photos';

  // --- MOCK DATA (Fallback for simulation) ---
  final Map<String, List<RecommendationItem>> _mockData = {
    'new york': [
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/liberty-mock/600/400',
        title: 'Statue of Liberty',
        description: 'Iconic symbol of freedom on Liberty Island in New York Harbor.',
        rating: 4.8,
        reviewCount: 1250,
        tags: ['Attractions', 'Must Try'],
      ),
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/pizza-mock/600/400',
        title: 'Authentic New York Pizza Slice',
        description: 'A thin-crust pizza sold in wide slices.',
        rating: 4.9,
        reviewCount: 2100,
        tags: ['Food & Shows'],
      ),
    ],
    'paris': [
      RecommendationItem(
        imageUrl: 'https://picsum.photos/seed/eiffel-mock/600/400',
        title: 'Eiffel Tower',
        description: 'Wrought-iron lattice tower on the Champ de Mars.',
        rating: 4.9,
        reviewCount: 3500,
        tags: ['Attractions', 'Must Try'],
      ),
    ],
  };

  // 1. --- GEMINI: FETCH ATTRACTION DATA (Real/Mock) ---
  Future<List<RecommendationItem>> fetchAttractionData(String city) async {
    // 
    // !!! ENABLE THIS SECTION FOR REAL GEMINI CALLS !!!
    //
    
    try {
      final prompt = 'As a travel guide, list 5 unique, must-do attractions for $city. For each, provide a title, a short one-sentence description, a rating (4.0-5.0), review count (500-5000), and comma-separated tags (e.g., "Attractions, Must Try, Nightlife"). Format the entire response as a single JSON array, like this: [{"title": "...", "description": "...", "rating": 4.5, "reviewCount": 1000, "tags": "Attractions, Must Try"}].';

      final response = await http.post(
        Uri.parse(_geminiApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {"role": "user", "parts": [{"text": prompt}]}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final geminiText = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        final cleanJson = geminiText.replaceAll(RegExp(r'```json\s*|```'), '').trim();
        final List<dynamic> jsonList = jsonDecode(cleanJson);
        
        // 2. --- UNSPLASH: FETCH IMAGES ---
        List<RecommendationItem> items = [];
        for (var data in jsonList) {
          final imageUrl = await _fetchUnsplashImage(data['title'] as String);
          items.add(RecommendationItem(
            imageUrl: imageUrl,
            title: data['title'] as String,
            description: data['description'] as String,
            rating: data['rating'] as double,
            reviewCount: data['reviewCount'] as int,
            tags: (data['tags'] as String).split(',').map((e) => e.trim()).toList(),
          ));
        }
        return items;
      }
      // If API fails, fall back to mock data
      print('Gemini API failed with status ${response.statusCode}. Falling back to mock data.');
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockData[city.toLowerCase()] ?? [];
    } catch (e) {
      print('Error during real API call: $e. Falling back to mock data.');
      // Fallback to mock data on error
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockData[city.toLowerCase()] ?? [];
    }
    
    
    // --- MOCK SIMULATION (Active by default) ---
    await Future.delayed(const Duration(milliseconds: 1500));
    final lowerCity = city.toLowerCase();
    final items = _mockData[lowerCity] ?? _mockData['new york'] ?? [];
    return items;
  }

  // 2. --- UNSPLASH: FETCH IMAGE URL (Real/Mock) ---
  Future<String> _fetchUnsplashImage(String query) async {
    //
    // !!! ENABLE THIS SECTION FOR REAL UNSPLASH CALLS !!!
    //
    
    try {
      final uri = Uri.parse('$_unsplashBaseUrl?query=$query&client_id=$_unsplashAccessKey&per_page=1');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['results'] != null && jsonResponse['results'].isNotEmpty) {
          return jsonResponse['results'][0]['urls']['regular'] as String;
        }
      }
    } catch (e) {
      print('Unsplash API error: $e');
    }
    
    
    // Fallback/Mock Image
    // Use picsum as a reliable fallback/mock image source
    return 'https://picsum.photos/seed/${query.replaceAll(' ', '-')}/600/400';
  }
}

// --- 3. MAIN SCREEN WIDGET ---

class MustDoScreen extends StatefulWidget {
  const MustDoScreen({super.key});

  @override
  State<MustDoScreen> createState() => _MustDoScreenState();
}

class _MustDoScreenState extends State<MustDoScreen> {
  // --- STATE VARIABLES ---
  
  String _selectedCity = 'New York'; // Default city to start the search
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final TravelApiRealClient _apiClient = TravelApiRealClient(); // Use the new API client

  // Future to hold the recommendation data from the API
  late Future<List<RecommendationItem>> _recommendationsFuture;
  
  // --- CONSTANTS ---

  final List<String> _categories = ['All', 'Attractions', 'Food & Shows', 'Shopping', 'Nightlife'];
  final List<IconData> _categoryIcons = [Icons.wb_sunny, Icons.account_balance, Icons.theaters, Icons.shopping_bag, Icons.nightlight_round];

  @override
  void initState() {
    super.initState();
    _searchController.text = _selectedCity;
    // Initial fetch
    _recommendationsFuture = _fetchRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // --- DATA FETCHING LOGIC ---

  Future<List<RecommendationItem>> _fetchRecommendations() async {
    // 1. Fetch raw data for the current city (uses mock/real API client)
    final rawList = await _apiClient.fetchAttractionData(_selectedCity);

    // 2. Filter the results based on the currently selected category
    final currentCategory = _categories[_selectedCategoryIndex];
    
    // Special mapping to handle category display name vs tag name
    String tagToMatch = currentCategory;
    if (tagToMatch == 'Food & Shows') tagToMatch = 'food';
    
    if (currentCategory == 'All') {
      return rawList;
    } else {
      return rawList.where((item) => 
        item.tags.any((tag) => tag.toLowerCase().contains(tagToMatch.toLowerCase()))
      ).toList();
    }
  }

  void _onCategorySelected(int index) {
    if (_selectedCategoryIndex != index) {
      setState(() {
        _selectedCategoryIndex = index;
        // Re-fetch data on category change (re-uses existing city data)
        // Note: The filtering is handled within _fetchRecommendations now.
        _recommendationsFuture = _fetchRecommendations(); 
      });
    }
  }

  void _onCitySearch() {
    final newCity = _searchController.text.trim();
    if (_selectedCity.toLowerCase() != newCity.toLowerCase() && newCity.isNotEmpty) {
      setState(() {
        _selectedCity = newCity;
        _selectedCategoryIndex = 0; // Reset category filter on new search
        // Re-fetch data for the new city
        _recommendationsFuture = _fetchRecommendations(); 
      });
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    }
  }
  
  // --- WIDGET BUILDER METHODS (Unchanged UI logic) ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      
      title: const Text('Must Do & Try', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(icon: const Icon(Icons.filter_list, color: Colors.black87), onPressed: () {}),
      ],
    );
  }

  Widget _buildTopCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF9772D), Color(0xFFF4511E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white),
              const SizedBox(width: 8),
              Text('Exploring $_selectedCity', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Text('Discover local favorites and hidden gems', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          _buildCityChips(),
          const SizedBox(height: 8),
          Slider(
            value: 0.6,
            onChanged: (val) {},
            activeColor: Colors.white,
            inactiveColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildCityChips() {
    final cities = ['New York', 'Tokyo', 'Paris', 'London'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          final isSelected = _selectedCity.toLowerCase() == city.toLowerCase();
          return GestureDetector(
            onTap: () {
              // Update search bar text and trigger search
              _searchController.text = city; 
              _onCitySearch();
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                city,
                style: TextStyle(
                  color: isSelected ? Colors.deepOrange.shade800 : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search attractions, restaurants, events...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.send),
          onPressed: _onCitySearch,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      onSubmitted: (_) => _onCitySearch(),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => _onCategorySelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.deepOrange.shade400 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(_categoryIcons[index], color: isSelected ? Colors.white : Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    _categories[index],
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

  Widget _buildSectionHeader(String title, String count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 24),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count,
            style: TextStyle(color: Colors.deepOrange.shade800, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
  
  MustTryItem _convertToMustTry(RecommendationItem item) {
    // Mock price for Must Try items based on title
    String price = '\$10-50';
    if (item.title.toLowerCase().contains('pizza')) price = '\$3-8';
    if (item.title.toLowerCase().contains('croissant')) price = '\$2-5';
    if (item.title.toLowerCase().contains('square')) price = 'Free';
    
    return MustTryItem(
      imageUrl: item.imageUrl,
      title: item.title,
      rating: item.rating,
      price: price,
    );
  }

  Widget _buildMustTryGrid(List<MustTryItem> mustTryItems) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: mustTryItems.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildMustTryCard(mustTryItems[index]);
      },
    );
  }

  Widget _buildMustTryCard(MustTryItem item) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => const Center(child: Icon(Icons.error)),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.center,
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.star, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Must Try', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
            Positioned(
            top: 8,
            right: 8,
            child: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(' ${item.rating}', style: const TextStyle(color: Colors.white)),
                    const Spacer(),
                    Text(item.price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(List<RecommendationItem> recommendations) {
    return ListView.separated(
      itemCount: recommendations.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildRecommendationCard(recommendations[index]);
      },
    );
  }

  Widget _buildRecommendationCard(RecommendationItem item) {
    return Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
              Stack(
                children: [
                  Image.network(
                    item.imageUrl, 
                    height: 180, 
                    width: double.infinity, 
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      height: 180, 
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey))
                    ),
                  ),
                  Positioned(
                    top: 12, left: 12,
                    child: Row(
                      children: item.tags.map((tag) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                           color: tag.toLowerCase().contains('must try') ? Colors.red.shade600 : Colors.amber, 
                           borderRadius: BorderRadius.circular(10)
                        ),
                        child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10)),
                      )).toList(),
                    ),
                  ),
                    Positioned(
                    top: 12, right: 12,
                    child: Row(
                      children: [
                        _buildBlurredIconButton(Icons.favorite_border),
                        const SizedBox(width: 8),
                        _buildBlurredIconButton(Icons.share_outlined),
                        const SizedBox(width: 8),
                        _buildBlurredIconButton(Icons.bookmark_border),
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
                      Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(item.description, style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(' ${item.rating} (${item.reviewCount} reviews)'),
                          const Spacer(),
                          const Icon(Icons.directions_car_outlined),
                          const SizedBox(width: 4),
                          const Text('1.2 km')
                        ],
                      )
                  ],
                ),
              )
          ],
        ),
    );
  }
  
    Widget _buildBlurredIconButton(IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(6),
          color: Colors.black.withOpacity(0.3),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }

  // --- MAIN BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Light beige background
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopCard(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 16),
                  _buildCategoryFilters(),
                  const SizedBox(height: 24),
                  // --- Dynamic Content using FutureBuilder ---
                  FutureBuilder<List<RecommendationItem>>(
                    future: _recommendationsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: Color(0xFFF9772D)),
                        ));
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('Error: ${snapshot.error}. Using mock data fallback.', style: TextStyle(color: Colors.red)),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text('No recommendations found for "$_selectedCity" under the selected category.', style: TextStyle(color: Colors.black54, fontStyle: FontStyle.italic)),
                        );
                      }

                      final filteredRecommendations = snapshot.data!;
                      
                      // Filter Must Try items from the filtered list (since it's already category-filtered)
                      final mustTryItems = filteredRecommendations
                          .where((item) => item.tags.any((tag) => tag.toLowerCase() == 'must try'))
                          .map(_convertToMustTry)
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // MUST TRY SECTION
                          _buildSectionHeader('Must Try', '${mustTryItems.length} items'),
                          const SizedBox(height: 16),
                          mustTryItems.isNotEmpty
                            ? _buildMustTryGrid(mustTryItems)
                            : const Text('No "Must Try" items in this category/city yet.', style: TextStyle(color: Colors.grey)),
                          
                          const SizedBox(height: 24),

                          // ALL RECOMMENDATIONS SECTION
                          _buildSectionHeader('All Recommendations', '${filteredRecommendations.length} items'),
                          const SizedBox(height: 16),
                          _buildRecommendationsList(filteredRecommendations),
                        ],
                      );
                    },
                  ),
                  // --- End Dynamic Content ---
                ],
              ),
            )
          ],
        ),
      ),
      // bottomNavigationBar: _buildBottomNavBar(), 
    );
  }
}