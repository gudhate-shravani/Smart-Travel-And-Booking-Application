// view_location_page.dart
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

const String GOOGLE_MAPS_API_KEY = "AIzaSyC-d7WK6cZDT0RIbWhnwGjRLkrKPR3IPCY";

class ViewLocationPage extends StatefulWidget {
  final String driverEmail;
  const ViewLocationPage({super.key, required this.driverEmail});

  @override
  State<ViewLocationPage> createState() => _ViewLocationPageState();
}

class _ViewLocationPageState extends State<ViewLocationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  Marker? _userMarker;
  Marker? _driverMarker;
  Polyline? _route;
  CameraPosition _initialPos = const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5.0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  Future<void> _setup() async {
    setState(() => _loading = true);
    try {
      // fetch driver location
      final driverDoc = await _firestore.collection('Rental Driver').doc(widget.driverEmail).get();
      if (!driverDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Driver location not found')));
        }
        setState(() => _loading = false);
        return;
      }
      final d = driverDoc.data() ?? {};
      double? dlat, dlng;
      final rawLat = d['latitude'] ?? d['lat'] ?? d['location']?['latitude'];
      final rawLng = d['longitude'] ?? d['lng'] ?? d['location']?['longitude'];
      if (rawLat != null) {
        dlat = (rawLat is num) ? rawLat.toDouble() : double.tryParse(rawLat.toString());
      }
      if (rawLng != null) {
        dlng = (rawLng is num) ? rawLng.toDouble() : double.tryParse(rawLng.toString());
      }

      // fetch user location
      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      final userLatLng = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _userMarker = Marker(markerId: const MarkerId('user'), position: userLatLng, infoWindow: const InfoWindow(title: 'You'));
      });

      if (dlat != null && dlng != null) {
        final driverLatLng = LatLng(dlat, dlng);
        setState(() {
          _driverMarker = Marker(markerId: const MarkerId('driver'), position: driverLatLng, infoWindow: const InfoWindow(title: 'Driver'));
        });

        // Try Google Directions API if key present else draw straight line
        if (GOOGLE_MAPS_API_KEY.isNotEmpty) {
          try {
            final url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=${userLatLng.latitude},${userLatLng.longitude}&destination=${driverLatLng.latitude},${driverLatLng.longitude}&key=$GOOGLE_MAPS_API_KEY&mode=driving');
            final resp = await http.get(url);
            if (resp.statusCode == 200) {
              final body = json.decode(resp.body);
              final routes = body['routes'] as List<dynamic>?;
              if (routes != null && routes.isNotEmpty) {
                final poly = routes.first['overview_polyline']['points'] as String?;
                final decoded = _decodePolyline(poly ?? '');
                setState(() {
                  _route = Polyline(polylineId: const PolylineId('route'), points: decoded, width: 5);
                });
              } else {
                setState(() {
                  _route = Polyline(polylineId: const PolylineId('route'), points: [userLatLng, driverLatLng], width: 5);
                });
              }
            } else {
              setState(() {
                _route = Polyline(polylineId: const PolylineId('route'), points: [userLatLng, driverLatLng], width: 5);
              });
            }
          } catch (e) {
            setState(() {
              _route = Polyline(polylineId: const PolylineId('route'), points: [userLatLng, driverLatLng], width: 5);
            });
          }
        } else {
          setState(() {
            _route = Polyline(polylineId: const PolylineId('route'), points: [userLatLng, driverLatLng], width: 5);
          });
        }

        // move camera to include both
        final latMin = [userLatLng.latitude, driverLatLng.latitude].reduce((a, b) => a < b ? a : b);
        final latMax = [userLatLng.latitude, driverLatLng.latitude].reduce((a, b) => a > b ? a : b);
        final lonMin = [userLatLng.longitude, driverLatLng.longitude].reduce((a, b) => a < b ? a : b);
        final lonMax = [userLatLng.longitude, driverLatLng.longitude].reduce((a, b) => a > b ? a : b);
        final bounds = LatLngBounds(southwest: LatLng(latMin, lonMin), northeast: LatLng(latMax, lonMax));
        // later on mapCreated we will animate to bounds
        _initialPos = CameraPosition(target: LatLng((latMin + latMax) / 2, (lonMin + lonMax) / 2), zoom: 12);
      }
    } catch (e) {
      debugPrint('ViewLocation error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route to Driver'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialPos,
              markers: {
                if (_userMarker != null) _userMarker!,
                if (_driverMarker != null) _driverMarker!,
              },
              polylines: {
                if (_route != null) _route!,
              },
              onMapCreated: (c) {
                _mapController = c;
                // attempt to move camera to bounds if route exists
                // (safe-guard with try/catch)
                try {
                  if (_route != null && _route!.points.isNotEmpty) {
                    final points = _route!.points;
                    double south = points.first.latitude, north = points.first.latitude, west = points.first.longitude, east = points.first.longitude;
                    for (final p in points) {
                      if (p.latitude < south) south = p.latitude;
                      if (p.latitude > north) north = p.latitude;
                      if (p.longitude < west) west = p.longitude;
                      if (p.longitude > east) east = p.longitude;
                    }
                    final bounds = LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east));
                    c.moveCamera(CameraUpdate.newLatLngBounds(bounds, 60));
                  }
                } catch (_) {}
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              },
            ),
    );
  }
}
