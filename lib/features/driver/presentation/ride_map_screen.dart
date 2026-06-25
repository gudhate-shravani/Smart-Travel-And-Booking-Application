// ride_map_screen.dart
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:location/location.dart' show PermissionStatus;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'dart:math' as math;

class RideMapScreen extends StatefulWidget {
  final String driverEmail;
  final String vehicleName;
  final String senderEmail;
  final DocumentReference requestDocRef;

  const RideMapScreen({
    super.key,
    required this.driverEmail,
    required this.vehicleName,
    required this.senderEmail,
    required this.requestDocRef,
  });

  @override
  State<RideMapScreen> createState() => _RideMapScreenState();
}

class _RideMapScreenState extends State<RideMapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final loc.Location _location = loc.Location();
  GoogleMapController? _mapController;
  StreamSubscription<loc.LocationData>? _locSub;

  LatLng? _driverLatLng;
  LatLng? _pickupLatLng;
  LatLng? _destLatLng;

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _currentPolyline = [];

  bool _showingPickupRoute = true;
  String googleApiKey = 'YOUR_GOOGLE_MAPS_API_KEY_HERE'; // <- put your API key here

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  @override
  void dispose() {
    _locSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _initAll() async {
    // 1) get pickup and destination addresses from request doc
    final reqSnap = await widget.requestDocRef.get();
    final data = reqSnap.data() as Map<String, dynamic>? ?? {};
    final pickupAddr = data['pickup_location']?.toString() ?? '';
    final destAddr = data['destination_location']?.toString() ?? '';

    // 2) geocode addresses to latlng
    try {
      if (pickupAddr.isNotEmpty) {
        final places = await locationFromAddress(pickupAddr);
        if (places.isNotEmpty) {
          _pickupLatLng = LatLng(places.first.latitude, places.first.longitude);
        }
      }
      if (destAddr.isNotEmpty) {
        final places = await locationFromAddress(destAddr);
        if (places.isNotEmpty) {
          _destLatLng = LatLng(places.first.latitude, places.first.longitude);
        }
      }
    } catch (e) {
      // geocoding error -> leave null
      debugPrint('Geocoding error: $e');
    }

    // 3) enable location permission and start tracking driver
    final locEnabled = await _location.serviceEnabled() || await _location.requestService();
    if (!locEnabled) {
      // user denied service
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enable location services')));
      }
      return;
    }

    final permStatus = await _location.hasPermission();
    if (permStatus == PermissionStatus.denied) {
      final p = await _location.requestPermission();
      if (p != PermissionStatus.granted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permission required')));
        }
        return;
      }
    }

    // get current location once
    final initial = await _location.getLocation();
    _driverLatLng = LatLng(initial.latitude ?? 0.0, initial.longitude ?? 0.0);

    // initial markers & camera
    _updateDriverMarker();
    _moveCameraTo(_driverLatLng!);

    // update driver's current location in Firestore
    await _writeDriverLocation(_driverLatLng!);

    // start listening to location updates
    _locSub = _location.onLocationChanged.listen((locData) async {
      if (locData.latitude == null || locData.longitude == null) return;
      _driverLatLng = LatLng(locData.latitude!, locData.longitude!);
      _updateDriverMarker();
      // if showing pickup route, update polyline from driver->pickup
      if (_showingPickupRoute && _pickupLatLng != null) {
        await _drawPolylineBetween(_driverLatLng!, _pickupLatLng!);
      } else if (!_showingPickupRoute && _destLatLng != null) {
        await _drawPolylineBetween(_driverLatLng!, _destLatLng!);
      }
      // write to firestore
      await _writeDriverLocation(_driverLatLng!);

      // if trip started and close to dest, mark trip completed
      final doc = await widget.requestDocRef.get();
      final tripState = (doc.data() as Map<String, dynamic>?)?['trip'] ?? 'not_started';
      if (tripState == 'start' && _destLatLng != null && _driverLatLng != null) {
        final dist = _calculateDistanceMeters(_driverLatLng!, _destLatLng!);
        if (dist < 50) {
          await widget.requestDocRef.update({'trip': 'completed'});
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trip marked completed')));
        }
      }
    });

    // draw initial polyline driver->pickup if pickup exists
    if (_driverLatLng != null && _pickupLatLng != null) {
      await _drawPolylineBetween(_driverLatLng!, _pickupLatLng!);
    }
    setState(() {});
  }

  Future<void> _updateDriverMarker() async {
    if (_driverLatLng == null) return;
    final m = Marker(
      markerId: const MarkerId('driver'),
      position: _driverLatLng!,
      infoWindow: const InfoWindow(title: 'You (Driver)'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
    _markers.removeWhere((e) => e.markerId == const MarkerId('driver'));
    _markers.add(m);

    // also add pickup/dest markers
    if (_pickupLatLng != null) {
      _markers.removeWhere((e) => e.markerId == const MarkerId('pickup'));
      _markers.add(Marker(markerId: const MarkerId('pickup'), position: _pickupLatLng!, infoWindow: const InfoWindow(title: 'Pickup')));
    }
    if (_destLatLng != null) {
      _markers.removeWhere((e) => e.markerId == const MarkerId('dest'));
      _markers.add(Marker(markerId: const MarkerId('dest'), position: _destLatLng!, infoWindow: const InfoWindow(title: 'Destination')));
    }

    setState(() {});
  }

  Future<void> _moveCameraTo(LatLng pos) async {
    if (_mapController == null) return;
    await _mapController!.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));
  }

  Future<void> _drawPolylineBetween(LatLng a, LatLng b) async {
    _currentPolyline.clear();
    PolylinePoints polylinePoints = PolylinePoints(apiKey: googleApiKey);

final result = await polylinePoints.getRouteBetweenCoordinates(
  request: PolylineRequest(
    origin: PointLatLng(a.latitude, a.longitude),
    destination: PointLatLng(b.latitude, b.longitude),
    mode: TravelMode.driving,
  ),
);



    if (result.points.isNotEmpty) {
      for (final p in result.points) {
        _currentPolyline.add(LatLng(p.latitude, p.longitude));
      }
      _polylines.removeWhere((p) => p.polylineId.value == 'route');
      _polylines.add(Polyline(polylineId: const PolylineId('route'), points: _currentPolyline, width: 5));
      setState(() {});
    }
  }

  Future<void> _writeDriverLocation(LatLng latlng) async {
    try {
      await _firestore.collection('Rental Driver').doc(widget.driverEmail).set({
        'currentLocation': {'lat': latlng.latitude, 'lng': latlng.longitude}
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error writing driver loc: $e');
    }
  }

  double _calculateDistanceMeters(LatLng p1, LatLng p2) {
    // Haversine
    double lat1 = p1.latitude;
    double lon1 = p1.longitude;
    double lat2 = p2.latitude;
    double lon2 = p2.longitude;
    const R = 6371000; // m
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = (sin(dLat/2) * sin(dLat/2)) + cos(_toRad(lat1)) * cos(_toRad(lat2)) * (sin(dLon/2) * sin(dLon/2));
    final c = 2 * asin(sqrt(a));
    final d = R * c;
    return d;
  }

  double _toRad(double deg) => deg * (3.1415926535897932 / 180.0);
  double sin(double x) => math.sin(x); // helper
  double cos(double x) => math.cos(x);
  double sqrt(double x) => math.sqrt(x);
  double asin(double x) => math.asin(x);

  // Helper: show OTP dialog in-map (FAB), verify against request doc and if matches set trip -> start
  Future<void> _showOtpDialogAndStart() async {
    final TextEditingController c = TextEditingController();
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Enter OTP to start trip'),
          content: TextField(controller: c, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'OTP')),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Verify')),
          ],
        );
      }
    );
    if (res != true) return;
    final entered = c.text.trim();
    if (entered.isEmpty) return;
    final doc = await widget.requestDocRef.get();
    final remoteOtp = (doc.data() as Map<String, dynamic>?)?['otp']?.toString() ?? '';
    if (entered == remoteOtp) {
      // set trip -> start
      await widget.requestDocRef.update({'trip': 'start'});
      // switch to destination route
      _showingPickupRoute = false;
      if (_driverLatLng != null && _destLatLng != null) {
        await _drawPolylineBetween(_driverLatLng!, _destLatLng!);
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP matched. Trip started')));
      setState(() {});
    } else {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP mismatch')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // default center
    final initial = _driverLatLng ?? const LatLng(28.6139, 77.2090);

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: initial, zoom: 13),
        onMapCreated: (c) {
          _mapController = c;
          if (_driverLatLng != null) _moveCameraTo(_driverLatLng!);
        },
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showOtpDialogAndStart,
        child: const Icon(Icons.check),
      ),
    );
  }
}
