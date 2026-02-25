// rental_tab.dart
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';

/// Replace with your real keys
const String GOOGLE_MAPS_API_KEY = "YOUR_API_KEY";
const String RAZORPAY_KEY_PLACEHOLDER = "your_razorpay_placeholder";

/// A widget that is safe to embed inside your page (does NOT return a Scaffold).
/// Use it like: _selectedMainTab == 1 ? const RentalTab() : ...
class RentalTab extends StatefulWidget {
  const RentalTab({super.key});

  @override
  State<RentalTab> createState() => _RentalTabState();
}

class _RentalTabState extends State<RentalTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _loading = true;

  /// vehicles: each item: {
  ///   'driverEmail': driverDocId,
  ///   'vehicleRef': DocumentReference,
  ///   'vehicleName': vehicleDocId,
  ///   'data': Map<String,dynamic>
  /// }
  List<Map<String, dynamic>> _vehicles = [];

  /// user requests keyed by vehicleRef.path -> entry {
  ///   'vehicleRef', 'requestRef', 'driverEmail', 'vehicleName', 'data'
  /// }
  final Map<String, Map<String, dynamic>> _userRequests = {};

  final List<StreamSubscription> _requestSubs = [];

  late Razorpay _razorpay;
  Map<String, dynamic>? _pendingPaymentContext;

  /// keep controllers per vehicle so bottomsheet form values persist while the sheet is open
  final Map<String, Map<String, TextEditingController>> _formControllers = {};

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllVehicles();
    });
  }

  @override
  void dispose() {
    for (final s in _requestSubs) {
      try {
        s.cancel();
      } catch (_) {}
    }
    _razorpay.clear();
    for (final map in _formControllers.values) {
      for (final c in map.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _fetchAllVehicles() async {
    setState(() => _loading = true);
    try {
      final driversSnap = await _firestore.collection('Rental Driver').get();
      final List<Map<String, dynamic>> vehicles = [];
      for (final d in driversSnap.docs) {
        try {
          final vehicleSnap = await d.reference.collection('vehicle').get();
          for (final vdoc in vehicleSnap.docs) {
            vehicles.add({
              'driverEmail': d.id,
              'vehicleRef': vdoc.reference,
              'vehicleName': vdoc.id,
              'data': vdoc.data(),
            });
          }
        } catch (e) {
          debugPrint('Error reading vehicle subcollection for ${d.id}: $e');
        }
      }
      setState(() {
        _vehicles = vehicles;
      });

      // start listening to user's rentalRequests for each vehicle
      await _startListeningUserRequests();
    } catch (e) {
      debugPrint('Error fetching vehicles: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _startListeningUserRequests() async {
    // cancel previous
    for (final s in _requestSubs) {
      try {
        s.cancel();
      } catch (_) {}
    }
    _requestSubs.clear();
    _userRequests.clear();

    final user = _auth.currentUser;
    final userEmail = (user?.email ?? user?.uid ?? 'unknown_user').toString();

    for (final v in _vehicles) {
      final vref = v['vehicleRef'] as DocumentReference;
      final driverEmail = v['driverEmail'] as String;
      final vehicleName = v['vehicleName'] as String;

      final reqDoc = vref.collection('rentalRequests').doc(userEmail);
      final sub = reqDoc.snapshots().listen((snap) {
        if (!mounted) return;
        if (snap.exists) {
          final data = snap.data() ?? {};
          _userRequests[vref.path] = {
            'vehicleRef': vref,
            'requestRef': reqDoc,
            'driverEmail': driverEmail,
            'vehicleName': vehicleName,
            'data': data,
          };
        } else {
          _userRequests.remove(vref.path);
        }
        setState(() {});
      }, onError: (e) {
        debugPrint('rental request listen error: $e');
      });
      _requestSubs.add(sub);
    }
  }

  /// Open the bottom sheet for the selected vehicle.
  /// Controllers are kept in the _formControllers map so that the content doesn't "vanish".
  void _openRentalBottomSheet(Map<String, dynamic> vehicle) {
    final vref = vehicle['vehicleRef'] as DocumentReference;
    final key = vref.path;

    // create controllers if not exist
    _formControllers.putIfAbsent(key, () => {
          'startDate': TextEditingController(),
          'endDate': TextEditingController(),
          'startTime': TextEditingController(),
          'endTime': TextEditingController(),
          'duration': TextEditingController(),
          'pickup': TextEditingController(),
          'license': TextEditingController(),
          'amount': TextEditingController(text: (vehicle['data']?['rentPerDay']?.toString() ?? '100')),
        });

    final ctrls = _formControllers[key]!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        // Use a StatefulBuilder inside bottom sheet so we can setState locally if needed.
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.82,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Rent ${vehicle['vehicleName']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () => Navigator.of(ctx).pop(), icon: const Icon(Icons.close)),
                      ]),
                      const SizedBox(height: 12),
                      // Dates
                      Row(children: [
                        Expanded(child: _buildFormField('Start Date', ctrls['startDate']!, hint: 'dd-mm-yyyy')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFormField('End Date', ctrls['endDate']!, hint: 'dd-mm-yyyy')),
                      ]),
                      const SizedBox(height: 12),
                      Row(children: [
                        Expanded(child: _buildFormField('Start Time', ctrls['startTime']!, hint: 'HH:MM')),
                        const SizedBox(width: 12),
                        Expanded(child: _buildFormField('End Time', ctrls['endTime']!, hint: 'HH:MM')),
                      ]),
                      const SizedBox(height: 12),
                      _buildFormField('Duration (hours)', ctrls['duration']!, keyboardType: TextInputType.number),
                      const SizedBox(height: 12),
                      _buildFormField('Pickup Location', ctrls['pickup']!),
                      const SizedBox(height: 12),
                      _buildFormField('Driver License Number', ctrls['license']!),
                      const SizedBox(height: 12),
                      _buildFormField('Amount (INR)', ctrls['amount']!, keyboardType: TextInputType.number),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel'))),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final user = _auth.currentUser;
                                final userEmail = (user?.email ?? user?.uid ?? 'unknown_user').toString();
                                final otp = (Random().nextInt(9000) + 1000).toString();

                                final payload = {
                                  'userEmail': userEmail,
                                  'vehicleName': vehicle['vehicleName'],
                                  'driverEmail': vehicle['driverEmail'],
                                  'startDate': ctrls['startDate']!.text.trim(),
                                  'endDate': ctrls['endDate']!.text.trim(),
                                  'startTime': ctrls['startTime']!.text.trim(),
                                  'endTime': ctrls['endTime']!.text.trim(),
                                  'duration': ctrls['duration']!.text.trim(),
                                  'pickup': ctrls['pickup']!.text.trim(),
                                  'licenseNumber': ctrls['license']!.text.trim(),
                                  'amount': int.tryParse(ctrls['amount']!.text.trim()) ?? 100,
                                  'status': 'pending',
                                  'otp': otp,
                                  'paymentStatus': 'pending',
                                  'timestamp': FieldValue.serverTimestamp(),
                                };

                                try {
                                  await vref.collection('rentalRequests').doc(payload['userEmail']).set(payload, SetOptions(merge: true));
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rental request created')));
                                  Navigator.of(ctx).pop();
                                } catch (e) {
                                  debugPrint('Error creating rental request: $e');
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14.0),
                                child: Text('Confirm Rental', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField(String label, TextEditingController ctrl, {String hint = '', TextInputType keyboardType = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label),
      const SizedBox(height: 6),
      TextField(controller: ctrl, decoration: InputDecoration(hintText: hint), keyboardType: keyboardType),
    ]);
  }

  Future<void> _viewDriverLocation(String driverEmail) async {
    // Push new page that shows route from user's current location -> driver's lat/lng stored in Rental Driver/{driverEmail}
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewLocationPage(driverEmail: driverEmail)));
  }

  Future<void> _payNowForRequest(Map<String, dynamic> entry) async {
    // entry has 'requestRef' and 'data'
    final data = entry['data'] as Map<String, dynamic>;
    final amount = (data['amount'] is num) ? (data['amount'] as num).toInt() : (int.tryParse((data['amount'] ?? '100').toString()) ?? 100);
    _pendingPaymentContext = entry;
    _openRazorpayCheckout(amountINR: amount);
  }

  void _openRazorpayCheckout({required int amountINR}) {
    final options = {
      'key': RAZORPAY_KEY_PLACEHOLDER,
      'amount': amountINR * 100,
      'name': 'Rental Payment',
      'description': 'Pay for rental',
      'prefill': {'contact': _auth.currentUser?.phoneNumber ?? '', 'email': _auth.currentUser?.email ?? ''},
      'external': {'wallets': ['paytm']}
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay open error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment open error: $e')));
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;
    try {
      if (_pendingPaymentContext != null) {
        final requestRef = _pendingPaymentContext!['requestRef'] as DocumentReference?;
        if (requestRef != null) {
          await requestRef.set({
            'status': 'completed',
            'paymentStatus': 'completed',
            'paymentId': response.paymentId,
            'paymentTimestamp': FieldValue.serverTimestamp()
          }, SetOptions(merge: true));
        }
      }
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful')));
    } catch (e) {
      debugPrint('Error updating payment status: $e');
    } finally {
      _pendingPaymentContext = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: ${response.message}')));
    _pendingPaymentContext = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('External wallet: ${response.walletName}')));
  }

  String _vehicleSubtitle(Map<String, dynamic> vdata) {
    final vtype = (vdata['vehicleType'] ?? vdata['type'] ?? '').toString();
    final number = (vdata['vehicleNumber'] ?? vdata['number'] ?? '').toString();
    return '$vtype ${number.isNotEmpty ? "• $number" : ""}';
  }

  @override
  Widget build(BuildContext context) {
    // This widget is intended to be embedded inside another scrollable page;
    // so we return a Column with internal ListViews that are shrinkWrapped.
    return _loading
        ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Available Rental Vehicles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_vehicles.length} vehicles', style: const TextStyle(color: Colors.grey)),
              ]),
              const SizedBox(height: 12),
              _vehicles.isEmpty
                  ? const Text('No vehicles available')
                  : ListView.separated(
                      itemBuilder: (ctx, i) {
                        final v = _vehicles[i];
                        final vdata = v['data'] ?? {};
                        final image = (vdata['vehicleImage'] ?? vdata['imageUrl'] ?? '').toString();
                        // Build card in the style you provided
                        return Card(
                          color: const Color.fromARGB(255, 241, 238, 238),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    image.isNotEmpty
                                        ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(image, width: 80, height: 80, fit: BoxFit.cover))
                                        : Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.directions_car)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(v['vehicleName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 6),
                                          Text(_vehicleSubtitle(vdata), style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                                          const SizedBox(height: 6),
                                          Row(children: [
                                            const Icon(Icons.star, color: Colors.amber, size: 16),
                                            Text(' ${(vdata['rating'] ?? 4.8).toString()}'),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.person, size: 16),
                                            Text(' ${vdata['capacity'] ?? 4}'),
                                          ]),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('₹${vdata['rentPerDay'] ?? vdata['rentDay'] ?? '—'}/day', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 12),
                                        ElevatedButton(
                                          onPressed: () => _openRentalBottomSheet(v),
                                          child: const Text('Take it on Rent'),
                                          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40), backgroundColor: const Color.fromARGB(255, 118, 123, 207)),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if ((vdata['features'] as List<dynamic>?)?.isNotEmpty ?? false)
                                  Wrap(
                                    spacing: 8,
                                    children: List<Widget>.from(((vdata['features'] as List<dynamic>) ?? []).map((f) => Chip(label: Text(f.toString())))),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _vehicles.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
              const SizedBox(height: 20),
              const Text('Requested Vehicles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _userRequests.isEmpty
                  ? const Text('No requests yet')
                  : ListView.separated(
                      itemBuilder: (ctx, i) {
                        final key = _userRequests.keys.elementAt(i);
                        final entry = _userRequests[key]!;
                        final data = entry['data'] as Map<String, dynamic>;
                        final status = (data['status'] ?? 'pending').toString();
                        final otp = (data['otp'] ?? '').toString();
                        final driverEmail = entry['driverEmail'] as String;
                        final vehicleName = entry['vehicleName'] as String;
                        final requestRef = entry['requestRef'] as DocumentReference;

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Text(vehicleName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const Spacer(),
                                Chip(label: Text(status.toUpperCase())),
                              ]),
                              const SizedBox(height: 6),
                              Text('From: ${data['pickup'] ?? '—'}'),
                              Text('To: ${data['destination'] ?? data['vehicleName'] ?? '—'}'),
                              const SizedBox(height: 8),
                              if (status == 'accepted' && otp.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                  child: Text('OTP: $otp', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              const SizedBox(height: 8),
                              Row(children: [
                                ElevatedButton(
                                  onPressed: () => _viewDriverLocation(driverEmail),
                                  child: const Text('View Location'),
                                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: status == 'accepted' ? () => _payNowForRequest(entry) : null,
                                  child: Text(status == 'completed' ? 'Paid' : 'Pay Now'),
                                  style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40), backgroundColor: const Color.fromARGB(255, 170, 224, 243)),
                                ),
                                const Spacer(),
                                Text('₹${data['amount'] ?? '—'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ]),
                              const SizedBox(height: 8),
                              // small action row for debug / cancel
                              Row(children: [
                                TextButton(
                                  onPressed: () async {
                                    // Cancel request (set status 'no')
                                    try {
                                       final user = _auth.currentUser;
                                      await requestRef.set({'status': 'no', 'otp': 'no'}, SetOptions(merge: true));
                                      await FirebaseFirestore.instance
        .collection('Rental Driver')
        .doc(driverEmail)
        .collection('vehicle')
        .doc(vehicleName)
        .collection('rentalRequests')
        .doc((user?.email ?? user?.uid ?? 'unknown_user').toString())
        .delete();
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request cancelled')));
                                    } catch (e) {
                                      debugPrint('Cancel error: $e');
                                    }
                                  },
                                  child: const Text('Cancel Request'),
                                ),
                              ]),
                            ]),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _userRequests.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
              const SizedBox(height: 16),
            ],
          );
  }
}

/// Full-screen page that shows a Google Map with polyline from user's current location to driver's location.
/// It fetches driver's lat/lng from 'Rental Driver/{driverEmail}' document fields 'latitude' and 'longitude' (or 'lat'/'lng').
class ViewLocationPage extends StatefulWidget {
  final String driverEmail;
  const ViewLocationPage({required this.driverEmail, super.key});

  @override
  State<ViewLocationPage> createState() => _ViewLocationPageState();
}

class _ViewLocationPageState extends State<ViewLocationPage> {
  GoogleMapController? _mapController;
  Marker? _userMarker;
  Marker? _driverMarker;
  Polyline? _routePolyline;
  CameraPosition _initialCamera = const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5.0);
  bool _loading = true;
  StreamSubscription<Position>? _posSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _driverDocSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _driverDocSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await _ensureLocationPermission();
    await _setupUserPosition();
    await _startDriverDocListener();
    setState(() => _loading = false);
  }

  Future<void> _ensureLocationPermission() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    } catch (e) {
      debugPrint('Location permission error: $e');
    }
  }

  Future<void> _setupUserPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      final latlng = LatLng(pos.latitude, pos.longitude);
      _userMarker = Marker(markerId: const MarkerId('user_marker'), position: latlng, infoWindow: const InfoWindow(title: 'You'));
      _initialCamera = CameraPosition(target: latlng, zoom: 13.0);

      _posSub = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 10)).listen((p) {
        if (!mounted) return;
        final latlng2 = LatLng(p.latitude, p.longitude);
        setState(() {
          _userMarker = Marker(markerId: const MarkerId('user_marker'), position: latlng2, infoWindow: const InfoWindow(title: 'You'));
        });
        _updateRouteIfPossible();
      });
    } catch (e) {
      debugPrint('Failed to get user position: $e');
    }
  }

  Future<void> _startDriverDocListener() async {
    final docRef = FirebaseFirestore.instance.collection('Rental Driver').doc(widget.driverEmail);
    _driverDocSub = docRef.snapshots().listen((snap) async {
      if (!mounted) return;
      if (!snap.exists) return;
      final dd = snap.data() ?? {};
      double? lat;
      double? lng;
      try {
        final rawLat = dd['latitude'] ?? dd['lat'] ?? dd['location']?['latitude'];
        final rawLng = dd['longitude'] ?? dd['lng'] ?? dd['location']?['longitude'];
        if (rawLat != null) lat = (rawLat is num) ? rawLat.toDouble() : double.tryParse(rawLat.toString());
        if (rawLng != null) lng = (rawLng is num) ? rawLng.toDouble() : double.tryParse(rawLng.toString());
      } catch (e) {
        debugPrint('Driver lat parse error: $e');
      }
      if (lat != null && lng != null) {
        setState(() {
          _driverMarker = Marker(markerId: const MarkerId('driver_marker'), position: LatLng(lat!, lng!), infoWindow: const InfoWindow(title: 'Driver'));
        });
        _updateRouteIfPossible();
        // move camera to show both
        if (_mapController != null) {
          final bounds = _getBoundsForMarkers([_userMarker, _driverMarker]);
          if (bounds != null) {
            try {
              _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
            } catch (_) {}
          }
        }
      }
    }, onError: (e) {
      debugPrint('driver doc listen error: $e');
    });
  }

  LatLngBounds? _getBoundsForMarkers(List<Marker?> markers) {
    final coords = markers.where((m) => m != null).map((m) => m!.position).toList();
    if (coords.isEmpty) return null;
    double south = coords.first.latitude, north = coords.first.latitude, west = coords.first.longitude, east = coords.first.longitude;
    for (final c in coords) {
      if (c.latitude < south) south = c.latitude;
      if (c.latitude > north) north = c.latitude;
      if (c.longitude < west) west = c.longitude;
      if (c.longitude > east) east = c.longitude;
    }
    return LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east));
  }

  Future<void> _updateRouteIfPossible() async {
    if (_userMarker == null || _driverMarker == null) return;
    final a = _userMarker!.position;
    final b = _driverMarker!.position;

    // If GOOGLE_MAPS_API_KEY provided, call Directions; otherwise draw straight line
    if (GOOGLE_MAPS_API_KEY.isEmpty) {
      setState(() {
        _routePolyline = Polyline(polylineId: const PolylineId('route'), points: [a, b], width: 5);
      });
      return;
    }

    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${a.latitude},${a.longitude}&destination=${b.latitude},${b.longitude}&key=$GOOGLE_MAPS_API_KEY&mode=driving');
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        final routes = body['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final overview = routes.first['overview_polyline']?['points'] as String?;
          if (overview != null) {
            final decoded = _decodePolyline(overview);
            setState(() {
              _routePolyline = Polyline(polylineId: const PolylineId('route'), points: decoded, width: 5);
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
      setState(() {
        _routePolyline = Polyline(polylineId: const PolylineId('route'), points: [a, b], width: 5);
      });
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
      appBar: AppBar(title: const Text('Driver Location'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCamera,
                  onMapCreated: (c) => _mapController = c,
                  markers: {
                    if (_userMarker != null) _userMarker!,
                    if (_driverMarker != null) _driverMarker!,
                  },
                  polylines: {
                    if (_routePolyline != null) _routePolyline!,
                  },
                  myLocationEnabled: false,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_driverMarker != null ? 'Driver: ${widget.driverEmail}' : 'Finding driver location...')),
                        IconButton(
                          onPressed: () {
                            // Fit to bounds
                            final bounds = _getBoundsForMarkers([_userMarker, _driverMarker]);
                            if (bounds != null && _mapController != null) {
                              try {
                                _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
                              } catch (_) {}
                            }
                          },
                          icon: const Icon(Icons.fullscreen),
                        )
                      ]),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}
