

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

// --- DATA MODELS ---

// The model now includes a category for filtering.
class TravelPackage {
  final String title;
  final String location;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String duration;
  final int price;
  final int originalPrice;
  final String difficulty;
  final String groupSize;
  final String date;
  final bool isFeatured;
  final String link;
  final String category; // Added category field

  TravelPackage({
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.duration,
    required this.price,
    required this.originalPrice,
    this.difficulty = 'Easy',
    this.groupSize = '',
    this.date = '',
    this.isFeatured = false,
    required this.link,
    required this.category, // Required in constructor
  });

  // Factory constructor to create a package dynamically from the API response
  factory TravelPackage.fromApi(Map<String, dynamic> data, int index) {
    // Generate semi-random, but consistent-looking travel data from the API response
    final name = data['name'] ?? 'Unknown Destination';
    final city = data['address']['city'] ?? 'Earth';
    final company = data['company']['name'] ?? 'Global Tours';
    final link = 'https://${data['website']}';
    
    final random = Random(index); // Use index as seed for consistent randomness
    final price = 1500 + random.nextInt(2000); // 1500 to 3499
    final originalPrice = price + random.nextInt(500) + 100;
    final rating = 4.0 + random.nextDouble() * 0.9;
    final reviewCount = 500 + random.nextInt(2000);
    final isFeatured = index % 3 == 0;
    
    // --- Dynamic Category Assignment ---
    const categories = ['Cultural', 'Adventure', 'Relax'];
    final category = categories[random.nextInt(categories.length)];

    return TravelPackage(
      title: '$name\'s ${company.split(' ').first} Retreat',
      location: '$city, ${data['address']['zipcode'].substring(0, 2)}XX',
      imageUrl: 'https://picsum.photos/seed/${data['id'] * 100}/800/600',
      rating: double.parse(rating.toStringAsFixed(1)),
      reviewCount: reviewCount,
      duration: '${5 + random.nextInt(10)} Days, ${4 + random.nextInt(10)} Nights',
      price: price,
      originalPrice: originalPrice,
      difficulty: random.nextBool() ? 'Easy' : 'Medium',
      groupSize: '${4 + random.nextInt(10)}-${15 + random.nextInt(10)} people',
      date: 'Dec ${1 + random.nextInt(20)}, 2024',
      isFeatured: isFeatured,
      link: link,
      category: category,
    );
  }
}

// --- MAIN SCREEN WIDGET ---

class TravelPackagesScreen extends StatefulWidget {
  const TravelPackagesScreen({super.key});

  @override
  State<TravelPackagesScreen> createState() => _TravelPackagesScreenState();
}

class _TravelPackagesScreenState extends State<TravelPackagesScreen> {
  // --- STATE AND DATA ---
  List<TravelPackage> _allPackages = []; // Holds the full list fetched from API
  List<TravelPackage> _filteredPackages = []; // Holds the list displayed on screen
  bool _isLoading = true; 
  String? _error;
  
