// ignore_for_file: body_might_complete_normally_catch_error, constant_identifier_names, deprecated_member_use, use_build_context_synchronously





// lib/location_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocod;
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

const String GOOGLE_API_KEY = 'location  ggoole apikey'; // <<-- Replace this

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  int _selectedCategoryIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // categories: Fuel, EV Charging, Petrol Pump
  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.local_gas_station_rounded, 'label': 'Fuel'},
    {'icon': Icons.ev_station_rounded, 'label': 'EV Charging'},
    {'icon': Icons.local_gas_station, 'label': 'Petrol Pump'},
  ];

  // map controllers & state
  final Completer<GoogleMapController> _mapController = Completer();
  final CameraPosition _initialCamera = const CameraPosition(target: LatLng(28.6315, 77.2167), zoom: 12); // Delhi default
  LatLng? _currentLatLng;
  Marker? _searchedMarker;
  LatLng? _searchedLatLng;
  final Set<Marker> _nearbyMarkers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  final polylinePoints = PolylinePoints(apiKey: 'AIzaSyC-d7WK6cZDT0RIbWhnwGjRLkrKPR3IPCY');


  bool _mapCardHasPlace = false;
  String _mapCardPlaceName = '';
  String _mapCardPlaceAddress = '';

  // For showing nearby places list (same card UI)
  List<Map<String, dynamic>> _nearbyPlaces = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // ask user to enable
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      // permissions are denied forever
      return;
    }

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentLatLng = LatLng(pos.latitude, pos.longitude);
    final controller = await _mapController.future.catchError((_) {});
    setState(() {});
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLatLng!, 14));
    }

  Future<void> _onSearchSubmitted(String query) async {
    if (query.trim().isEmpty) return;
    try {
      List<geocod.Location> locations = await geocod.locationFromAddress(query);
      if (locations.isEmpty) return;
      _searchedLatLng = LatLng(locations.first.latitude, locations.first.longitude);
      _searchedMarker = Marker(
        markerId: const MarkerId('searched_place'),
        position: _searchedLatLng!,
        infoWindow: InfoWindow(title: query),
      );
      // set map card info
      _mapCardHasPlace = true;
      _mapCardPlaceName = query;
      _mapCardPlaceAddress = '${_searchedLatLng!.latitude.toStringAsFixed(5)}, ${_searchedLatLng!.longitude.toStringAsFixed(5)}';

      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(_searchedLatLng!, 14));

      // clear polylines
      _polylines.clear();
      _polylineCoordinates.clear();

      setState(() {});
    } catch (e) {
      debugPrint('Geocode error: $e');
    }
  }

  Future<void> _openMapWithRoute({required LatLng destination, String? destinationName}) async {
    if (_currentLatLng == null) {
      await _determinePosition();
      if (_currentLatLng == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to get current location')));
        return;
      }
    }

    // get directions
    await _createRoute(_currentLatLng!, destination);

    // navigate to full-screen map view
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return RouteMapScreen(
        origin: _currentLatLng!,
        destination: destination,
        polylines: _polylines,
        markers: {
          Marker(markerId: const MarkerId('origin'), position: _currentLatLng!, infoWindow: const InfoWindow(title: 'You')),
          Marker(markerId: const MarkerId('dest'), position: destination, infoWindow: InfoWindow(title: destinationName ?? 'Destination')),
        },
      );
    }));
  }

  Future<void> _createRoute(LatLng start, LatLng end) async {
  // Clear previous route
  _polylines.clear();
  _polylineCoordinates.clear();

  try {
    final directionsUrl =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${start.latitude},${start.longitude}'
        '&destination=${end.latitude},${end.longitude}'
        '&mode=driving'
        '&key=$GOOGLE_API_KEY';

    final resp = await http.get(Uri.parse(directionsUrl));
    if (resp.statusCode != 200) {
      debugPrint('Directions API returned ${resp.statusCode}');
      return;
    }

    final Map<String, dynamic> data = jsonDecode(resp.body);
    if (data['status'] != 'OK' || (data['routes'] as List).isEmpty) {
      debugPrint('No routes found: ${data['status']}, ${data['error_message'] ?? ''}');
      return;
    }

    final String encodedPolyline = data['routes'][0]['overview_polyline']['points'] as String;

    // Ã¢Å“â€¦ Use static method instead of instance method
    final List<PointLatLng> result = PolylinePoints.decodePolyline(encodedPolyline);

    if (result.isEmpty) {
      debugPrint('Decoded polyline contains no points.');
      return;
    }

    _polylineCoordinates = result
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final polylineId = PolylineId('route_${DateTime.now().millisecondsSinceEpoch}');
    final polyline = Polyline(
      polylineId: polylineId,
      points: _polylineCoordinates,
      width: 6,
      color: Colors.blue,
      geodesic: true,
    );

    _polylines.add(polyline);
    setState(() {});
  } catch (e, st) {
    debugPrint('Error in _createRoute: $e\n$st');
  }
}

  /// fetch nearby places using Places API (nearbysearch)
  Future<void> _fetchNearbyPlaces(String type) async {
    if (_currentLatLng == null) {
      await _determinePosition();
      if (_currentLatLng == null) return;
    }
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentLatLng!.latitude},${_currentLatLng!.longitude}&radius=5000&type=$type&key=$GOOGLE_API_KEY';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return;
    final map = jsonDecode(res.body);
    final results = map['results'] as List<dynamic>;
    _nearbyPlaces = results.map((r) {
      return {
        'name': r['name'],
        'address': r['vicinity'] ?? '',
        'lat': r['geometry']['location']['lat'],
        'lng': r['geometry']['location']['lng'],
        'place_id': r['place_id'],
      };
    }).toList();

    // create markers
    _nearbyMarkers.clear();
    for (var p in _nearbyPlaces) {
      final m = Marker(
        markerId: MarkerId(p['place_id']),
        position: LatLng(p['lat'], p['lng']),
        infoWindow: InfoWindow(title: p['name'], snippet: p['address']),
      );
      _nearbyMarkers.add(m);
    }

    // show places on main card by replacing map card content
    _mapCardHasPlace = false; // main map card will show results in list below map
    setState(() {});
  }

  String _categoryTypeForIndex(int idx) {
    // Places API types: gas_station, charging_station
    if (idx == 0) return 'gas_station';
    if (idx == 1) return 'charging_station';
    return 'gas_station';
  }

  // UI builders (kept same structure, but removed Quick Actions & Traffic)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 241, 247),
      appBar: AppBar(
        title: const Text('Location Helper'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color.fromARGB(255, 16, 16, 16),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(70, 0, 20, 0), child: _buildHeader()),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildLiveMapView(), // now contains the interactive GoogleMap in the card
              const SizedBox(height: 20),
              // quick actions removed per requirement
              _buildCategoryFilters(),
              const SizedBox(height: 20),
              _buildCurrentLocationCard(),
              const SizedBox(height: 20),
              _buildNearbyPlaces(), // dynamic content based on selected category or searched place
              // traffic updates removed per requirement
            ],
          ),
        ),
      ),
      floatingActionButton: Tooltip(
        message: 'Plan a route',
        child: FloatingActionButton(
          onPressed: () => _showPlanRouteDialog(context),
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.route_rounded, color: Colors.white),
        ),
      ),
    );
  }

  // 1. Header (unchanged)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.withValues(alpha: 0.1),
          child: const Icon(Icons.location_on_outlined, color: Colors.blue, size: 30),
        ),
        const SizedBox(height: 12),
        const Text('Location Helper', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Smart navigation & place discovery', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }

  // 2. Search Bar (triggers geo and shows marker in map card)
  Widget _buildSearchBar() {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(25),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => _onSearchSubmitted(value),
        decoration: InputDecoration(
          hintText: 'Search for places...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
          suffixIcon: IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: Colors.grey),
            onPressed: () {},
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  // 3. Live Map View (card now contains a GoogleMap and below it a mini summary + View on Map)
  Widget _buildLiveMapView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.map_outlined, size: 20, color: Colors.black54),
            SizedBox(width: 8),
            Text('Live Map View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: _initialCamera,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: {
                  if (_currentLatLng != null) Marker(markerId: const MarkerId('me'), position: _currentLatLng!),
                  if (_searchedMarker != null) _searchedMarker!,
                  ..._nearbyMarkers,
                },
                polylines: _polylines,
                onMapCreated: (GoogleMapController controller) {
                  if (!_mapController.isCompleted) _mapController.complete(controller);
                },
                onTap: (pos) {
                  // hide search card details if user taps map
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // show either searched place details or a small hint
          _mapCardHasPlace
              ? Row(
                  children: [
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_mapCardPlaceName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_mapCardPlaceAddress, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ])),
                    ElevatedButton(
                      onPressed: _searchedLatLng == null
                          ? null
                          : () => _openMapWithRoute(destination: _searchedLatLng!, destinationName: _mapCardPlaceName),
                      child: const Text('View on Map'),
                    ),
                  ],
                )
              : const Text('Search a place to preview it on the map above', style: TextStyle(color: Colors.black54)),
        ]),
      ),
    );
  }

  // Category filters (shows which category is selected and fetches nearby)
  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false, dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        }),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategoryIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: isSelected
                  ? ElevatedButton.icon(
                      icon: Icon(category['icon'], size: 18, color: Colors.white),
                      label: Text(category['label'], style: const TextStyle(color: Colors.white)),
                      onPressed: () => setState(() => _selectedCategoryIndex = index),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    )
                  : OutlinedButton.icon(
                      icon: Icon(category['icon'], size: 18),
                      label: Text(category['label']),
                      onPressed: () async {
                        setState(() => _selectedCategoryIndex = index);
                        final type = _categoryTypeForIndex(index);
                        await _fetchNearbyPlaces(type);
                      },
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCurrentLocationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.blue.withValues(alpha: 0.1), Colors.blue.withValues(alpha: 0.2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.my_location, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Current Location', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(_currentLatLng != null ? '${_currentLatLng!.latitude.toStringAsFixed(5)}, ${_currentLatLng!.longitude.toStringAsFixed(5)}' : 'Determining location...', style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              const Text('Accuracy: Ã‚Â±5 meters', style: TextStyle(color: Colors.black54, fontSize: 12)),
            ]),
          ),
          OutlinedButton.icon(onPressed: () async {
            // share: simple clipboard for now
            if (_currentLatLng != null) {
              // copy to clipboard or share - minimal approach:
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location link ready (copy/share outside)')));
            }
          }, icon: const Icon(Icons.share_outlined, size: 16), label: const Text('Share')),
        ],
      ),
    );
  }

  Widget _buildNearbyPlaces() {
    // If user searched a place, show that place card (already displayed in map card), below show nearby places if any
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Nearby Places', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
          child: Text('${_nearbyPlaces.length} found', style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ]),
      const SizedBox(height: 12),
      // If we have fetched nearby places, show them; otherwise show some default sample cards (kept same card UI)
      if (_nearbyPlaces.isEmpty) ...[
        _placeCard('AIIMS Hospital', 'Ansari Nagar, New Delhi', '2.3 km', '8 mins', '4.2', Icons.local_hospital_rounded, isSample: true),
        const SizedBox(height: 12),
        _placeCard('HP Petrol Pump', 'Ring Road, New Delhi', '1.1 km', '4 mins', '4', Icons.local_gas_station_rounded, isSample: true),
        const SizedBox(height: 12),
        _placeCard('McDonald\'s', 'Connaught Place', '3.2 km', '12 mins', '4.3', Icons.restaurant_menu, isSample: true),
      ] else ...[
        for (var p in _nearbyPlaces) ...[
          _realPlaceCard(p),
          const SizedBox(height: 12),
        ],
      ],
    ]);
  }

  Widget _placeCard(String name, String address, String dist, String time, String rating, IconData icon, {bool isSample = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(children: [
          CircleAvatar(child: Icon(icon, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(address, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 8),
              Row(children: [
                Text('$dist Ã¢â‚¬Â¢ $time Ã¢â‚¬Â¢ ', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                const Icon(Icons.star, color: Colors.amber, size: 14),
                Text(' $rating', style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ]),
            ]),
          ),
          OutlinedButton.icon(
            onPressed: () {
              if (isSample) {
                // open map showing sample location
                final sampleDest = LatLng(28.6315 + 0.01, 77.2167 + 0.01);
                _openMapWithRoute(destination: sampleDest, destinationName: name);
              } else {
                // do nothing
              }
            },
            icon: const Icon(Icons.near_me_outlined, size: 16),
            label: const Text('Navigate'),
          ),
        ]),
      ),
    );
  }

  Widget _realPlaceCard(Map<String, dynamic> place) {
    final name = place['name'] ?? '';
    final addr = place['address'] ?? '';
    final lat = place['lat'];
    final lng = place['lng'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(children: [
          const CircleAvatar(child: Icon(Icons.place, size: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(addr, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              const SizedBox(height: 8),
              Row(children: [
                Text('${(Geolocator.distanceBetween(_currentLatLng?.latitude ?? 0, _currentLatLng?.longitude ?? 0, lat, lng) / 1000).toStringAsFixed(1)} km Ã¢â‚¬Â¢ approx', style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ]),
            ]),
          ),
          OutlinedButton.icon(
            onPressed: () {
              _openMapWithRoute(destination: LatLng(lat, lng), destinationName: name);
            },
            icon: const Icon(Icons.near_me_outlined, size: 16),
            label: const Text('Navigate'),
          ),
        ]),
      ),
    );
  }

  // Plan Route dialog (FAB)
  void _showPlanRouteDialog(BuildContext context) {
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Plan Route'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Location', prefixIcon: Icon(Icons.my_location))),
              const SizedBox(height: 12),
              TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'Destination', prefixIcon: Icon(Icons.location_on))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final startText = startCtrl.text.trim();
                final endText = endCtrl.text.trim();
                if (startText.isEmpty || endText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter both start and destination')));
                  return;
                }
                // geocode start and end
                try {
                  final sres = await geocod.locationFromAddress(startText);
                  final eres = await geocod.locationFromAddress(endText);
                  final sLatLng = LatLng(sres.first.latitude, sres.first.longitude);
                  final eLatLng = LatLng(eres.first.latitude, eres.first.longitude);
                  // create route polyline
                  await _createRoute(sLatLng, eLatLng);

                  // push full screen route map
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                    return RouteMapScreen(
                      origin: sLatLng,
                      destination: eLatLng,
                      polylines: _polylines,
                      markers: {
                        Marker(markerId: const MarkerId('start'), position: sLatLng, infoWindow: InfoWindow(title: startText)),
                        Marker(markerId: const MarkerId('end'), position: eLatLng, infoWindow: InfoWindow(title: endText)),
                      },
                    );
                  }));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Geocoding failed: $e')));
                }
              },
              child: const Text('Find Routes'),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Full screen route map widget
