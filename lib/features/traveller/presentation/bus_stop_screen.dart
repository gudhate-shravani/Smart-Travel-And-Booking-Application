// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'location_service.dart';
import 'bus_stop_card.dart';

class BusStopScreen extends StatefulWidget {
  const BusStopScreen({super.key});

  @override
  State<BusStopScreen> createState() => _BusStopScreenState();
}

class _BusStopScreenState extends State<BusStopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _currentPosition;
  LatLng? _searchedStop;
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>> _nearbyStops = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
          markerId: const MarkerId('current'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: "You are here"),
        ));
      });

      _fetchNearbyStops();
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _searchStop() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          _searchedStop = LatLng(loc.latitude, loc.longitude);
          _markers.add(Marker(
            markerId: const MarkerId('searchedStop'),
            position: _searchedStop!,
            infoWindow: InfoWindow(title: query),
          ));
        });
        final mapController = await _mapController.future;
        mapController.animateCamera(CameraUpdate.newLatLngZoom(_searchedStop!, 14));
      }
    } catch (e) {
      debugPrint("Search error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stop not found')),
      );
    }
  }

  void _fetchNearbyStops() {
    // Dummy nearby stops
    _nearbyStops = [
      {'name': 'Swargate Bus Stop', 'lat': 18.5010, 'lng': 73.8580},
      {'name': 'Shivaji Nagar Bus Stop', 'lat': 18.5308, 'lng': 73.8476},
      {'name': 'Deccan Bus Stop', 'lat': 18.5168, 'lng': 73.8413},
    ];
    setState(() {});
  }

  void _viewStopOnMap(double lat, double lng, String name) async {
    final stop = LatLng(lat, lng);
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(name),
        position: stop,
        infoWindow: InfoWindow(title: name),
      ));
    });
    final mapController = await _mapController.future;
    mapController.animateCamera(CameraUpdate.newLatLngZoom(stop, 14));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Stop Finder'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search Bus Stop...',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _searchStop,
                        child: const Text("Search"),
                      )
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition!,
                      zoom: 13,
                    ),
                    myLocationEnabled: true,
                    markers: _markers,
                    onMapCreated: (controller) => _mapController.complete(controller),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: _nearbyStops.length,
                    itemBuilder: (context, index) {
                      final stop = _nearbyStops[index];
                      return BusStopCard(
                        stopName: stop['name'],
                        onViewLocation: () => _viewStopOnMap(
                          stop['lat'],
                          stop['lng'],
                          stop['name'],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