  // Define categories used in the UI and for filtering
  final List<String> _categories = ['All Packages', 'Cultural', 'Adventure', 'Relax'];
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // We fetch ALL packages once, then filter locally
    _fetchAllPackages(); 
  }

  // --- ASYNC DATA FETCHING FROM EXTERNAL API ---

  // New method to fetch ALL packages from the API
  Future<void> _fetchAllPackages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      const apiUrl = 'https://jsonplaceholder.typicode.com/users'; 
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        
        final List<TravelPackage> fetchedPackages = jsonResponse
            .asMap()
            .entries
            .map((entry) => TravelPackage.fromApi(entry.value, entry.key))
            .toList();

        setState(() {
          _allPackages = fetchedPackages;
          _isLoading = false;
          // After fetching, apply the initial filter (which is 'All Packages')
          _applyCategoryFilter(_selectedCategoryIndex); 
        });
      } else {
        setState(() {
          _error = 'Failed to load packages. Status code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'An error occurred while fetching data: $e';
        _isLoading = false;
      });
    }
  }
  
  // --- FILTERING LOGIC ---

  void _applyCategoryFilter(int index) {
    // 1. Update the index
    _selectedCategoryIndex = index;
    final selectedCategory = _categories[index];
    
    // 2. Filter the master list (_allPackages)
    if (selectedCategory == 'All Packages') {
      _filteredPackages = _allPackages;
    } else {
      _filteredPackages = _allPackages
          .where((p) => p.category == selectedCategory)
          .toList();
    }
    
    // 3. Trigger a UI rebuild
    setState(() {});
  }

  // --- EXTERNAL NAVIGATION (Unchanged) ---

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch ${uri.host}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final featuredPackages = _filteredPackages.where((p) => p.isFeatured).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _buildBody(featuredPackages),
    );
  }
  
  // Conditionally render the body based on state (Unchanged)
  Widget _buildBody(List<TravelPackage> featuredPackages) {
      if (_isLoading) {
        return const Center(child: CircularProgressIndicator(color: Color(0xFFE91E63)));
      }

      if (_error != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 40, color: Colors.grey),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _fetchAllPackages,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                )
              ],
            ),
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildCategoryFilters(),
            const SizedBox(height: 24),
            // Only show featured section if there are featured packages
            if (featuredPackages.isNotEmpty) ...[
              _buildSectionHeader('Featured Packages'),
              const SizedBox(height: 16),
              _buildFeaturedPackagesList(featuredPackages),
              const SizedBox(height: 24),
            ],
            _buildSectionHeader('All Packages', count: _filteredPackages.length),
            const SizedBox(height: 16),
            _buildAllPackagesList(),
          ],
        ),
      );
  }
  
  // --- WIDGET BUILDER METHODS (Updated _buildCategoryFilters) ---

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text('Travel Packages',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
            icon: const Icon(Icons.redeem, color: Colors.black87),
            onPressed: () {}),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFF9772D), Color(0xFFE91E63)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.airplanemode_active, color: Colors.white, size: 32),
          SizedBox(height: 12),
          Text(
            'Curated Travel Experiences',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 8),
          Text(
            'Handpicked destinations with expert guides and premium accommodations',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = _categories; // Use the state variable list
    final icons = [
      Icons.wb_sunny,
      Icons.account_balance,
      Icons.hiking,
      Icons.beach_access
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.only(left: 16),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            // --- ACTION: Call filter logic on tap ---
            onTap: () => _applyCategoryFilter(index),
            // ---------------------------------------
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.orange.shade100 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(icons[index],
                      color: isSelected
                          ? Colors.deepOrange.shade600
                          : Colors.grey.shade600,
                      size: 20),
                  const SizedBox(width: 8),
                  Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.deepOrange.shade800
                          : Colors.black87,
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

  Widget _buildSectionHeader(String title, {int? count}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (count != null)
            Text('$count packages', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFeaturedPackagesList(List<TravelPackage> packages) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: packages.length,
        padding: const EdgeInsets.only(left: 16),
        itemBuilder: (context, index) {
          return _buildFeaturedPackageCard(packages[index]);
        },
      ),
    );
  }

  Widget _buildFeaturedPackageCard(TravelPackage package) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(
                  package.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      const Center(child: Icon(Icons.error, size: 40)),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: package.isFeatured
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Featured',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Row(children: [
                    Icon(Icons.favorite_border, color: Colors.white),
                    SizedBox(width: 8),
                    Icon(Icons.share_outlined, color: Colors.white),
                  ]),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.title,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        Flexible(
                            child: Text(package.location,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                                overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        const Icon(Icons.timer_outlined,
                            size: 14, color: Colors.grey),
                        Flexible(
                            child: Text(package.duration,
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12),
                                overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${package.rating} (${package.reviewCount})'),
                        const Spacer(),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8)),
                            child: Text(package.difficulty,
                                style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                      ],
                    ),
                    const Spacer(), 
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${package.price}',
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange),
                            ),
                            const Text('per person',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _launchUrl(package.link),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))), 
                          child: const Text('View Package'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPackagesList() {
    return ListView.separated(
      itemCount: _filteredPackages.length, // Use filtered list
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildAllPackagesCard(_filteredPackages[index]);
      },
    );
  }

  Widget _buildAllPackagesCard(TravelPackage package) {
    return GestureDetector(
      onTap: () => _launchUrl(package.link),
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: const Color(0xFFFFF9F5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  package.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      const Center(child: Icon(Icons.error, size: 40)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(package.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                          child: Text(
                        package.location,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      )),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Flexible(
                          child: Text(
                        package.date,
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      )),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text('${package.rating} • ${package.groupSize}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12)),
                    ]),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('\$${package.price}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                                fontSize: 16)),
                        const SizedBox(width: 4),
                        Text('\$${package.originalPrice}',
                            style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 12)),
                        const Spacer(),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(package.duration,
                              style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}