class RouteMapScreen extends StatefulWidget {
  final LatLng origin;
  final LatLng destination;
  final Set<Polyline> polylines;
  final Set<Marker> markers;

  const RouteMapScreen({super.key, required this.origin, required this.destination, required this.polylines, required this.markers});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  late CameraPosition _camera;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _camera = CameraPosition(target: widget.origin, zoom: 13);
    _polylines = widget.polylines;
    _markers = widget.markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: GoogleMap(
        initialCameraPosition: _camera,
        polylines: _polylines,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) async {
          if (!_controller.isCompleted) _controller.complete(controller);
          // fit bounds to show both markers
          await Future.delayed(const Duration(milliseconds: 300));
          try {
            final controller2 = await _controller.future;
            final bounds = LatLngBounds(
              southwest: LatLng(
                (widget.origin.latitude <= widget.destination.latitude) ? widget.origin.latitude : widget.destination.latitude,
                (widget.origin.longitude <= widget.destination.longitude) ? widget.origin.longitude : widget.destination.longitude,
              ),
              northeast: LatLng(
                (widget.origin.latitude > widget.destination.latitude) ? widget.origin.latitude : widget.destination.latitude,
                (widget.origin.longitude > widget.destination.longitude) ? widget.origin.longitude : widget.destination.longitude,
              ),
            );
            controller2.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
          } catch (e) {
            // ignore
          }
        },
      ),
    );
  }
}
