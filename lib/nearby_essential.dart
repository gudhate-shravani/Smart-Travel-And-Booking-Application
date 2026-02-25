/*import 'package:flutter/material.dart';

class NearbyEssentialsScreen extends StatelessWidget {
  const NearbyEssentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'TravelMate',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.black87),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Title and subtitle
            const Center(
              child: Column(
                children: [
                  Icon(Icons.place, size: 60, color: Colors.purple),
                  SizedBox(height: 8),
                  Text(
                    'Nearby Essentials',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find ATMs, restaurants, gas stations, and emergency services nearby',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Current Location Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        ),
                        Text(
                          'Times Square, New York',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '1 km',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search for specific places...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, color: Colors.purple),
                  label: const Text('Filters', style: TextStyle(color: Colors.purple)),
                )
              ],
            ),

            const SizedBox(height: 8),

            // Category buttons
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: const [
                _CategoryChip(label: 'All', icon: Icons.grid_view, selected: true),
                _CategoryChip(label: 'ATM', icon: Icons.account_balance),
                _CategoryChip(label: 'Food', icon: Icons.restaurant),
                _CategoryChip(label: 'Gas', icon: Icons.local_gas_station),
                _CategoryChip(label: 'Medical', icon: Icons.local_hospital),
                _CategoryChip(label: 'Safety', icon: Icons.local_police),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              '6 places found nearby',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Place cards
            const _PlaceCard(
              name: 'Chase Bank ATM',
              address: '123 Main St, New York, NY',
              distance: '0.2 km',
              rating: 4.2,
              tags: ['24/7', 'Fee-free', 'Accessible'],
            ),
            const _PlaceCard(
              name: 'Joe’s Pizza',
              address: '456 Broadway, New York, NY',
              distance: '0.3 km',
              rating: 4.7,
              tags: ['Fast service', 'Italian', 'Takeout'],
            ),
            const _PlaceCard(
              name: 'Shell Gas Station',
              address: '789 Avenue, New York, NY',
              distance: '0.5 km',
              rating: 4.1,
              tags: ['Credit cards', 'Car wash', 'Convenience store'],
            ),
            const _PlaceCard(
              name: 'Central Hospital',
              address: '321 Health St, New York, NY',
              distance: '0.8 km',
              rating: 4.5,
              tags: ['Emergency', '24/7', 'Parking available'],
            ),
            const _PlaceCard(
              name: 'Police Station 14th Precinct',
              address: '555 Safety Ave, New York, NY',
              distance: '1.1 km',
              rating: 4.3,
              tags: ['24/7', 'Tourist assistance', 'Emergency'],
            ),
          ],
        ),
      ),

      // Bottom Navigation
    
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _CategoryChip({
    required this.label,
    required this.icon,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: selected
            ? const LinearGradient(
                colors: [Color(0xFFCE9FFC), Color(0xFF7367F0)],
              )
            : null,
        color: selected ? null : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: selected ? Colors.white : Colors.black87),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final String name;
  final String address;
  final double rating;
  final String distance;
  final List<String> tags;

  const _PlaceCard({
    required this.name,
    required this.address,
    required this.rating,
    required this.distance,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and distance
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.location_on, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(address,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.green, size: 10),
                          const SizedBox(width: 4),
                          const Text('Open',
                              style: TextStyle(
                                  color: Colors.green, fontSize: 13)),
                          const SizedBox(width: 8),
                          Text(distance,
                              style: const TextStyle(
                                  color: Colors.black45, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(rating.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCE9FFC), Color(0xFF7367F0)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        'Navigate',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 40,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.call, color: Colors.black87),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}*/



import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

// --------------------------------------------------------------------------
// 1. DATA MODEL
// --------------------------------------------------------------------------
class Place {
  final String name;
  final String address;
  final double rating;
  final double latitude;
  final double longitude;
  final String distance; 
  final List<String> tags;

