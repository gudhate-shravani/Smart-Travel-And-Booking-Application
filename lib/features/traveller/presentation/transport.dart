// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:convert'; // For parsing JSON
import 'package:http/http.dart' as http; // For API calls
import 'package:geolocator/geolocator.dart';
import 'bus_stop_screen.dart'; // For GPS location



// A new class to hold our route data
class RouteData {
  final String from;
  final String to;
  final String time;
  final String price;
  final List<IconData>? transportIcons;
  final List<RouteLeg>? legs;

  RouteData({
    required this.from,
    required this.to,
    required this.time,
    required this.price,
    this.transportIcons,
    this.legs,
  });
}



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Master list of all routes
  final List<RouteData> _allRoutes = [
    // --- Maharashtra Routes ---
    RouteData(from: 'Pune', to: 'Mumbai', time: '3h 30m', price: 'â‚¹750', transportIcons: [Icons.directions_bus, Icons.local_taxi], legs: [const RouteLeg(icon: Icons.directions_bus, title: 'Bus', description: 'Swargate (Pune) â†’ Dadar Circle (Mumbai)', time: '3h', price: 'â‚¹600'), const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Dadar Circle â†’ Gateway of India', time: '30m', price: 'â‚¹150'),],),
    RouteData(from: 'Pune', to: 'Nashik', time: '5h 15m', price: 'â‚¹1,100', transportIcons: [Icons.directions_bus, Icons.local_taxi], legs: [const RouteLeg(icon: Icons.directions_bus, title: 'Bus', description: 'Pune Shivajinagar â†’ Nashik CBS', time: '4h 30m', price: 'â‚¹800'), const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Nashik CBS â†’ Trimbakeshwar', time: '45m', price: 'â‚¹300'),],),
    RouteData(from: 'Pune', to: 'Nagpur', time: '13h 45m', price: 'â‚¹2,500', transportIcons: [Icons.local_taxi, Icons.train], legs: [const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Your Location â†’ Pune Station (PUNE)', time: '30m', price: 'â‚¹300'), const RouteLeg(icon: Icons.train, title: 'Train', description: 'Pune Station (PUNE) â†’ Nagpur (NGP)', time: '13h 15m', price: 'â‚¹2,200'),],),
    RouteData(from: 'Pune', to: 'Mahabaleshwar', time: '3h 30m', price: 'â‚¹650', transportIcons: [Icons.directions_bus, Icons.local_taxi], legs: [const RouteLeg(icon: Icons.directions_bus, title: 'Bus', description: 'Pune â†’ Mahabaleshwar Bus Stand', time: '3h 15m', price: 'â‚¹500'), const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Bus Stand â†’ Lodwick Point', time: '15m', price: 'â‚¹150'),],),
    RouteData(from: 'Pune', to: 'Aurangabad', time: '5h 00m', price: 'â‚¹950', transportIcons: [Icons.directions_bus, Icons.local_taxi], legs: [const RouteLeg(icon: Icons.directions_bus, title: 'Bus', description: 'Pune â†’ Aurangabad CBS', time: '4h 30m', price: 'â‚¹700'), const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Aurangabad CBS â†’ Ellora Caves', time: '30m', price: 'â‚¹250'),],),
    RouteData(from: 'Pune', to: 'Kolhapur', time: '4h 15m', price: 'â‚¹700', transportIcons: [Icons.train, Icons.local_taxi], legs: [const RouteLeg(icon: Icons.train, title: 'Train', description: 'Pune Station (PUNE) â†’ Kolhapur (KOP)', time: '4h', price: 'â‚¹500'), const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Kolhapur Station â†’ Mahalakshmi Temple', time: '15m', price: 'â‚¹200'),],),
    RouteData(from: 'Pune', to: 'Shirdi', time: '4h 30m', price: 'â‚¹600', transportIcons: [Icons.directions_bus, Icons.directions_walk], legs: [const RouteLeg(icon: Icons.directions_bus, title: 'Bus', description: 'Pune (Shivajinagar) â†’ Shirdi Bus Stand', time: '4h 15m', price: 'â‚¹600'), const RouteLeg(icon: Icons.directions_walk, title: 'Walk', description: 'Bus Stand â†’ Sai Baba Temple', time: '15m', price: 'â‚¹0'),],),
    RouteData(from: 'Pune', to: 'Alibag', time: '5h 00m', price: 'â‚¹900', transportIcons: [Icons.directions_bus, Icons.directions_boat, Icons.directions_bus], legs: [const RouteLeg(icon: Icons.directions_bus, title: 'Bus', description: 'Pune â†’ Gateway of India (Mumbai)', time: '3h 30m', price: 'â‚¹600'), const RouteLeg(icon: Icons.directions_boat, title: 'Ferry', description: 'Gateway of India â†’ Mandwa Jetty', time: '1h', price: 'â‚¹200'), const RouteLeg(icon: Icons.directions_bus, title: 'Bus', description: 'Mandwa Jetty â†’ Alibag Bus Stand', time: '30m', price: 'â‚¹100'),],),
    
    // --- Other Domestic Routes ---
    RouteData(from: 'Pune', to: 'Goa', time: '10h 30m', price: 'â‚¹1,800', transportIcons: [Icons.directions_bus, Icons.local_taxi], legs: [const RouteLeg(icon: Icons.directions_bus, title: 'Bus', description: 'Pune (Hinjewadi) â†’ Panjim (Goa)', time: '10h', price: 'â‚¹1,500'), const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Panjim â†’ Calangute Beach', time: '30m', price: 'â‚¹300'),],),
    RouteData(from: 'Pune', to: 'Bangalore', time: '1h 30m', price: 'â‚¹3,500', transportIcons: [Icons.flight_takeoff], legs: [const RouteLeg(icon: Icons.flight_takeoff, title: 'Flight', description: 'Pune (PNQ) â†’ Bangalore (BLR)', time: '1h 30m', price: 'â‚¹3,500'),],),
    RouteData(from: 'Pune', to: 'Chennai', time: '1h 45m', price: 'â‚¹4,200', transportIcons: [Icons.local_taxi, Icons.flight_takeoff], legs: [const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Home â†’ Pune Airport (PNQ)', time: '45m', price: 'â‚¹400'), const RouteLeg(icon: Icons.flight_takeoff, title: 'Flight', description: 'Pune (PNQ) â†’ Chennai (MAA)', time: '1h 45m', price: 'â‚¹3,800'),],),
    RouteData(from: 'Mumbai', to: 'Delhi', time: '2h 10m', price: 'â‚¹5,000', transportIcons: [Icons.flight_takeoff], legs: [const RouteLeg(icon: Icons.flight_takeoff, title: 'Flight', description: 'Mumbai (BOM) â†’ Delhi (DEL)', time: '2h 10m', price: 'â‚¹5,000'),],),
    RouteData(from: 'Mumbai', to: 'Kanyakumari', time: '28h 15m', price: 'â‚¹2,800', transportIcons: [Icons.train, Icons.local_taxi], legs: [const RouteLeg(icon: Icons.train, title: 'Train', description: 'Mumbai Central (MMCT) â†’ Nagercoil (NCJ)', time: '27h 30m', price: 'â‚¹2,000'), const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Nagercoil Station â†’ Kanyakumari Beach', time: '45m', price: 'â‚¹800'),],),

    // --- International (Abroad) Routes ---
    RouteData(from: 'Pune', to: 'Dubai', time: '4h 30m', price: 'â‚¹12,500', transportIcons: [Icons.local_taxi, Icons.flight_takeoff], legs: [const RouteLeg(icon: Icons.local_taxi, title: 'Taxi', description: 'Swargate â†’ Pune Airport (PNQ)', time: '45m', price: 'â‚¹500'), const RouteLeg(icon: Icons.flight_takeoff, title: 'Flight', description: 'Pune (PNQ) â†’ Dubai (DXB)', time: '3h 45m', price: 'â‚¹12,000'),],),
    RouteData(from: 'Pune', to: 'Singapore', time: '8h 15m', price: 'â‚¹22,000', transportIcons: [Icons.flight_takeoff, Icons.flight_takeoff], legs: [const RouteLeg(icon: Icons.flight_takeoff, title: 'Flight', description: 'Pune (PNQ) â†’ Bangalore (BLR)', time: '1h 30m', price: 'â‚¹3,500'), const RouteLeg(icon: Icons.flight_takeoff, title: 'Flight', description: 'Bangalore (BLR) â†’ Singapore (SIN)', time: '4h 45m', price: 'â‚¹18,500'),],),
    RouteData(from: 'Delhi', to: 'London', time: '9h 30m', price: 'â‚¹48,000', transportIcons: [Icons.flight_takeoff], legs: [const RouteLeg(icon: Icons.flight_takeoff, title: 'Flight', description: 'Delhi (DEL) â†’ London-Heathrow (LHR)', time: '9h 30m', price: 'â‚¹48,000'),],),
    RouteData(from: 'Pune', to: 'Paris', time: '14h 30m', price: 'â‚¹45,000', transportIcons: [Icons.directions_bus, Icons.flight_takeoff], legs: [const RouteLeg(icon: Icons.directions_bus, title: 'Bus', description: 'Pune Station (Stop 2) â†’ Pune Airport (PNQ)', time: '45m', price: 'â‚¹150'), const RouteLeg(icon: Icons.flight_takeoff, title: 'Flight', description: 'Pune (PNQ) â†’ Paris-CDG (via DXB)', time: '13h 45m', price: 'â‚¹44,850'),],),
  ];

  List<RouteData> _displayedRoutes = [];
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _displayedRoutes = List.from(_allRoutes);
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _filterRoutes() {
    final String fromQuery = _fromController.text.toLowerCase();
    final String toQuery = _toController.text.toLowerCase();

    setState(() {
      _displayedRoutes = _allRoutes.where((route) {
        final bool fromMatch = fromQuery.isEmpty ||
            route.from.toLowerCase().startsWith(fromQuery);
        final bool toMatch =
            toQuery.isEmpty || route.to.toLowerCase().startsWith(toQuery);
        return fromMatch && toMatch;
      }).toList();
    });
  }

  void _showNearbyStations() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BusStopScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildSearchUi(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Routes',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2A38),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _showNearbyStations,
                    icon: Icon(Icons.my_location, size: 18, color: Colors.blue.shade700),
                    label: Text(
                      'Nearby',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_displayedRoutes.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      'No matching routes found.',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                Column(
                  children: _displayedRoutes.map((route) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: RouteInfoCard(
                        from: route.from,
                        to: route.to,
                        time: route.time,
                        price: route.price,
                        transportIcons: route.transportIcons,
                        legs: route.legs,
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchUi() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _fromController,
            onChanged: (value) => _filterRoutes(),
            decoration: InputDecoration(
              hintText: 'From (e.g., Pune, Mumbai)',
              prefixIcon: Icon(Icons.location_on_outlined, color: Colors.blue.shade300),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _toController,
            onChanged: (value) => _filterRoutes(),
            decoration: InputDecoration(
              hintText: 'To (e.g., Goa, Dubai)',
              prefixIcon: Icon(Icons.location_on, color: Colors.blue.shade600),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _GradientButton(
            onPressed: () {
              _filterRoutes();
            },
            text: 'Find Routes',
            icon: Icons.search,
          ),
        ],
      ),
    );
  }
}

// --- RouteLeg Class ---
class RouteLeg {
  final IconData icon;
  final String title;
  final String description;
  final String? time;
  final String? price;
  const RouteLeg({
    required this.icon,
    required this.title,
    required this.description,
    this.time,
    this.price,
  });
}

// --- RouteInfoCard Widget ---
class RouteInfoCard extends StatefulWidget {
  final String from;
  final String to;
  final String time;
  final String price;
  final List<IconData>? transportIcons;
  final List<RouteLeg>? legs;
  const RouteInfoCard({
    super.key,
    required this.from,
    required this.to,
    required this.time,
    required this.price,
    this.transportIcons,
    this.legs,
  });
  @override
  State<RouteInfoCard> createState() => _RouteInfoCardState();
}

class _RouteInfoCardState extends State<RouteInfoCard> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.blue.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      margin: const EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildCollapsedHeader(),
                      const SizedBox(height: 16),
                      _buildSummaryRow(),
                    ],
                  ),
                ),
              ),
              if (_isExpanded) _buildExpandedContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedHeader() {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.from} â†’ ${widget.to}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...?widget.transportIcons?.map(
                  (icon) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(icon, size: 20, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Icon(
          _isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.grey.shade700,
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        _buildSummaryChip(
          icon: Icons.access_time_filled,
          text: widget.time,
          backgroundColor: Colors.orange.withValues(alpha: 0.1),
          foregroundColor: Colors.orange.shade800,
        ),
        const SizedBox(width: 12),
        _buildSummaryChip(
          icon: Icons.monetization_on,
          text: widget.price,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
          foregroundColor: Colors.green.shade800,
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(height: 16),
          ...?widget.legs?.map((leg) => _buildLegInfo(leg)),
        ],
      ),
    );
  }

  Widget _buildLegInfo(RouteLeg leg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(leg.icon, color: Colors.blue.shade700, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leg.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  leg.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                if (leg.time != null || leg.price != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (leg.time != null) ...[
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Text(
                          leg.time!,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (leg.price != null) ...[
                        Icon(Icons.monetization_on_outlined, size: 14, color: Colors.grey.shade700),
                        const SizedBox(width: 4),
                        Text(
                          leg.price!,
                          style: TextStyle(fontSize: 14, color: Colors.grey.shade800, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required IconData icon,
    required String text,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: foregroundColor, fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// --- GradientButton Widget ---
class _GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  const _GradientButton({
    required this.onPressed,
    required this.text,
    this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            width: double.infinity,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===================================================================
// *** NEARBY STATIONS SCREEN (Direct, Insecure API Call for Testing) ***
// ===================================================================

/// A data model for a station from the Google Places API
class Station {
  final String name;
  final String address; // Google calls this 'vicinity'
  final IconData icon;

  Station({required this.name, required this.address, required this.icon});

  factory Station.fromJson(Map<String, dynamic> json) {
    String type = 'location_pin';
    if (json['types'] != null) {
      List<dynamic> types = json['types'];
      if (types.contains('airport')) {
        type = 'airport';
      } else if (types.contains('train_station')){ type = 'train';}
      else if (types.contains('bus_station')) {type = 'bus';}
      else if (types.contains('bus_stop')) {type = 'bus_stop';} // Catches PMT stops
    }

    return Station(
      name: json['name'] ?? 'Unnamed Place',
      address: json['vicinity'] ?? 'No address provided',
      icon: _getIconForType(type),
    );
  }

  static IconData _getIconForType(String type) {
    switch (type) {
      case 'airport':
        return Icons.flight;
      case 'train':
        return Icons.train;
      case 'bus':
      case 'bus_stop':
        return Icons.directions_bus;
      default:
        return Icons.location_pin;
    }
  }
}

class NearbyStationsScreen extends StatefulWidget {
  const NearbyStationsScreen({super.key});

  @override
  State<NearbyStationsScreen> createState() => _NearbyStationsScreenState();
}

class _NearbyStationsScreenState extends State<NearbyStationsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Station> _nearbyStations = [];

  // *** YOUR API KEY IS PASTED HERE ***
  final String _yourApiKey = "AIzaSyC-d7WK6cZDT0RIbWhnwGjRLkrKPR3IPCYmy";

  @override
  void initState() {
    super.initState();
    if (_yourApiKey == "PASTE_YOUR_API_KEY_HERE") {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please add your Google API key to the code to test this feature.';
      });
    } else {
      _fetchNearbyStations();
    }
  }

  /// Gets user's current location, then calls the Google API directly
  Future<void> _fetchNearbyStations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 1. Get user's location permission
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

      // 2. Get current GPS position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      // 3. Build the (insecure) Google API URL
      // We are searching for all these types in a 5km (5000m) radius
      final String googleApiUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
          '?location=${position.latitude},${position.longitude}'
          '&radius=5000'
          '&types=airport|train_station|bus_station|bus_stop' // bus_stop finds PMT stops
          '&key=$_yourApiKey';
      
      final Uri uri = Uri.parse(googleApiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // 4. Parse the JSON response
        final data = json.decode(response.body);

        // Check the API status
        final String status = data['status'];
        if (status == 'OK') {
          final List<dynamic> results = data['results'];
          setState(() {
            _nearbyStations = results.map((json) => Station.fromJson(json)).toList();
            _isLoading = false;
          });
        } else if (status == 'REQUEST_DENIED') {
          throw Exception('Request Denied. Is your API key correct, is billing enabled, and is the Places API enabled?');
        } else {
           throw Exception('Google API Error: $status');
        }
      } else {
        throw Exception('Failed to load stations from Google. (Code: ${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Stations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: _buildBody(),
    );
  }

  /// Builds the body based on the current state (loading, error, or success)
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Error: $_errorMessage\n\nPlease check your location permissions, internet, and API key.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }
    
    if (_nearbyStations.isEmpty) {
      return const Center(
        child: Text(
          'No nearby stations found.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      itemCount: _nearbyStations.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final station = _nearbyStations[index];
        return ListTile(
          leading: Icon(
            station.icon,
            color: Colors.blue.shade700,
          ),
          title: Text(
            station.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            station.address,
            style: const TextStyle(color: Colors.black54),
          ),
        );
      },
    );
  }
}