


// full BookRideScreen.dart (single file)
// Paste/replace your existing file with this content.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'rental.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

// --- CONFIG ---
// Put your Google Maps + Directions + Geocoding API key here. If empty, route/ETA/geocoding will fall back to OSM/simple methods.
const String GOOGLE_MAPS_API_KEY = "AIzaSyC-d7WK6cZDT0RIbWhnwGjRLkrKPR3IPCY";

/// Distance threshold (meters) to consider "arrived" at pickup/destination (original small threshold)
const double ARRIVAL_THRESHOLD_METERS = 50.0;

/// Driver OTP arrival threshold (meters). Per your request, be forgiving (e.g. up to 500m considered "arrived" for OTP prompt).
const double DRIVER_ARRIVAL_THRESHOLD_METERS = 500.0;



// ----------------- Existing data models (unchanged) -----------------

class RideOption {
  final String title;
  final String description;
  final String priceRange;
  final String eta;
  final double rating;
  final int capacity;
  final String imageUrl;
  final List<String>? tags;
  final DocumentReference? docRef; // Firestore ref for the vehicle doc (Rental Driver/{driverEmail}/vehicle/{vehicleName})

  RideOption({
    required this.title,
    required this.description,
    required this.priceRange,
    required this.eta,
    required this.rating,
    required this.capacity,
    required this.imageUrl,
    this.tags,
    this.docRef,
  });
}

class RentalVehicle {
  final String name;
  final String type;
  final double rating;
  final int capacity;
  final int pricePerDay;
  final String imageUrl;
  final List<String> features;

  RentalVehicle({
    required this.name,
    required this.type,
    required this.rating,
    required this.capacity,
    required this.pricePerDay,
    required this.imageUrl,
    required this.features,
  });
}

enum RideState {
  initial,
  confirmingPickup,
  selectingRide,
  confirmingRide,
  findingDriver,
  driverFound,
  driverArriving,
  driverArrived,
}

// ----------------- App -----------------



class BookRideScreen extends StatefulWidget {
  const BookRideScreen({super.key});
  @override
  _BookRideScreenState createState() => _BookRideScreenState();
}

class _BookRideScreenState extends State<BookRideScreen> {
  // --- UI / state fields (same as your original) ---
  int _selectedMainTab = 0;
  RideState _rideState = RideState.initial;
  RideOption? _selectedRide;
  Timer? _driverStatusTimer;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Listener to the rideRequests/{userEmail} doc for the currently selected vehicle
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _rideRequestListener;
  Map<String, dynamic>? _currentRideRequestData;
  Map<String, dynamic>? _currentVehicleDocData;

  // NEW: listener to the driver's parent doc for live lat/lng updates
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _driverDocListener;

  // NEW: user position stream when on active trip
  StreamSubscription<Position>? _userPositionStream;

  // Location controllers & suggestions
  final TextEditingController _pickupController = TextEditingController(text: '');
  final TextEditingController _destController = TextEditingController(text: '');
  List<Map<String, dynamic>> _pickupSuggestions = [];
  List<Map<String, dynamic>> _destSuggestions = [];
  Timer? _pickupDebounce;
  Timer? _destDebounce;
  bool _showPickupSuggestions = false;
  bool _showDestSuggestions = false;

  // store lat/lng selected (from OSM suggestion / geocoding)
  double? _pickupLat;
  double? _pickupLng;
  double? _destLat;
  double? _destLng;

  // Map + route state
  GoogleMapController? _mapController;
  Marker? _driverMarker;
  Marker? _pickupMarker;
  Marker? _destMarker;
  Marker? _userMarker; // user current position while on trip
  Polyline? _routePolyline;
  String _etaText = '';
  String _distanceText = '';

  // Available vehicles fetched dynamically
  List<RideOption> _availableVehicles = [];

  // Rental vehicles (unchanged)
  final List<RentalVehicle> _rentalVehicles = [
    RentalVehicle(
      name: 'Toyota Camry',
      type: 'Sedan • Automatic',
      rating: 4.8,
      capacity: 5,
      pricePerDay: 45,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_bj2l5uaY5JZNZZEHwwaMrsooDX75vN1vSQ&s',
      features: ['AC', 'GPS', 'Bluetooth', '4 doors'],
    ),
    RentalVehicle(
      name: 'Honda CR-V',
      type: 'SUV • Automatic',
      rating: 4.9,
      capacity: 7,
      pricePerDay: 65,
      imageUrl: 'https://placehold.co/100x100/4CAF50/FFFFFF?text=CRV',
      features: ['AWD', 'AC', 'GPS', 'Spacious', '5 doors'],
    ),
    RentalVehicle(
      name: 'Nissan Versa',
      type: 'Compact • Manual',
      rating: 4.7,
      capacity: 4,
      pricePerDay: 35,
      imageUrl: 'https://placehold.co/100x100/2196F3/FFFFFF?text=VER',
      features: ['Fuel efficient', 'AC', 'Compact', 'Easy parking'],
    ),
  ];

  // Map/fallback defaults
  late CameraPosition _initialCameraPosition;
  bool _hasLocationPermission = false;

  // NEW: on trip mode flag — when true we render the full-screen trip map
  bool _onTripMode = false;

  // NEW: razorpay instance
  late Razorpay _razorpay;

  // Avoid showing OTP multiple times
  bool _hasShownOtpDialog = false;

  @override
  void initState() {
    super.initState();
    // initial fallback camera (India center) to avoid null initialCameraPosition
    _initialCameraPosition = const CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5.0);
    _ensureLocationPermissionAndPosition();
    // Fetch vehicles on startup from Rental Driver -> vehicle subcollections
    _fetchAllVehiclesFromFirestore();

    // initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _driverStatusTimer?.cancel();
    _pickupDebounce?.cancel();
    _destDebounce?.cancel();
    _pickupController.dispose();
    _destController.dispose();
    _rideRequestListener?.cancel();
    _driverDocListener?.cancel();
    _userPositionStream?.cancel();
    _mapController?.dispose();
    _razorpay.clear();
    super.dispose();
  }

  // ------------------ Location permission & initial position ------------------

  Future<void> _ensureLocationPermissionAndPosition() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever || perm == LocationPermission.denied) {
        // can't get permission; keep fallback initial camera
        setState(() => _hasLocationPermission = false);
        return;
      }
      setState(() => _hasLocationPermission = true);

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      _initialCameraPosition = CameraPosition(target: LatLng(pos.latitude, pos.longitude), zoom: 14.0);
      // animate map if already created
      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newCameraPosition(_initialCameraPosition));
      }
    } catch (e) {
      debugPrint("Location permission/position error: $e");
    }
  }

  // ------------------ Flow methods (modified) ------------------

  Future<void> _searchRides() async {
    setState(() => _rideState = RideState.confirmingPickup);
    await _fetchAllVehiclesFromFirestore();
  }

  void _confirmPickup() => setState(() => _rideState = RideState.selectingRide);

  void _selectRide(RideOption ride) => setState(() {
        _selectedRide = ride;
        _rideState = RideState.confirmingRide;
      });

  /// When selecting a DB-backed vehicle, create the rideRequests/{userEmail} doc
  /// under that vehicle document:
  /// Rental Driver/{driverEmail}/vehicle/{vehicleName}/rideRequests/{userEmail}
  Future<void> _selectVehicleFromDB(RideOption ride) async {
    try {
      // get current user email (document id)
      final user = _auth.currentUser;
      final userEmail = (user?.email ?? user?.uid ?? 'unknown_user').toString();

      if (ride.docRef != null) {
        // generate OTP
        final otp = (Random().nextInt(9000) + 1000).toString();

        // ride.docRef points to: Rental Driver/{driverEmail}/vehicle/{vehicleName}
        // so collection('rideRequests').doc(userEmail) is the correct path
        final requestDocRef = ride.docRef!.collection('rideRequests').doc(userEmail);

        // write the request with default status = 'pending'
        await requestDocRef.set({
          'status': 'pending', // default as you requested
          'otp': otp,
          'trip': 'no',
          'pickup_location': _pickupController.text,
          'destination_location': _destController.text,
          'timestamp': FieldValue.serverTimestamp(),
          // driverEmail will be set by driver app when accepting (optional)
        }, SetOptions(merge: true));

        // start listening for this rideRequest doc for status updates
        _startRideRequestListener(ride, userEmail);
      }
    } catch (e) {
      debugPrint("Error writing ride request subdoc: $e");
    }

    // go to confirmation UI
    _selectRide(ride);
  }

  void _bookNow() {
    // if DB-backed, just set state; listener will handle further updates
    if (_selectedRide?.docRef != null) {
      setState(() => _rideState = RideState.findingDriver);
      return;
    }

    // fallback simulated behavior when not DB-backed
    setState(() => _rideState = RideState.findingDriver);
    _driverStatusTimer = Timer(const Duration(seconds: 3), () {
      setState(() => _rideState = RideState.driverFound);
      _driverStatusTimer = Timer(const Duration(seconds: 3), () {
        setState(() => _rideState = RideState.driverArriving);
        _driverStatusTimer = Timer(const Duration(seconds: 4), () {
          setState(() => _rideState = RideState.driverArrived);
        });
      });
    });
  }

  Future<void> _cancelRide() async {
    _driverStatusTimer?.cancel();

    try {
      final user = _auth.currentUser;
      final userEmail = (user?.email ?? user?.uid ?? 'unknown_user').toString();

      if (_selectedRide?.docRef != null) {
        // set ride request status to 'no' on cancel
        final requestDocRef = _selectedRide!.docRef!.collection('rideRequests').doc(userEmail);
        await requestDocRef.set({
          'status': 'no',
          'otp': 'no',
          'trip': 'no',
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Error while canceling ride in Firestore: $e");
    }

    // cancel listener and reset map & UI
    await _rideRequestListener?.cancel();
    _rideRequestListener = null;
    await _driverDocListener?.cancel();
    _driverDocListener = null;
    _currentRideRequestData = null;
    _currentVehicleDocData = null;
    _clearMap();
    _stopUserPositionStream();

    setState(() {
      _rideState = RideState.initial;
      _selectedRide = null;
      _onTripMode = false;
    });
  }

  void _showRentalModal(RentalVehicle vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(0, 255, 252, 252),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => _buildRentalForm(vehicle, controller),
      ),
    );
  }

  // ------------------ Firestore vehicle fetch & rideRequest listener ------------------

  /// Fetch all vehicles by iterating through every document in the
  /// 'Rental Driver' collection and reading its 'vehicle' subcollection.
  /// This produces vehicles from all drivers (no hardcoding).
  Future<void> _fetchAllVehiclesFromFirestore() async {
    try {
      final driversSnap = await _firestore.collection('Rental Driver').get();

      List<RideOption> vehicles = [];

      // iterate each driver document
      for (final driverDoc in driversSnap.docs) {
        try {
          // each driver has a 'vehicle' subcollection
          final vehicleSnap = await driverDoc.reference.collection('vehicle').get();
          for (final vdoc in vehicleSnap.docs) {
            final data = vdoc.data();

            // vehicle title: prefer stored vehicleName else use the vehicle doc id (vehicleName)
            final title = (data['vehicleName'] ?? vdoc.id ?? 'Vehicle') as String;
            final type = (data['vehicleType'] ?? data['type'] ?? 'Unknown') as String;
            final number = (data['vehicleNumber'] ?? data['number'] ?? '') as String;
            final rentHour = (data['rentPerHour'] ?? data['rentHour'] ?? '');
            final rentDay = (data['rentPerDay'] ?? data['rentDay'] ?? '');
            final priceRange = rentHour != '' ? '₹$rentHour/hr' : (rentDay != '' ? '₹$rentDay/day' : 'Price N/A');
            final imageUrl = data['imageUrl'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_bj2l5uaY5JZNZZEHwwaMrsooDX75vN1vSQ&s';

            final description = '$type ${number.isNotEmpty ? "• $number" : ""}';

            // IMPORTANT: we store vdoc.reference which points to:
            // Rental Driver/{driverEmail}/vehicle/{vehicleName}
            vehicles.add(RideOption(
              title: title,
              description: description,
              priceRange: priceRange,
              eta: '5 min',
              rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 4.5,
              capacity: (data['capacity'] is int) ? data['capacity'] as int : 4,
              imageUrl: imageUrl,
              docRef: vdoc.reference,
            ));
          }
        } catch (e) {
          debugPrint("Error reading vehicle subcollection for driver ${driverDoc.id}: $e");
        }
      }

      setState(() {
        _availableVehicles = vehicles;
      });
    } catch (e) {
      debugPrint("Error fetching drivers/vehicles from Firestore: $e");
      setState(() {
        _availableVehicles = [];
      });
    }
  }

  /// Start listening to the selected vehicle's rideRequests/{userEmail} doc for live updates.
  /// Note: ride.docRef points to Rental Driver/{driverEmail}/vehicle/{vehicleName}
  void _startRideRequestListener(RideOption ride, String userEmail) {
    _rideRequestListener?.cancel();
    _rideRequestListener = null;
    _currentRideRequestData = null;
    _currentVehicleDocData = null;

    if (ride.docRef == null) return;

    final requestDocRef = ride.docRef!.collection('rideRequests').doc(userEmail);

    _rideRequestListener = requestDocRef
        .snapshots()
        .cast<DocumentSnapshot<Map<String, dynamic>>>()
        .listen((snap) async {
      if (!mounted) return;
      if (!snap.exists) return;

      final data = snap.data() ?? {};
      _currentRideRequestData = data;

      // fetch the vehicle doc too (if you want meta data like rating / vehicleNumber)
      try {
        final vehicleSnap = await ride.docRef!.get();
        if (vehicleSnap.exists) {
          _currentVehicleDocData = vehicleSnap.data() as Map<String, dynamic>?;
        }
      } catch (e) {
        debugPrint("Error fetching vehicle doc: $e");
      }

      final statusVal = (data['status'] ?? 'no').toString();
      final tripVal = (data['trip'] ?? 'no').toString();
      final otpVal = (data['otp'] ?? 'no').toString();

      // When accepted -> show driver card and fetch driver-pickup route
      if (statusVal == 'accepted') {
        setState(() {
          _rideState = RideState.driverFound;
        });

        // Determine driverEmail. First try driver's email written into the rideRequest doc by the driver app.
        String? driverEmail = data['driverEmail']?.toString();

        // If not present, derive driverEmail from the vehicle docRef parent chain:
        // ride.docRef is Rental Driver/{driverEmail}/vehicle/{vehicleName}
        // so parent.parent is the driver doc reference
        try {
          final driverDocRef = ride.docRef!.parent.parent;
          if (driverDocRef != null && (driverEmail == null || driverEmail.isEmpty)) {
            driverEmail = driverDocRef.id; // driver doc id = driverEmail as you said
          }
        } catch (e) {
          debugPrint("Error deriving driverDocRef: $e");
        }

        // Fetch pickup coordinates via geocoding only if not already present
        if (_pickupLat == null || _pickupLng == null) {
          final pickupText = data['pickup_location']?.toString() ?? _pickupController.text;
          if (pickupText.isNotEmpty) {
            try {
              final coords = await _geocodeAddress(pickupText);
              if (coords != null) {
                _pickupLat = coords.latitude;
                _pickupLng = coords.longitude;
                _pickupMarker = Marker(markerId: const MarkerId('pickup'), position: LatLng(_pickupLat!, _pickupLng!), infoWindow: const InfoWindow(title: 'Pickup'));
              }
            } catch (e) {
              debugPrint("Geocode error: $e");
            }
          }
        }

        // Start a live listener on the driver's document to track lat/lng changes
        if (driverEmail != null && driverEmail.isNotEmpty) {
          _startDriverDocListener(driverEmail, ride, userEmail);
        } else {
          debugPrint("Driver email not found in ride request doc or vehicle docRef.");
        }
      } else if (statusVal == 'rejected') {
        // driver rejected: notify user and reset
        await _rideRequestListener?.cancel();
        _rideRequestListener = null;

        // optional: reset the request doc fields server-side
        try {
          await requestDocRef.set({'status': 'no', 'otp': 'no', 'trip': 'no'}, SetOptions(merge: true));
        } catch (_) {}

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Ride unavailable'),
            content: const Text('This ride is not available.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  setState(() {
                    _rideState = RideState.initial;
                    _selectedRide = null;
                    _clearMap();
                  });
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        // pending or no or other statuses
        if (statusVal == 'pending') {
          setState(() => _rideState = RideState.findingDriver);
        } else {
          // status 'no' or canceled => reset UI
          await _rideRequestListener?.cancel();
          _rideRequestListener = null;
          await _driverDocListener?.cancel();
          _driverDocListener = null;
          setState(() {
            _rideState = RideState.initial;
            _selectedRide = null;
            _currentRideRequestData = null;
            _currentVehicleDocData = null;
            _clearMap();
          });
        }
      }

      // If trip started by driver or OTP verification and trip changed to 'start' -> start on-trip mode
      if (tripVal == 'start') {
        // Prepare destination coordinates (geocode if needed)
        final destText = (data['destination_location']?.toString() ?? _destController.text);
        if ((destText.isNotEmpty) && (_destLat == null || _destLng == null)) {
          try {
            final destCoords = await _geocodeAddress(destText);
            if (destCoords != null) {
              _destLat = destCoords.latitude;
              _destLng = destCoords.longitude;
              _destMarker = Marker(markerId: const MarkerId('dest'), position: LatLng(_destLat!, _destLng!), infoWindow: const InfoWindow(title: 'Destination'));
            }
          } catch (e) {
            debugPrint("Geocoding destination error: $e");
          }
        }

        // Enter on-trip mode: show map only and start tracking user location
        setState(() {
          _onTripMode = true;
        });

        // Stop driver doc listener; during trip we mostly need user movement
        await _driverDocListener?.cancel();
        _driverDocListener = null;

        // Remove pickup & driver markers (we only want user & destination during trip)
        _removePickupAndDriverMarkers();

        // start listening to user position and show route from user->destination
        _startUserPositionStream(ride.docRef!, userEmail);
      }

      // If driver location present and pickup & driver present: compute ETA/distance for driver -> pickup
      if ((_driverMarker != null) && (_pickupLat != null && _pickupLng != null) && !_onTripMode) {
        await _updateEtaAndDistance(_driverMarker!.position, LatLng(_pickupLat!, _pickupLng!));
        // ALSO draw polyline driver -> pickup (only when NOT on trip)
        await _fetchAndShowRoute(_driverMarker!.position, LatLng(_pickupLat!, _pickupLng!));
      }

      // Check final destination arrival when trip started: if driver near destination -> mark complete
      if (tripVal == 'start' && _driverMarker != null && _destLat != null && _destLng != null) {
        final distToDest = _computeDistanceMeters(_driverMarker!.position, LatLng(_destLat!, _destLng!));
        if (distToDest <= ARRIVAL_THRESHOLD_METERS) {
          // Mark completed (driver arrived at destination)
          try {
            await requestDocRef.set({
              'status': 'completed',
              'otp': 'no',
              'trip': 'completed',
            }, SetOptions(merge: true));
          } catch (e) {
            debugPrint("Error setting completed: $e");
          }

          if (!mounted) return;
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Ride Completed'),
              content: const Text('Your ride is completed.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _rideState = RideState.initial;
                      _selectedRide = null;
                      _clearMap();
                      _onTripMode = false;
                    });
                    // Optionally trigger payment flow here or via request doc listener elsewhere
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }, onError: (err) {
      debugPrint("Ride request listener error: $err");
    });
  }

  /// Start a Firestore listener on Rental Driver/{driverEmail} to track latitude/longitude live.
  /// We update driver marker in real-time and check arrival to pickup.
  void _startDriverDocListener(String driverEmail, RideOption ride, String userEmail) {
    _driverDocListener?.cancel();
    _driverDocListener = null;

    final driverDocRef = _firestore.collection('Rental Driver').doc(driverEmail);

    _driverDocListener = driverDocRef.snapshots().cast<DocumentSnapshot<Map<String, dynamic>>>().listen((snap) async {
      if (!mounted) return;
      if (!snap.exists) return;

      final dd = snap.data() ?? {};
      double? lat;
      double? lng;
      try {
        final rawLat = dd['latitude'] ?? dd['lat'] ?? dd['location']?['latitude'];
        final rawLng = dd['longitude'] ?? dd['lng'] ?? dd['location']?['longitude'];
        if (rawLat != null) {
          lat = (rawLat is num) ? rawLat.toDouble() : double.tryParse(rawLat.toString());
        }
        if (rawLng != null) {
          lng = (rawLng is num) ? rawLng.toDouble() : double.tryParse(rawLng.toString());
        }
      } catch (e) {
        debugPrint("Driver lat/lng parse error: $e");
      }

      if (lat != null && lng != null) {
        final pos = LatLng(lat, lng);
        await _updateDriverMarker(pos);
       await _fetchAndShowRoute(pos, LatLng(_pickupLat!, _pickupLng!));

        // compute distance between driver and pickup (use generous threshold for OTP)
        if (_pickupLat != null && _pickupLng != null) {
          final dist = _computeDistanceMeters(pos, LatLng(_pickupLat!, _pickupLng!));
          await _fetchAndShowRoute(pos, LatLng(_pickupLat!, _pickupLng!));
          if (dist <= DRIVER_ARRIVAL_THRESHOLD_METERS) {
            // Driver arrived at pickup. Show OTP dialog (only once).
            // We'll show OTP prompt and on success set trip='start'
            await _promptOtpAndStartTrip(ride, userEmail);
          } else {
            // If not arrived yet, keep UI in driverArriving
            if (mounted) {
              setState(() {
                _rideState = RideState.driverArriving;
              });
            }
          }
        }

        // When driver moves and we are still in pre-trip (not _onTripMode), update driver->pickup polyline
        if (!_onTripMode && (_pickupLat != null && _pickupLng != null)) {
          await _fetchAndShowRoute(pos, LatLng(_pickupLat!, _pickupLng!));
        }
      } else {
        debugPrint("Driver doc missing latitude/longitude fields");
      }
    }, onError: (e) {
      debugPrint("Driver doc listener error: $e");
    });
  }

  // Prompt the user to enter OTP when driver arrives at pickup. If OTP matches, set trip='start'.
  Future<void> _promptOtpAndStartTrip(RideOption ride, String userEmail) async {
    if (_hasShownOtpDialog) return; // avoid showing multiple times
    _hasShownOtpDialog = true;

    // retrieve the request doc ref
    final requestDocRef = ride.docRef!.collection('rideRequests').doc(userEmail);

    // fetch latest OTP value
    String serverOtp = '';
    try {
      final snap = await requestDocRef.get();
      if (snap.exists) {
        serverOtp = (snap.data()?['otp'] ?? '').toString();
      }
    } catch (e) {
      debugPrint("Error fetching otp: $e");
    }

    if (!mounted) {
      _hasShownOtpDialog = false;
      return;
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        final otpController = TextEditingController();
        return AlertDialog(
          title: const Text('Driver has arrived'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Your driver has arrived. Please share your OTP with them and enter it below to start the trip.'),
              const SizedBox(height: 12),
              TextField(controller: otpController, decoration: const InputDecoration(hintText: 'Enter OTP')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _hasShownOtpDialog = false;
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final entered = otpController.text.trim();
                Navigator.of(ctx).pop();
                if (entered.isNotEmpty && serverOtp.isNotEmpty && entered == serverOtp) {
                  try {
                    await requestDocRef.set({'trip': 'start', 'status': 'accepted'}, SetOptions(merge: true));
                  } catch (e) {
                    debugPrint("Error setting trip start on db: $e");
                  }
                } else {
                  // optionally notify user of mismatch
                  if (mounted) {
                    showDialog(
                      context: context,
                      builder: (c2) => AlertDialog(
                        title: const Text('OTP mismatch'),
                        content: const Text('The OTP you entered does not match.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(c2).pop(), child: const Text('OK')),
                        ],
                      ),
                    );
                  }
                }
                _hasShownOtpDialog = false;
              },
              child: const Text('Confirm OTP'),
            ),
          ],
        );
      },
    );
  }

  // ------------------ User position stream (during trip) ------------------

  void _startUserPositionStream(DocumentReference vehicleDocRef, String userEmail) async {
    // cancel existing
    await _userPositionStream?.cancel();
    _userPositionStream = null;

    // sanity: ensure we have permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      debugPrint("No permission for location stream");
      return;
    }

    // initial fetch of user's position
    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      _userMarker = Marker(markerId: const MarkerId('user_marker'), position: LatLng(pos.latitude, pos.longitude), infoWindow: const InfoWindow(title: 'You'));
      // if destination known show route
      if (_destLat != null && _destLng != null) {
        await _fetchAndShowRoute(LatLng(pos.latitude, pos.longitude), LatLng(_destLat!, _destLng!));
      }
      // move camera
      try {
        if (_mapController != null) _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(pos.latitude, pos.longitude), 14));
      } catch (_) {}
    } catch (e) {
      debugPrint("Error getting initial position: $e");
    }

    // Use LocationSettings for geolocator v14.x
    _userPositionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // meters
        // timeLimit is not appropriate for continuous stream; leaving defaults is fine
      ),
    ).listen((position) async {
      if (!mounted) return;
      final lat = position.latitude;
      final lng = position.longitude;
      setState(() {
        _userMarker = Marker(markerId: const MarkerId('user_marker'), position: LatLng(lat, lng), infoWindow: const InfoWindow(title: 'You'));
      });

      // update route from user -> destination
      if (_destLat != null && _destLng != null) {
        await _fetchAndShowRoute(LatLng(lat, lng), LatLng(_destLat!, _destLng!));
      }

      // when user reaches destination: mark trip complete and trigger payment
      final distToDest = (_destLat != null && _destLng != null) ? _computeDistanceMeters(LatLng(lat, lng), LatLng(_destLat!, _destLng!)) : double.infinity;
      if (distToDest <= ARRIVAL_THRESHOLD_METERS) {
        // update Firestore trip field to 'completed'
        try {
          await vehicleDocRef.collection('rideRequests').doc(userEmail).set({'trip': 'completed', 'status': 'completed'}, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Error marking trip completed: $e");
        }

        // stop stream and show completed dialog + payment UI
        await _userPositionStream?.cancel();
        _userPositionStream = null;

        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Trip Completed'),
            content: const Text('You have reached your destination. Proceed to payment.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  // open razorpay payment
                  _openRazorpayCheckout(amountINR: 100); // sample amount (INR)
                },
                child: const Text('Pay Now'),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> _stopUserPositionStream() async {
    await _userPositionStream?.cancel();
    _userPositionStream = null;
  }

  // ------------------ Map helpers ------------------

  void _clearMap() {
    // clear markers & route but keep controller and initial camera
    _driverMarker = null;
    _pickupMarker = null;
    _destMarker = null;
    _userMarker = null;
    _routePolyline = null;
    _etaText = '';
    _distanceText = '';
    _pickupLat = null;
    _pickupLng = null;
    _destLat = null;
    _destLng = null;
  }

  /// Remove pickup & driver markers only (used when trip starts)
  void _removePickupAndDriverMarkers() {
    setState(() {
      _pickupMarker = null;
      _driverMarker = null;
      _routePolyline = null; // route will be replaced by user->dest
      _etaText = '';
      _distanceText = '';
    });
  }

  /// Safely fetch driver lat/lng from `Rental Driver/{driverEmail}` where
  /// lat/lng may be stored as numbers or strings. Returns null if not found.
  Future<LatLng?> _fetchDriverLatLngFromParent(String driverEmail) async {
    try {
      final docSnap = await FirebaseFirestore.instance.collection('Rental Driver').doc(driverEmail).get();

      if (!docSnap.exists) return null;
      final data = docSnap.data()!;
      // Try common field names
      final rawLat = data['latitude'] ?? data['lat'] ?? data['location']?['latitude'];
      final rawLng = data['longitude'] ?? data['lng'] ?? data['location']?['longitude'];

      // Convert to double safely
      double? lat;
      double? lng;

      if (rawLat != null) {
        if (rawLat is num) lat = rawLat.toDouble();
        else lat = double.tryParse(rawLat.toString());
      }
      if (rawLng != null) {
        if (rawLng is num) lng = rawLng.toDouble();
        else lng = double.tryParse(rawLng.toString());
      }

      if (lat == null || lng == null) return null;
      return LatLng(lat, lng);
    } catch (e) {
      debugPrint('Error fetching driver lat/lng: $e');
      return null;
    }
  }

  Future<void> _updateDriverMarker(LatLng pos) async {
    final marker = Marker(
      markerId: const MarkerId('driver_marker'),
      position: pos,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: const InfoWindow(title: 'Driver'),
    );

    setState(() {
      _driverMarker = marker;
    });

    // Move camera to include pickup and driver if map is ready (only if not onTripMode)
    if (!_onTripMode && _mapController != null) {
      try {
        final bounds = _getBoundsForMarkers([_driverMarker, _pickupMarker, _destMarker, _userMarker]);
        if (bounds != null) {
          _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
        } else {
          _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)));
        }
      } catch (_) {}
    }
  }

  LatLngBounds? _getBoundsForMarkers(List<Marker?> markers) {
    final coords = markers.where((m) => m != null).map((m) => m!.position).toList();
    if (coords.isEmpty) return null;
    double south = coords.first.latitude;
    double north = coords.first.latitude;
    double west = coords.first.longitude;
    double east = coords.first.longitude;
    for (final c in coords) {
      if (c.latitude < south) south = c.latitude;
      if (c.latitude > north) north = c.latitude;
      if (c.longitude < west) west = c.longitude;
      if (c.longitude > east) east = c.longitude;
    }
    return LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east));
  }

  /// Fetch route polyline and ETA using Google Directions API (if key provided).
  /// If key is missing, function will calculate simple straight-line info and no polyline.
  Future<void> _fetchAndShowRoute(LatLng origin, LatLng destination) async {
    // if no API key, just draw straight line polyline and compute straightline distance & ETA approx
    if (GOOGLE_MAPS_API_KEY.isEmpty) {
      final points = [origin, destination];
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: points,
        color: Colors.blue,
        width: 5,
      );
      setState(() {
        _routePolyline = polyline;
        // For driver->pickup we intentionally set pickup marker if present
        if (_pickupLat != null && _pickupLng != null) {
          _pickupMarker = Marker(markerId: const MarkerId('pickup'), position: LatLng(_pickupLat!, _pickupLng!), infoWindow: const InfoWindow(title: 'Pickup'));
        }
        if (_destLat != null && _destLng != null) {
          _destMarker = Marker(markerId: const MarkerId('dest'), position: LatLng(_destLat!, _destLng!), infoWindow: const InfoWindow(title: 'Destination'));
        }
      });

      final meters = _computeDistanceMeters(origin, destination);
      _etaText = '${((meters / 1000) / 40 * 60).round()} min'; // crude: avg 40 km/h
      _distanceText = '${(meters / 1000).toStringAsFixed(1)} km';
      return;
    }

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$GOOGLE_MAPS_API_KEY&mode=driving');

    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        final routes = body['routes'] as List<dynamic>?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes.first;
          final overviewPolyline = route['overview_polyline']['points'] as String?;
          final legs = route['legs'] as List<dynamic>?;
          int durationSec = 0;
          int distanceMeters = 0;
          if (legs != null && legs.isNotEmpty) {
            durationSec = (legs.first['duration']['value'] ?? 0) as int;
            distanceMeters = (legs.first['distance']['value'] ?? 0) as int;
          }

          // decode polyline
          final decoded = _decodePolyline(overviewPolyline ?? '');
          final polyline = Polyline(
            polylineId: const PolylineId('route'),
            points: decoded,
            color: Colors.blue,
            width: 5,
          );

          setState(() {
            _routePolyline = polyline;
            // set pickup/destination markers if we have coordinates for them
            if (_pickupLat != null && _pickupLng != null) {
              _pickupMarker = Marker(markerId: const MarkerId('pickup'), position: LatLng(_pickupLat!, _pickupLng!), infoWindow: const InfoWindow(title: 'Pickup'));
            }
            if (_destLat != null && _destLng != null) {
              _destMarker = Marker(markerId: const MarkerId('dest'), position: LatLng(_destLat!, _destLng!), infoWindow: const InfoWindow(title: 'Destination'));
            }
            _etaText = '${(durationSec / 60).round()} min';
            _distanceText = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
          });

          // move camera to include both markers and polyline
          if (_mapController != null) {
            final bounds = _getBoundsForPolyline(decoded);
            if (bounds != null) {
              try {
                _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
              } catch (_) {}
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Directions API error: $e");
    }
  }

  LatLngBounds? _getBoundsForPolyline(List<LatLng> points) {
    if (points.isEmpty) return null;
    double south = points.first.latitude, north = points.first.latitude, west = points.first.longitude, east = points.first.longitude;
    for (final p in points) {
      if (p.latitude < south) south = p.latitude;
      if (p.latitude > north) north = p.latitude;
      if (p.longitude < west) west = p.longitude;
      if (p.longitude > east) east = p.longitude;
    }
    return LatLngBounds(southwest: LatLng(south, west), northeast: LatLng(north, east));
  }

  /// decode polyline (Google polyline algorithm)
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

  Future<void> _updateEtaAndDistance(LatLng driver, LatLng pickup) async {
    // prefer Google Directions API if key provided
    if (GOOGLE_MAPS_API_KEY.isNotEmpty) {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${driver.latitude},${driver.longitude}&destination=${pickup.latitude},${pickup.longitude}&key=$GOOGLE_MAPS_API_KEY&mode=driving');
      try {
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          final body = json.decode(resp.body);
          final legs = (body['routes'] as List).isNotEmpty ? body['routes'][0]['legs'] as List<dynamic> : null;
          if (legs != null && legs.isNotEmpty) {
            final durationSec = (legs[0]['duration']['value'] ?? 0) as int;
            final distanceMeters = (legs[0]['distance']['value'] ?? 0) as int;
            setState(() {
              _etaText = '${(durationSec / 60).round()} min';
              _distanceText = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
            });
            return;
          }
        }
      } catch (e) {
        debugPrint("Directions ETA error: $e");
      }
    }

    // fallback: straight-line
    final meters = _computeDistanceMeters(driver, pickup);
    setState(() {
      _distanceText = '${(meters / 1000).toStringAsFixed(2)} km';
      _etaText = '${((meters / 1000) / 30 * 60).round()} min'; // assume avg 30 km/h
    });
  }

  double _computeDistanceMeters(LatLng a, LatLng b) {
    // haversine
    const R = 6371000; // meters
    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;
    final dlat = (b.latitude - a.latitude) * pi / 180;
    final dlng = (b.longitude - a.longitude) * pi / 180;
    final x = sin(dlat / 2) * sin(dlat / 2) + cos(lat1) * cos(lat2) * sin(dlng / 2) * sin(dlng / 2);
    final c = 2 * atan2(sqrt(x), sqrt(1 - x));
    final d = R * c;
    return d;
  }

  // ------------------ Geocoding helpers ------------------

  /// Geocode address to LatLng. Uses Google Geocoding if key configured, otherwise uses Nominatim OSM.
  Future<LatLng?> _geocodeAddress(String address) async {
    if (address.trim().isEmpty) return null;
    if (GOOGLE_MAPS_API_KEY.isNotEmpty) {
      final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$GOOGLE_MAPS_API_KEY');
      try {
        final resp = await http.get(url);
        if (resp.statusCode == 200) {
          final body = json.decode(resp.body);
          final results = body['results'] as List<dynamic>?;
          if (results != null && results.isNotEmpty) {
            final loc = results.first['geometry']['location'];
            final lat = (loc['lat'] as num).toDouble();
            final lng = (loc['lng'] as num).toDouble();
            return LatLng(lat, lng);
          }
        }
      } catch (e) {
        debugPrint("Google geocode error: $e");
      }
    }

    // fallback to Nominatim
    try {
      final encoded = Uri.encodeComponent(address);
      final url = 'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&limit=1';
      final resp = await http.get(Uri.parse(url), headers: {'User-Agent': 'FlutterApp (youremail@example.com)'});
      if (resp.statusCode == 200) {
        final List jsonList = json.decode(resp.body) as List;
        if (jsonList.isNotEmpty) {
          final item = jsonList.first;
          final lat = double.tryParse(item['lat']?.toString() ?? '');
          final lon = double.tryParse(item['lon']?.toString() ?? '');
          if (lat != null && lon != null) return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint("OSM geocode error: $e");
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> _fetchPlaceSuggestions(String input) async {
    if (input.trim().isEmpty) return [];
    final encoded = Uri.encodeComponent(input);
    final url = 'https://nominatim.openstreetmap.org/search?q=$encoded&format=json&addressdetails=1&limit=6';
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'FlutterApp (youremail@example.com)'
      });
      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body) as List;
        return jsonList.map((item) {
          return {
            'display_name': item['display_name'] ?? '',
            'lat': item['lat'] ?? '',
            'lon': item['lon'] ?? '',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('OSM suggestion error: $e');
    }
    return [];
  }

  void _onPickupChanged(String v) {
    _pickupDebounce?.cancel();
    _pickupDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (v.trim().isEmpty) {
        setState(() {
          _pickupSuggestions = [];
          _showPickupSuggestions = false;
        });
        return;
      }
      final results = await _fetchPlaceSuggestions(v);
      setState(() {
        _pickupSuggestions = results;
        _showPickupSuggestions = results.isNotEmpty;
      });
    });
  }

  void _onDestChanged(String v) {
    _destDebounce?.cancel();
    _destDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (v.trim().isEmpty) {
        setState(() {
          _destSuggestions = [];
          _showDestSuggestions = false;
        });
        return;
      }
      final results = await _fetchPlaceSuggestions(v);
      setState(() {
        _destSuggestions = results;
        _showDestSuggestions = results.isNotEmpty;
      });
    });
  }

  // ------------------ UI Build (mostly unchanged) ------------------

  @override
  Widget build(BuildContext context) {
    // If on active trip, show full-screen map-only UI
    if (_onTripMode) {
      return Scaffold(
        
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              myLocationButtonEnabled: true,
              markers: {
                if (_userMarker != null) _userMarker!,
                if (_destMarker != null) _destMarker!,
                // driverMarker intentionally kept out during onTrip mode (we removed it at trip start)
              },
              polylines: {
                if (_routePolyline != null) _routePolyline!,
              },
              onMapCreated: (c) {
                _mapController = c;
                final bounds = _getBoundsForMarkers([_userMarker, _destMarker /* , _driverMarker*/]);
                if (bounds != null) {
                  try {
                    _mapController!.moveCamera(CameraUpdate.newLatLngBounds(bounds, 80));
                  } catch (_) {}
                } else {
                  _mapController!.moveCamera(CameraUpdate.newLatLng(_initialCameraPosition.target));
                }
              },
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
              },
              myLocationEnabled: false,
            ),

            // small overlay with ETA/distance if available
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: ifNotEmptyContainer(_etaText, _distanceText),
            ),

            // Payment button overlay (visible while trip started and not completed/paid)
            if (_shouldShowPaymentButton())
              Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: ElevatedButton(
                  onPressed: () {
                    // sample amount; you can compute actual based on distance or ride pricing
                    _openRazorpayCheckout(amountINR: 100);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 149, 196, 235),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
     // appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMainTabs(),
              const SizedBox(height: 20),
              _selectedMainTab == 0 ? _buildRideBookingBody() : RentalTab(),
            ],
          ),
        ),
      ),
    );
  }

  bool _shouldShowPaymentButton() {
    // Show payment button when we are on trip mode and the request exists with trip == 'start'
    final tripVal = (_currentRideRequestData?['trip'] ?? '').toString();
    final statusVal = (_currentRideRequestData?['status'] ?? '').toString();
    if (_onTripMode && tripVal == 'start' && statusVal != 'completed' && statusVal != 'paid') {
      return true;
    }
    return false;
  }

  Widget ifNotEmptyContainer(String eta, String distance) {
    if ((eta.isEmpty && distance.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [const Icon(Icons.timer_outlined), const SizedBox(width: 8), Text(eta.isNotEmpty ? eta : '—')]),
          Row(children: [const Icon(Icons.location_on), const SizedBox(width: 8), Text(distance.isNotEmpty ? distance : '—')]),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const Icon(Icons.menu),
      title: const Text('Book Your Ride', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: const [
        Icon(Icons.notifications_none),
        SizedBox(width: 16),
        Icon(Icons.person_outline),
        SizedBox(width: 16),
      ],
    );
  }

  Widget _buildMainTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 240, 236, 236),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          _buildTabItem('Ride Booking', Icons.directions_car, 0),
          _buildTabItem('Rental Booking', Icons.timer_outlined, 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, IconData icon, int index) {
    final isSelected = _selectedMainTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedMainTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromARGB(255, 160, 183, 232) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? Colors.white : Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey.shade400)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRideBookingBody() {
    switch (_rideState) {
      case RideState.initial:
        return _buildRideInitial();
      case RideState.confirmingPickup:
        return _buildConfirmPickup();
      case RideState.selectingRide:
        return _buildChooseRide();
      case RideState.confirmingRide:
        return _buildConfirmRide();
      case RideState.findingDriver:
      case RideState.driverFound:
      case RideState.driverArriving:
      case RideState.driverArrived:
        return _buildDriverStatus();
    }
  }

  // ------------------ UI Widgets (copied & preserved from your original) ------------------

  Widget _buildRideInitial() {
    return Card(
      color: const Color.fromARGB(255, 241, 236, 236),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pickup field with suggestions
            Stack(
              children: [
                TextField(
                  controller: _pickupController,
                  decoration: const InputDecoration(hintText: 'Pickup location', prefixIcon: Icon(Icons.location_on)),
                  onChanged: _onPickupChanged,
                ),
                if (_showPickupSuggestions)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 56,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _pickupSuggestions.length,
                          itemBuilder: (_, i) {
                            final s = _pickupSuggestions[i];
                            return ListTile(
                              title: Text(s['display_name'] ?? ''),
                              onTap: () {
                                _pickupController.text = s['display_name'] ?? '';
                                setState(() {
                                  _showPickupSuggestions = false;
                                  _pickupSuggestions = [];
                                  // store lat/lng
                                  _pickupLat = double.tryParse(s['lat']?.toString() ?? '');
                                  _pickupLng = double.tryParse(s['lon']?.toString() ?? '');
                                  // set pickup marker (if map exists)
                                  if (_pickupLat != null && _pickupLng != null) {
                                    _pickupMarker = Marker(markerId: const MarkerId('pickup'), position: LatLng(_pickupLat!, _pickupLng!), infoWindow: const InfoWindow(title: 'Pickup'));
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  )
              ],
            ),

            const SizedBox(height: 8),

            // Destination field with suggestions
            Stack(
              children: [
                TextField(
                  controller: _destController,
                  decoration: const InputDecoration(hintText: 'Where to?', prefixIcon: Icon(Icons.location_on)),
                  onChanged: _onDestChanged,
                ),
                if (_showDestSuggestions)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 56,
                    child: Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _destSuggestions.length,
                          itemBuilder: (_, i) {
                            final s = _destSuggestions[i];
                            return ListTile(
                              title: Text(s['display_name'] ?? ''),
                              onTap: () {
                                _destController.text = s['display_name'] ?? '';
                                setState(() {
                                  _showDestSuggestions = false;
                                  _destSuggestions = [];
                                  _destLat = double.tryParse(s['lat']?.toString() ?? '');
                                  _destLng = double.tryParse(s['lon']?.toString() ?? '');
                                  if (_destLat != null && _destLng != null) {
                                    _destMarker = Marker(markerId: const MarkerId('dest'), position: LatLng(_destLat!, _destLng!), infoWindow: const InfoWindow(title: 'Destination'));
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  )
              ],
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchRides,
              child: const Text('Search Rides'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color.fromARGB(255, 165, 207, 239),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmPickup() {
    return Column(
      children: [
        _buildLocationHeader(),
        const SizedBox(height: 16),
        Card(
          color: const Color.fromARGB(255, 241, 239, 239),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Confirm pickup location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('Make sure you\'re at the exact pickup spot', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _confirmPickup,
                  child: const Text('Confirm Pickup'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color.fromARGB(255, 170, 224, 243)),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildChooseRide() {
    return Column(
      children: [
        _buildLocationHeader(),
        const SizedBox(height: 16),
        const Align(alignment: Alignment.centerLeft, child: Text('Choose your ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        // Use vehicles fetched from Firestore if available; otherwise fallback to a small placeholder
        ListView.separated(
          itemCount: _availableVehicles.isNotEmpty ? _availableVehicles.length : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (_availableVehicles.isEmpty) {
              final ride = RideOption(
                title: 'Economy',
                description: '4 seats • Budget-friendly',
                priceRange: '\$8-12',
                eta: '3 min',
                rating: 4.8,
                capacity: 4,
                imageUrl: 'https://placehold.co/100x100/9E9E9E/FFFFFF?text=CAR',
              );
              return _buildRideCard(ride, null);
            }
            final ride = _availableVehicles[index];
            return _buildRideCard(ride, () {
              // onSelect: if this vehicle has a Firestore docRef, create rideRequest under it
              if (ride.docRef != null) {
                _selectVehicleFromDB(ride);
              } else {
                _selectRide(ride);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildRideCard(RideOption ride, VoidCallback? onSelect) {
    return Card(
      color: const Color.fromARGB(255, 249, 247, 247),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Image.network(ride.imageUrl, width: 60, height: 60),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(ride.description, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' ${ride.rating}'),
                        const SizedBox(width: 8),
                        const Icon(Icons.person, size: 16),
                        Text(' ${ride.capacity}'),
                      ]),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(ride.priceRange, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(children: [
                      const Icon(Icons.timer_outlined, size: 14),
                      Text(' ${ride.eta}')
                    ]),
                  ],
                )
              ],
            ),
            if (ride.tags != null) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: ride.tags!.map((tag) => Chip(label: Text(tag), backgroundColor: const Color.fromARGB(255, 240, 235, 235))).toList()),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onSelect ?? () => _selectRide(ride),
              child: const Text('Select'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color.fromARGB(255, 149, 196, 235)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmRide() {
    return Column(
      children: [
        _buildLocationHeader(),
        const SizedBox(height: 16),
        Card(
          color: const Color.fromARGB(255, 245, 243, 243),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Confirm your ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildRideOptionRow(_selectedRide!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // If user selected a DB-backed ride, booking was created in _selectVehicleFromDB.
                    // For non-DB fallback, just run existing _bookNow behaviour.
                    if (_selectedRide?.docRef == null) {
                      _bookNow();
                    } else {
                      // set UI to findingDriver; the ride request listener will drive the rest
                      setState(() => _rideState = RideState.findingDriver);
                    }
                  },
                  child: const Text('Book Now'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color.fromARGB(255, 188, 223, 244)),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color.fromARGB(255, 187, 236, 238), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Expanded(child: Text('From:', style: TextStyle(color: Color.fromARGB(255, 161, 194, 253)))),
                      Text(_pickupController.text.isNotEmpty ? _pickupController.text : '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color.fromARGB(255, 197, 238, 238), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Expanded(child: Text('To:', style: TextStyle(color: Color.fromARGB(255, 161, 194, 253)))),
                      Text(_destController.text.isNotEmpty ? _destController.text : '—', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildDriverStatus() {
    // Build the same driver status card as before but when driver found show map & ETA card below driver info
    String title = "Finding your driver...";
    String subtitle = "This usually takes 1-2 minutes";
    Widget content;

    final bool dbBacked = _selectedRide?.docRef != null;

    if (dbBacked) {
      final statusVal = (_currentRideRequestData?['status'] ?? 'no').toString();

      if (statusVal == 'accepted' && _currentRideRequestData != null) {
        final driverName = _currentRideRequestData?['driverName'] ?? _currentVehicleDocData?['driverName'] ?? 'Driver';
        final vehicleName = _currentVehicleDocData?['vehicleName'] ?? (_selectedRide?.title ?? 'Vehicle');
        final vehicleNumber = _currentVehicleDocData?['vehicleNumber'] ?? 'N/A';
        final vehicleType = _currentVehicleDocData?['vehicleType'] ?? _currentVehicleDocData?['type'] ?? 'N/A';
        final otpVal = (_currentRideRequestData?['otp'] ?? 'no').toString();

        content = Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Driver Found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
           Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    CircleAvatar(
      radius: 25,
      child: Text(driverName.isNotEmpty ? driverName[0].toUpperCase() : 'D'),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            driverName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(_currentVehicleDocData?['rating']?.toString() ?? '4.9'),
            ],
          ),
          Text(
            '$vehicleName • $vehicleType',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            vehicleNumber,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),

          // OTP row (OTP + call/chat icons)
          if (otpVal != 'no' && otpVal.isNotEmpty)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'OTP: $otpVal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.call_outlined),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    ),
  ],
),


            const SizedBox(height: 16),

            // --- MAP & ETA CARD area ---
            if ((_driverMarker != null) || (_pickupLat != null && _pickupLng != null))
              Column(
                children: [
                  // ETA / distance small card above the map
                  if ((_etaText.isNotEmpty || _distanceText.isNotEmpty))
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [const Icon(Icons.timer_outlined), const SizedBox(width: 8), Text(_etaText.isNotEmpty ? _etaText : '—')]),
                          Row(children: [const Icon(Icons.location_on), const SizedBox(width: 8), Text(_distanceText.isNotEmpty ? _distanceText : '—')]),
                        ],
                      ),
                    ),

                  // Google Map area (fixed height)
                  SizedBox(
                    height: 240,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: _initialCameraPosition,
                        zoomControlsEnabled: true,
zoomGesturesEnabled: true,
myLocationButtonEnabled: true,

                        markers: {
                          if (_driverMarker != null) _driverMarker!,
                          if (_pickupMarker != null) _pickupMarker!,
                          if (_destMarker != null) _destMarker!,
                        },
                        polylines: {
                          if (_routePolyline != null) _routePolyline!,
                        },
                        onMapCreated: (c) {
                          _mapController = c;
                          // when map is created, move camera to include markers if available
                          final bounds = _getBoundsForMarkers([_driverMarker, _pickupMarker, _destMarker]);
                          if (bounds != null) {
                            _mapController!.moveCamera(CameraUpdate.newLatLngBounds(bounds, 80));
                          } else {
                            _mapController!.moveCamera(CameraUpdate.newLatLng(_initialCameraPosition.target));
                          }
                        },
                        myLocationEnabled: false,
                        // KEY: allow the map to receive all gestures (inside scrolling parent)
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
                        },
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),
          ],
        );

        title = '';
        subtitle = '';
      } else {
        // pending -> spinner
        content = const CircularProgressIndicator(color: Colors.white);
      }
    } else {
      // fallback original UI
      if (_rideState == RideState.findingDriver) {
        content = const CircularProgressIndicator(color: Colors.white);
      } else {
        String driverStatusText = "Driver Found";
        Color driverStatusColor = Colors.blue;
        Widget? arrivalInfo;

        if (_rideState == RideState.driverArriving) {
          driverStatusText = "Driver Arriving";
          arrivalInfo = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined, size: 16),
              const Text(' 2 min'),
            ],
          );
        } else if (_rideState == RideState.driverArrived) {
          driverStatusText = "Driver Arrived";
          driverStatusColor = Colors.black;
          arrivalInfo = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade800),
                const SizedBox(width: 8),
                Text('Your driver has arrived!', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }

        content = Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: driverStatusColor, borderRadius: BorderRadius.circular(8)),
                  child: Text(driverStatusText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const Spacer(),
                if (arrivalInfo != null && _rideState == RideState.driverArriving) arrivalInfo,
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(radius: 25, child: Text('JS')),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('John Smith', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(children: [Icon(Icons.star, size: 16, color: Colors.amber), Text(' 4.9')]),
                    Text('Toyota Camry - Black', style: TextStyle(color: Colors.grey)),
                    Text('ABC 1234', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline)),
              ],
            ),
            const SizedBox(height: 16),
            if (_rideState == RideState.driverArrived) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade800),
                    const SizedBox(width: 8),
                    Text('Your driver has arrived!', style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ]
          ],
        );
        title = "";
        subtitle = "";
      }
    }

    return Card(
      color: const Color.fromARGB(255, 244, 240, 240),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            content,
            if (title.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
            ],
            OutlinedButton(
              onPressed: _cancelRide,
              child: const Text('Cancel Ride'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50), foregroundColor: Colors.white, side: const BorderSide(color: Colors.grey), backgroundColor: const Color.fromARGB(255, 172, 215, 254)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRentalBookingBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Available Rental Vehicles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('${_rentalVehicles.length} vehicles available', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          itemCount: _rentalVehicles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final vehicle = _rentalVehicles[index];
            return Card(
              color: const Color.fromARGB(255, 241, 238, 238),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.network(vehicle.imageUrl, width: 80, height: 80),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vehicle.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(vehicle.type, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                              Row(children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(' ${vehicle.rating}'),
                                const SizedBox(width: 8),
                                const Icon(Icons.person, size: 16),
                                Text(' ${vehicle.capacity}'),
                              ]),
                            ],
                          ),
                        ),
                        Text('\$${vehicle.pricePerDay}/day', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, children: vehicle.features.map((f) => Chip(label: Text(f), backgroundColor: const Color.fromARGB(255, 249, 248, 248))).toList()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _showRentalModal(vehicle),
                      child: const Text('Take it on Rent'),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color.fromARGB(255, 118, 123, 207)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocationHeader() {
    return Card(
      color: const Color.fromARGB(255, 241, 239, 239),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: TextEditingController(text: _pickupController.text.isNotEmpty ? _pickupController.text : 'jsfk'), decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on))),
            const SizedBox(height: 8),
            TextField(controller: TextEditingController(text: _destController.text.isNotEmpty ? _destController.text : 'ds'), decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on))),
          ],
        ),
      ),
    );
  }

  Widget _buildRideOptionRow(RideOption ride) {
    return Row(
      children: [
        Image.network(ride.imageUrl, width: 60, height: 60),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ride.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(ride.description, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              Row(children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${ride.rating}'),
                const SizedBox(width: 8),
                const Icon(Icons.person, size: 16),
                Text(' ${ride.capacity}'),
              ]),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(ride.priceRange, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(children: [
              const Icon(Icons.timer_outlined, size: 14),
              Text(' ${ride.eta}')
            ]),
          ],
        )
      ],
    );
  }

  Widget _buildRentalForm(RentalVehicle vehicle, ScrollController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 243, 239, 239),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: ListView(
        controller: controller,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Rent ${vehicle.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormRow('Start Date', 'End Date'),
          const SizedBox(height: 12),
          _buildFormRow('Start Time', 'End Time'),
          const SizedBox(height: 12),
          const Text('Rental Duration'),
          const SizedBox(height: 4),
          DropdownButtonFormField(items: [], onChanged: (val) {}, decoration: const InputDecoration(hintText: 'Select duration')),
          const SizedBox(height: 12),
          const Text('Pickup Location'),
          const SizedBox(height: 4),
          const TextField(decoration: InputDecoration(hintText: 'Enter pickup address')),
          const SizedBox(height: 12),
          const Text('Driver License Number'),
          const SizedBox(height: 4),
          const TextField(decoration: InputDecoration(hintText: 'Enter your license number')),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
              const SizedBox(width: 12),
              Expanded(child: ElevatedButton(onPressed: () {}, child: const Text('Confirm Rental'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFormRow(String label1, String label2) {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label1), const SizedBox(height: 4), TextField(decoration: InputDecoration(hintText: label1.contains('Date') ? 'dd-mm-yyyy' : '--:--'))])),

        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label2), const SizedBox(height: 4), TextField(decoration: InputDecoration(hintText: label2.contains('Date') ? 'dd-mm-yyyy' : '--:--'))])),
      ],
    );
  }

  // ------------------ Razorpay integration ------------------

  void _openRazorpayCheckout({required int amountINR}) {
    // amountINR: e.g. 100 = Rs. 100
    final options = {
      'key': 'rzp_test_RaXt8zyzOapu8L', // replace with your Razorpay key
      'amount': amountINR * 100, // in paise
      'name': 'lets Explore',
      'description': 'Ride payment',
      'prefill': {'contact': _auth.currentUser?.phoneNumber ?? '', 'email': _auth.currentUser?.email ?? ''},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay open error: $e");
    }
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) async {
    // Payment success
    // mark the rideRequest document as completed (trip: completed) if not already
    try {
      final user = _auth.currentUser;
      final userEmail = (user?.email ?? user?.uid ?? 'unknown_user').toString();
      if (_selectedRide?.docRef != null) {
        await _selectedRide!.docRef!.collection('rideRequests').doc(userEmail).set({'trip': 'completed', 'status': 'paid'}, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Error marking paid: $e");
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Text('Payment id: ${response.paymentId}'),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(ctx).pop();
            // reset UI
            setState(() {
              _onTripMode = false;
              _rideState = RideState.initial;
              _selectedRide = null;
              _clearMap();
            });
          }, child: const Text('OK'))
        ],
      ),
    );
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text('Error: ${response.code} - ${response.message}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))
        ],
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('External Wallet'),
        content: Text('Wallet: ${response.walletName}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))
        ],
      ),
    );
  }
}