  Place({
    required this.name,
    required this.address,
    required this.rating,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.tags = const [],
  });
}

// --------------------------------------------------------------------------
// 2. MAIN SCREEN (STATEFUL)
// --------------------------------------------------------------------------
class NearbyEssentialsScreen extends StatefulWidget {
  const NearbyEssentialsScreen({super.key});

  @override
  State<NearbyEssentialsScreen> createState() => _NearbyEssentialsScreenState();
}

class _NearbyEssentialsScreenState extends State<NearbyEssentialsScreen> {
  // --- State Variables ---
  Position? _currentPosition;
  String _currentAddress = 'Fetching location...';
  List<Place> _nearbyPlaces = [];
  String _selectedCategory = 'All'; 
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  // 🛑 IMPORTANT: REPLACE THIS WITH YOUR ACTUAL GOOGLE PLACES API KEY
  final String _googlePlacesApiKey = ' REPLACE THIS WITH YOUR ACTUAL GOOGLE PLACES API KEY'; 

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // --- Location Functions ---

  /// Determines the current position of the user and requests necessary permissions.
  Future<void> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  setState(() {
    _currentAddress = 'Checking location services...';
  });

  // 1. Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    setState(() => _currentAddress = 'Location services are disabled.');
    // Do NOT call _fetchNearbyPlaces if services are disabled
    return;
  }

  // 2. Check and request permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      setState(() => _currentAddress = 'Location permissions are denied.');
      // Do NOT call _fetchNearbyPlaces if permissions are denied
      return;
    }
  }

  try {
    setState(() => _currentAddress = 'Fetching current coordinates...');
    // 3. Get the actual position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        // Added a timeout to prevent infinite hanging
        timeLimit: const Duration(seconds: 15)); 
        
    setState(() {
      _currentPosition = position;
      // Display coordinates on success
      _currentAddress = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'; 
    });
    
    // 4. CRITICAL: ONLY call the fetch function here, after location is confirmed.
    _fetchNearbyPlaces(); 

  } catch (e) {
    debugPrint('Geolocation error: $e');
    setState(() => _currentAddress = 'Error: Failed to get GPS position.');
  }
}



  String _categoryToPlaceType(String category) {
    // Return a broad keyword for 'textsearch' endpoint, which is more reliable.
    switch (category) {
      case 'ATM':
        return 'ATM';
      case 'Food':
        return 'restaurant, cafe, fast food,bar,hotel';
      case 'Gas':
        return 'gas station,petrol pump';
      case 'Medical':
        return 'hospital, pharmacy, clinic';
      case 'Safety':
        return 'police, fire station, emergency,ambulance';
      case 'All':
      default:
        return 'essential services,police, fire station, emergency,hospital, pharmacy, clinic,gas station,restaurant, cafe, fast food,ATM'; // Broad query
    }
  }
  /// Fetches nearby places from Google Places API based on category or search query.
  Future<void> _fetchNearbyPlaces({String? query}) async {
    if (_currentPosition == null) {
      debugPrint('Location not available. Cannot fetch places.');
      return;
    }

    setState(() {
      _isLoading = true;
      _nearbyPlaces = []; 
    });

    try {
      final dio = Dio();
      
      // 1. ALWAYS use the textsearch/json endpoint for consistency and robustness.
      const String endpoint = 'textsearch/json'; 
      
      // Determine the search query: use the user's query or the category keyword.
      final String searchText = query != null && query.isNotEmpty
          ? query
          : _categoryToPlaceType(_selectedCategory); // Use keyword from the category function
      
      Map<String, dynamic> params = {
        'key': _googlePlacesApiKey,
        'query': searchText, 
        // 2. Use 'location' to bias results towards the user's coordinates.
        'location': '${_currentPosition!.latitude},${_currentPosition!.longitude}',
        'radius': 5000, // Still limits search scope to 5km radius
      };
      
      // --- DEBUGGING: Log the request query ---
      debugPrint('Places API Request Query: $searchText');
      debugPrint('Places API Location Bias: ${params['location']}');
      // ---------------------------------------------
      
      final response = await dio.get(
        'https://maps.googleapis.com/maps/api/place/$endpoint',
        queryParameters: params,
      );

      List<Place> fetchedPlaces = [];
      if (response.data['status'] == 'OK') {
        for (var result in response.data['results']) {
          final lat = result['geometry']['location']['lat'];
          final lng = result['geometry']['location']['lng'];
          
          final distanceInMeters = Geolocator.distanceBetween(
            _currentPosition!.latitude, 
            _currentPosition!.longitude, 
            lat, 
            lng
          );
          
          String formattedDistance = distanceInMeters < 1000 
              ? '${distanceInMeters.toStringAsFixed(0)} m'
              : '${(distanceInMeters / 1000).toStringAsFixed(1)} km';

          // Extract place types or any available tags
          List<String> rawTags = result['types'] != null 
                  ? List<String>.from(result['types']).map((t) => t.replaceAll('_', ' ')).toList() 
                  : ['Service'];
          
          fetchedPlaces.add(Place(
            name: result['name'] ?? 'Unknown Place',
            address: result['vicinity'] ?? 'Address not available',
            rating: (result['rating'] ?? 0.0).toDouble(),
            latitude: lat,
            longitude: lng,
            distance: formattedDistance,
            tags: rawTags.take(3).toList(),
          ));
        }
        debugPrint('Successfully fetched ${fetchedPlaces.length} places.');
      } else if (response.data['status'] == 'ZERO_RESULTS') {
        debugPrint('Google Places API: ZERO_RESULTS for query "$searchText". Try a different location or radius.');
      } else {
         // CRITICAL: Log the specific error message from Google
         debugPrint('Google Places API Error: ${response.data['status']} - ${response.data['error_message']}');
      }
      
      setState(() {
        _nearbyPlaces = fetchedPlaces;
        _isLoading = false;
      });

    } on DioError catch (e) {
      // Use DioException for Dio specific errors
      debugPrint('Dio/Network Error: ${e.message}');
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('General Error fetching places: $e');
      setState(() => _isLoading = false);
    }
}
  /// Launches the native map application for navigation.
  void _navigateToPlace(double destLat, double destLng) async {
    // Uses a Google Maps deep link for turn-by-turn navigation
    final String url = 'google.navigation:q=$destLat,$destLng';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Fallback to open in Google Maps browser view
      final String fallbackUrl = 'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=driving';
      if (await canLaunchUrl(Uri.parse(fallbackUrl))) {
        await launchUrl(Uri.parse(fallbackUrl));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map application.')),
        );
      }
    }
  }
  
  void _handleCategoryTap(String category) {
    setState(() {
      _selectedCategory = category;
      _searchController.clear(); // Clear search on category change
    });
    _fetchNearbyPlaces();
  }
  
  void _handleSearchSubmit(String query) {
    // If query is empty, revert to category search
    if (query.trim().isEmpty) {
      _fetchNearbyPlaces();
    } else {
      // If query is present, perform text search and clear category selection visually
      setState(() {
        _selectedCategory = 'Search'; // Temporarily change category state to visually unselect chips
      });
      _fetchNearbyPlaces(query: query);
    }
  }


  // --- UI Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Lets Explore',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.black87),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Title and subtitle
            const Center(
              child: Column(
                children: [
                  Icon(Icons.place, size: 60, color: Colors.purple),
                  SizedBox(height: 8),
                  Text(
                    'Nearby Essentials',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.purple,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Find ATMs, restaurants, gas stations, and emergency services nearby',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Current Location Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        ),
                        Text(
                          _currentAddress, // Dynamic address
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '5 km', 
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Bar
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _handleSearchSubmit,
                      decoration: const InputDecoration(
                        hintText: 'Search for specific places...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _handleSearchSubmit(''); // Revert to category search
                      },
                    )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Categories Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, color: Colors.purple),
                  label: const Text('Filters', style: TextStyle(color: Colors.purple)),
                )
              ],
            ),

            const SizedBox(height: 8),

            // Category buttons
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                _CategoryChip(
                  label: 'All', 
                  icon: Icons.grid_view, 
                  selected: _selectedCategory == 'All',
                  onTap: () => _handleCategoryTap('All'),
                ),
                _CategoryChip(
                  label: 'ATM', 
                  icon: Icons.account_balance, 
                  selected: _selectedCategory == 'ATM',
                  onTap: () => _handleCategoryTap('ATM'),
                ),
                _CategoryChip(
                  label: 'Food', 
                  icon: Icons.restaurant, 
                  selected: _selectedCategory == 'Food',
                  onTap: () => _handleCategoryTap('Food'),
                ),
                _CategoryChip(
                  label: 'Gas', 
                  icon: Icons.local_gas_station, 
                  selected: _selectedCategory == 'Gas',
                  onTap: () => _handleCategoryTap('Gas'),
                ),
                _CategoryChip(
                  label: 'Medical', 
                  icon: Icons.local_hospital, 
                  selected: _selectedCategory == 'Medical',
                  onTap: () => _handleCategoryTap('Medical'),
                ),
                _CategoryChip(
                  label: 'Safety', 
                  icon: Icons.local_police, 
                  selected: _selectedCategory == 'Safety',
                  onTap: () => _handleCategoryTap('Safety'),
                ),
                  _CategoryChip(
                  label: 'public washroom', 
                  icon: Icons.local_police, 
                  selected: _selectedCategory == 'public Washroom',
                  onTap: () => _handleCategoryTap('public washroom'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Results summary and list
            Text(
              _isLoading 
                  ? 'Searching...' 
                  : '${_nearbyPlaces.length} places found nearby',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            
            // Show loading or results
            _isLoading
              ? const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: CircularProgressIndicator(color: Colors.purple),
                ))
              : _nearbyPlaces.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(Icons.location_off, size: 40, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text(
                              _searchController.text.isNotEmpty
                                ? 'No results found for "${_searchController.text}".'
                                : 'No places found in this category or area.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            // Prompt to check API key if address is generic
                            if (_currentAddress == 'Fetching location...')
                              const Text('\nEnsure location permissions are granted.', style: TextStyle(color: Colors.redAccent))
                            else if (_googlePlacesApiKey == 'YOUR_GOOGLE_PLACES_API_KEY')
                                const Text('\n🛑 API KEY MISSING! Replace placeholder for results.', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))

                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _nearbyPlaces.map((place) {
                        return _PlaceCard(
                          place: place,
                          onNavigate: _navigateToPlace,
                        );
                      }).toList(),
                    ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------------------------------
// 3. WIDGET COMPONENTS
// --------------------------------------------------------------------------

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [Color(0xFFCE9FFC), Color(0xFF7367F0)],
                )
              : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  final Place place; 
  final Function(double lat, double lng) onNavigate; 

  const _PlaceCard({
    required this.place,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and distance
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Icon(Icons.location_on, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, 
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(place.address, 
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.circle, color: Colors.green, size: 10),
                          const SizedBox(width: 4),
                          const Text('Open', // Hardcoded 'Open' as status is complex via Places API
                              style: TextStyle(
                                  color: Colors.green, fontSize: 13)),
                          const SizedBox(width: 8),
                          Text(place.distance, 
                              style: const TextStyle(
                                  color: Colors.black45, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Rating
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(place.rating.toString(), 
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: place.tags 
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector( 
                    onTap: () => onNavigate(place.latitude, place.longitude),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFCE9FFC), Color(0xFF7367F0)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Navigate',
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 40,
                  width: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.call, color: Colors.black87),
                  // onTap logic would be added here if phone number was in Place model
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}