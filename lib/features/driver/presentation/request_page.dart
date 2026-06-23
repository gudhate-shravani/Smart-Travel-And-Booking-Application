// ignore_for_file: use_build_context_synchronously



// requests_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelapplication/features/driver/presentation/ride_map_screen.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage> {
  int selectedMainTab = 0; // 0 = Ride Requests, 1 = Rental Requests
  int selectedStatus = 0; // 0 = Pending, 1 = Accepted, 2 = Completed

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- Top Segmented Toggle (Ride vs Rental) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                _buildMainToggle("Ride Requests", 0),
                _buildMainToggle("Rental Requests", 1),
              ],
            ),
          ),
        ),

        // --- Animated Status Chips (Pending, Accepted, Completed) ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (index) {
              final statuses = ["Pending", "Accepted", "Completed"];
              final colors = [Colors.orange, Colors.green, Colors.blue];

              final isSelected = selectedStatus == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors[index].withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? colors[index] : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() => selectedStatus = index);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: colors[index],
                        size: 10,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statuses[index],
                        style: TextStyle(
                          color: colors[index],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        // --- Request Content Section ---
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeIn,
            switchOutCurve: Curves.easeOut,
            child: selectedMainTab == 0
                ? _buildRideRequests()
                : _buildRentalRequests(),
          ),
        ),
      ],
    );
  }

  // --- Ride/Rental Toggle Button Builder ---
  Widget _buildMainToggle(String title, int index) {
    final isSelected = selectedMainTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedMainTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // --- RIDE: Build Stream of Vehicles -> requests ---
  Widget _buildRideRequests() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in to see requests.'));
    }

    final vehiclesRef = _firestore.collection('Rental Driver').doc(user.email).collection('vehicle');

    // status mapping for ride queries:
    // selectedStatus 0 => status == 'pending'
    // 1 => status == 'accepted'
    // 2 => trip == 'completed'
    return StreamBuilder<QuerySnapshot>(
      stream: vehiclesRef.snapshots(),
      builder: (context, vehiclesSnap) {
        if (vehiclesSnap.hasError) return Center(child: Text('Error: ${vehiclesSnap.error}'));
        if (!vehiclesSnap.hasData) return const Center(child: CircularProgressIndicator());

        final vehicleDocs = vehiclesSnap.data!.docs;
        List<Widget> cards = [];

        for (final vehicleDoc in vehicleDocs) {
          final vehicleName = vehicleDoc.id;
          final reqColl = vehicleDoc.reference.collection('rideRequests');

          Query query;
          if (selectedStatus == 0) {
            query = reqColl.where('status', isEqualTo: 'pending');
          } else if (selectedStatus == 1) {
            query = reqColl.where('status', isEqualTo: 'accepted');
          } else {
            query = reqColl.where('trip', isEqualTo: 'completed'); // completed tab uses trip=='completed'
          }

          cards.add(
            StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, reqSnap) {
                if (reqSnap.hasError) return const SizedBox.shrink();
                if (!reqSnap.hasData) return const SizedBox.shrink();
                final requests = reqSnap.data!.docs;
                if (requests.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text('Vehicle: $vehicleName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...requests.map((reqDoc) {
                      final data = reqDoc.data() as Map<String, dynamic>;
                      final senderEmail = reqDoc.id;
                      final pickup = data['pickup_location'] ?? 'Unknown';
                      final destination = data['destination_location'] ?? 'Unknown';
                      final time = data['time'] ?? '';
                      final fare = data['fare'] ?? '';

                      // Determine card status text for UI
                      String statusForUI = selectedStatus == 0 ? 'Pending' : (selectedStatus == 1 ? 'Accepted' : 'Completed');

                      return _rideRequestCard(
                        name: data['fullName'] ?? senderEmail, // fallback
                        rating: (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0,
                        time: time.toString(),
                        from: pickup,
                        to: destination,
                        rideTime: data['scheduled_time'] ?? '',
                        distance: data['distance'] ?? '',
                        duration: data['duration'] ?? '',
                        price: fare.toString(),
                        status: statusForUI,
                        onAccept: selectedStatus == 0 ? () async {
                          // set status -> accepted
                          await reqDoc.reference.update({'status': 'accepted'});
                        } : null,
                        onDecline: selectedStatus == 0 ? () async {
                          await reqDoc.reference.update({'status': 'rejected'});
                        } : null,
                        onStartRide: selectedStatus == 1 ? () async {
                          // accepted tab -> need OTP verification then set trip to 'start' and open map
                          final otpMatch = await _showOtpAndVerify(context, reqDoc.reference);
                          if (otpMatch) {
                            await reqDoc.reference.update({'trip': 'start'});
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => RideMapScreen(
                              driverEmail: user.email!,
                              vehicleName: vehicleName,
                              senderEmail: senderEmail,
                              requestDocRef: reqDoc.reference,
                            )));
                          } else {
                            // snack
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP did not match')));
                          }
                        } : null,
                        onPayment: selectedStatus == 2 ? () async {
                          // Completed tab: show payment dialog or mark paid
                          final doc = await reqDoc.reference.get();
                          final currentPayment = (doc.data() as Map<String, dynamic>?)?['payment'] ?? 'unpaid';
                          if (currentPayment == 'paid') {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment already done')));
                          } else {
                            final pay = await _showPaymentConfirm(context);
                            if (pay == true) {
                              await reqDoc.reference.update({'payment': 'paid'});
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment marked as paid')));
                            }
                          }
                        } : null,
                      );
                    }),
                  ],
                );
              },
            ),
          );
        }

        if (cards.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No requests found.')),
          );
        }
        return ListView(padding: const EdgeInsets.all(16), children: cards);
      },
    );
  }

  // --- RENTAL: Build Stream of Vehicles -> rentalRequests ---
  Widget _buildRentalRequests() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Please sign in to see requests.'));
    }

    final vehiclesRef = _firestore.collection('Rental Driver').doc(user.email).collection('vehicle');

    // mapping:
    // selectedStatus 0 -> status == 'pending'
    // 1 -> status == 'accepted'
    // 2 -> status == 'start' (as requested)
    return StreamBuilder<QuerySnapshot>(
      stream: vehiclesRef.snapshots(),
      builder: (context, vehiclesSnap) {
        if (vehiclesSnap.hasError) return Center(child: Text('Error: ${vehiclesSnap.error}'));
        if (!vehiclesSnap.hasData) return const Center(child: CircularProgressIndicator());

        final vehicleDocs = vehiclesSnap.data!.docs;
        List<Widget> cards = [];

        for (final vehicleDoc in vehicleDocs) {
          final vehicleName = vehicleDoc.id;
          final reqColl = vehicleDoc.reference.collection('rentalRequests');

          Query query;
          if (selectedStatus == 0) {
            query = reqColl.where('status', isEqualTo: 'pending');
          } else if (selectedStatus == 1) {
            query = reqColl.where('status', isEqualTo: 'accepted');
          } else {
            // completed tab for rental shows status == 'start' per your instruction
            query = reqColl.where('status', isEqualTo: 'start');
          }

          cards.add(
            StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, reqSnap) {
                if (reqSnap.hasError) return const SizedBox.shrink();
                if (!reqSnap.hasData) return const SizedBox.shrink();
                final requests = reqSnap.data!.docs;
                if (requests.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text('Vehicle: $vehicleName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    ...requests.map((reqDoc) {
                      final data = reqDoc.data() as Map<String, dynamic>;
                      final senderEmail = reqDoc.id;
                      final startDate = data['startDate'] ?? '';
                      final startTime = data['startTime'] ?? '';
                      final endDate = data['endDate'] ?? '';
                      final endTime = data['endTime'] ?? '';
                      final fare = data['fare'] ?? '';
                      return _rentalRequestCard(
                        name: data['fullName'] ?? senderEmail,
                        from: data['from'] ?? '',
                        rentaltime: '$startDate $startTime',
                        time: '$endDate $endTime',
                        fare: fare.toString(),
                        statusText: _mapRentalStatusToUI(selectedStatus),
                        onAccept: selectedStatus == 0 ? () async {
                          await reqDoc.reference.update({'status': 'accepted'});
                        } : null,
                        onDecline: selectedStatus == 0 ? () async {
                          await reqDoc.reference.update({'status': 'rejected'});
                        } : null,
                        onStart: selectedStatus == 1 ? () async {
                          // accepted tab -> OTP verification, set status to 'start'
                          final otpMatch = await _showOtpAndVerify(context, reqDoc.reference, isRental: true);
                          if (otpMatch) {
                            await reqDoc.reference.update({'status': 'start'});
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rental started')));
                          } else {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP mismatch')));
                          }
                        } : null,
                        onPayment: selectedStatus == 2 ? () async {
                          // show payment and mark completed
                          final doc = await reqDoc.reference.get();
                          final currentPayment = (doc.data() as Map<String, dynamic>?)?['payment'] ?? 'unpaid';
                          if (currentPayment == 'paid') {
                            if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment already done')));
                          } else {
                            final pay = await _showPaymentConfirm(context);
                            if (pay == true) {
                              await reqDoc.reference.update({'payment': 'paid', 'status': 'completed'});
                              if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment marked as paid and rental completed')));
                            }
                          }
                        } : null,
                      );
                    }),
                  ],
                );
              },
            ),
          );
        }

        if (cards.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('No requests found.')),
          );
        }
        return ListView(padding: const EdgeInsets.all(16), children: cards);
      },
    );
  }

  // --- helper UI mapping ---
  String _mapRentalStatusToUI(int sel) {
    if (sel == 0) return 'Pending';
    if (sel == 1) return 'Accepted';
    return 'Start'; // when showing status == 'start'
  }

  // --- OTP dialog logic: verify otp stored in request document ---
  Future<bool> _showOtpAndVerify(BuildContext context, DocumentReference reqRef, {bool isRental = false}) async {
    final TextEditingController ctrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Enter the OTP from user'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Verify')),
          ],
        );
      },
    );

    if (result != true) return false;
    final entered = ctrl.text.trim();
    if (entered.isEmpty) return false;

    final doc = await reqRef.get();
    final remoteOtp = (doc.data() as Map<String, dynamic>?)?['otp']?.toString() ?? '';
    if (entered == remoteOtp) {
      // if ride -> set trip to 'start' is done by caller for ride; for rental we'll update status here
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> _showPaymentConfirm(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: const Text('Mark payment as done?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('No')),
            TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')),
          ],
        );
      },
    );
  }

  // --- Ride Request Card UI (keeps your look) ---
  Widget _rideRequestCard({
    required String name,
    required double rating,
    required String time,
    required String from,
    required String to,
    required String rideTime,
    required String distance,
    required String duration,
    required String price,
    required String status,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
    VoidCallback? onStartRide,
    VoidCallback? onPayment,
  }) {
    Color statusColor = status == "Accepted"
        ? Colors.green
        : status == "Completed"
            ? Colors.blue
            : Colors.orange;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(" $rating Ã¢â‚¬Â¢ $time",
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status,
                    style: TextStyle(color: statusColor, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("From: $from", style: const TextStyle(color: Colors.black87)),
          Text("To: $to", style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$rideTime Ã¢â‚¬Â¢ $distance Ã¢â‚¬Â¢ $duration",
                  style: const TextStyle(color: Colors.grey)),
              Text(price,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 10),

          // Action Buttons Based on Status
          if (status == "Pending") ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text("Accept"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDecline,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Text("Decline"),
                  ),
                ),
              ],
            ),
          ] else if (status == "Accepted") ...[
            ElevatedButton(
              onPressed: onStartRide,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Start Ride"),
            ),
          ] else if (status == "Completed") ...[
            ElevatedButton(
              onPressed: onPayment,
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Payment Status"),
            ),
          ],
        ],
      ),
    );
  }

  // --- Rental request card UI (keeps same look) ---
  Widget _rentalRequestCard({
    required String name,
    required String from,
    required String rentaltime,
    required String time,
    required String fare,
    required String statusText,
    VoidCallback? onAccept,
    VoidCallback? onDecline,
    VoidCallback? onStart,
    VoidCallback? onPayment,
  }) {
    Color statusColor = statusText == "Accepted"
        ? Colors.green
        : statusText == "Completed"
            ? Colors.blue
            : Colors.orange;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Rental Ã¢â‚¬Â¢ $rentaltime", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text("From: $from"),
        Text("To: $time"),
        const SizedBox(height: 10),
        Row(
          children: [
            if (statusText == "Pending") ...[
              Expanded(child: ElevatedButton(onPressed: onAccept, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Accept'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: onDecline, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Decline'))),
            ] else if (statusText == "Accepted") ...[
              Expanded(child: ElevatedButton(onPressed: onStart, style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: const Text('Start'))),
            ] else ...[
              Expanded(child: ElevatedButton(onPressed: onPayment, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), child: const Text('Payment Status'))),
            ]
          ],
        )
      ]),
    );
  }
}

