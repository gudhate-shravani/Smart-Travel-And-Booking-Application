/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  
  
  @override
  State<StatefulWidget> createState()  => _homePageState();
}

class _homePageState  extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

String? driverName;
bool _isLoading = true;
@override
void initState() {
  super.initState();
  _fetchDriverName();
}
Future<void> _fetchDriverName() async {
  try {
    final user = _auth.currentUser;
    if (user == null) {
      print("⚠️ No user logged in");
      setState(() => _isLoading = false);
      return;
    }

    final doc = await _firestore.collection('Rental Driver').doc(user.email).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        driverName = data['fullName'] ?? 'Driver';
      });
      print("✅ Fetched driver name: ${data['fullName']}");
    } else {
      print("❌ No document found for ${user.email}");
      setState(() => driverName = 'Driver');
    }
  } catch (e) {
    print("❌ Error fetching name: $e");
    setState(() => driverName = 'Driver');
  }

  setState(() => _isLoading = false);
}


    bool isRideSelected = true; 

  @override
  Widget build(BuildContext context) {
    return 
       SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Icon + Notification ---
            
              const SizedBox(height: 16),
               Text(
  _isLoading
      ? "Welcome..."
      : "Welcome ${driverName ?? 'Driver'}",
  style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  ),
),

             
              const Text("Ready to start earning today?"),
              const SizedBox(height: 16),

              // --- Stats Grid ---
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.8,
                children: [
                  buildStatCard("Total Trips", "142", Icons.show_chart, Colors.blue),
                  buildStatCard("Active Rentals", "3", Icons.directions_car, Colors.green),
                  buildStatCard("This Month", "₹15,240", Icons.currency_rupee, Colors.purple),
                  buildStatCard("Pending Requests", "5", Icons.access_time, Colors.orange),
                ],
              ),
              const SizedBox(height: 16),

              // --- Today's Summary ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Today's Summary",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("View Analytics", style: TextStyle(color: Colors.blue)),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final heights = [40, 60, 30, 70, 45, 80, 55];
                    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 12,
                          height: heights[i].toDouble(),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blueAccent, Colors.lightBlue],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(days[i],
                            style: const TextStyle(fontSize: 10, color: Colors.black54))
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // --- Ride / Rental Toggle Tabs ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isRideSelected = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isRideSelected
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text("Ride Requests",
                              style: TextStyle(
                                color: isRideSelected ? Colors.blue : Colors.black54,
                                fontWeight: isRideSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isRideSelected = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !isRideSelected
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          alignment: Alignment.center,
                          child: Text("Rental Requests",
                              style: TextStyle(
                                color: !isRideSelected ? Colors.blue : Colors.black54,
                                fontWeight: !isRideSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- Conditional UI (Ride / Rental) ---
              if (isRideSelected) ...[
                buildRideRequestCard(
                  name: "Priya Sharma",
                  from: "Connaught Place",
                  to: "IGI Airport",
                  time: "2:30 PM",
                  fare: "₹450",
                  isNew: true,
                ),
                const SizedBox(height: 12),
                buildRideRequestCard(
                  name: "Rahul Kumar",
                  from: "Karol Bagh",
                  to: "Gurgaon Cyber City",
                  time: "3:15 PM",
                  fare: "₹320",
                  isNew: false,
                ),
              ] else ...[
                buildRentalRequestCard(
                  name: "Ankit Singh",
                  from: "Noida",
                  rentaltime: "2 hour",
                  time: "1:30 PM",
                  fare: "₹500",
                  isNew: true,
                ),
                const SizedBox(height: 12),
                buildRentalRequestCard(
                  name: "Simran Kaur",
                  from: "Saket",
                  rentaltime: "2 hour",
                  time: "4:00 PM",
                  fare: "₹350",
                  isNew: false,
                ),
              ]
            ],
          ),
        ),
      );
  }


  Widget buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRideRequestCard({
    required String name,
    required String from,
    required String to,
    required String time,
    required String fare,
    required bool isNew,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text("New",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.green, size: 10),
            const SizedBox(width: 6),
            Text("From: $from"),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.red, size: 10),
            const SizedBox(width: 6),
            Text("To: $to"),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(time),
              ],
            ),
            Text(fare,
                style:
                    const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Accept"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cancel_outlined),
              label: const Text("Reject"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.phone, color: Colors.black54)),
            IconButton(
                onPressed: () {},
                icon:
                    const Icon(Icons.chat_bubble_outline, color: Colors.black54)),
          ],
        )
      ]),
    );
  }

  Widget buildRentalRequestCard({
    required String name,
    required String from,
    required String rentaltime,
    required String time,
    required String fare,
    required bool isNew,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            if (isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: const Text("New",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.green, size: 10),
            const SizedBox(width: 6),
            Text("From: $from"),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.circle, color: Colors.red, size: 10),
            const SizedBox(width: 6),
            Text("Rental time: $rentaltime"),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(time),
              ],
            ),
            Text(fare,
                style:
                    const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Accept"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cancel_outlined),
              label: const Text("Reject"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.phone, color: Colors.black54)),
            IconButton(
                onPressed: () {},
                icon:
                    const Icon(Icons.chat_bubble_outline, color: Colors.black54)),
          ],
        )
      ]),
    );
  }
}
*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _homePageState();
}

class _homePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? driverName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDriverName();
  }

  Future<void> _fetchDriverName() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print("⚠️ No user logged in");
        setState(() => _isLoading = false);
        return;
      }

      final doc =
          await _firestore.collection('Rental Driver').doc(user.email).get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          driverName = data['fullName'] ?? 'Driver';
        });
        print("✅ Fetched driver name: ${data['fullName']}");
      } else {
        print("❌ No document found for ${user.email}");
        setState(() => driverName = 'Driver');
      }
    } catch (e) {
      print("❌ Error fetching name: $e");
      setState(() => driverName = 'Driver');
    }

    setState(() => _isLoading = false);
  }

  bool isRideSelected = true;

  // helper to update status of a request document
  Future<void> _updateRequestStatus({
    required DocumentReference requestDocRef,
    required String newStatus,
  }) async {
    try {
      await requestDocRef.update({'status': newStatus});
    } catch (e) {
      // optionally show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating request: $e')),
        );
      }
    }
  }

  // fetch sender name from traveler collection
  Future<String> _getSenderName(String senderEmail) async {
    try {
      final snap =
          await _firestore.collection('traveler').doc(senderEmail).get();
      if (snap.exists) {
        final data = snap.data()!;
        return data['fullName'] ?? senderEmail;
      } else {
        return senderEmail;
      }
    } catch (e) {
      return senderEmail;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              _isLoading ? "Welcome..." : "Welcome ${driverName ?? 'Driver'}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text("Ready to start earning today?"),
            const SizedBox(height: 16),

            // --- Stats Grid (unchanged) ---
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.8,
              children: [
                buildStatCard("Total Trips", "3", Icons.show_chart, Colors.blue),
                buildStatCard("Active Rentals", "1", Icons.directions_car, Colors.green),
                buildStatCard("This Month", "₹500", Icons.currency_rupee, Colors.purple),
                buildStatCard("Pending Requests", "1", Icons.access_time, Colors.orange),
              ],
            ),
          
            const SizedBox(height: 24),

            // --- Toggle Tabs ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isRideSelected = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isRideSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text("Ride Requests",
                            style: TextStyle(
                              color: isRideSelected ? Colors.blue : Colors.black54,
                              fontWeight: isRideSelected ? FontWeight.bold : FontWeight.normal,
                            )),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isRideSelected = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isRideSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        alignment: Alignment.center,
                        child: Text("Rental Requests",
                            style: TextStyle(
                              color: !isRideSelected ? Colors.blue : Colors.black54,
                              fontWeight: !isRideSelected ? FontWeight.bold : FontWeight.normal,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- Conditional UI (Ride / Rental) ---
            if (isRideSelected) ...[
              // RIDE: Show live requests under each vehicle's rideRequests subcollection where status == 'pending'
              if (user == null)
                const Text("Please sign in to see requests.")
              else
                buildVehicleRequestsStream(
                  driverEmail: user.email!,
                  requestSubcollectionName: 'rideRequests',
                  isRental: false,
                ),
            ] else ...[
              if (user == null)
                const Text("Please sign in to see requests.")
              else
                buildVehicleRequestsStream(
                  driverEmail: user.email!,
                  requestSubcollectionName: 'rentalRequests',
                  isRental: true,
                ),
            ]
          ],
        ),
      ),
    );
  }

  // Builds stream that listens to driver's vehicle docs and then each vehicle's requests subcollection
  Widget buildVehicleRequestsStream({
    required String driverEmail,
    required String requestSubcollectionName, // 'rideRequests' or 'rentalRequests'
    required bool isRental,
  }) {
    final vehiclesCollection = _firestore
        .collection('Rental Driver')
        .doc(driverEmail)
        .collection('vehicle');

    return StreamBuilder<QuerySnapshot>(
      stream: vehiclesCollection.snapshots(),
      builder: (context, vehiclesSnapshot) {
        if (vehiclesSnapshot.hasError) {
          return Text('Error loading vehicles: ${vehiclesSnapshot.error}');
        }
        if (vehiclesSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final vehicleDocs = vehiclesSnapshot.data?.docs ?? [];

        if (vehicleDocs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text('No vehicles found for this driver.'),
          );
        }

        // For each vehicle, create a StreamBuilder for its pending requests.
        return Column(
          children: vehicleDocs.map((vehicleDoc) {
            final vehicleName = vehicleDoc.id;
            final requestsRef = vehicleDoc.reference.collection(requestSubcollectionName);

            // Stream of only pending requests for this vehicle
            final pendingStream = requestsRef.where('status', isEqualTo: 'pending').snapshots();

            return StreamBuilder<QuerySnapshot>(
              stream: pendingStream,
              builder: (context, requestsSnapshot) {
                if (requestsSnapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('Error loading requests for $vehicleName: ${requestsSnapshot.error}'),
                  );
                }
                if (requestsSnapshot.connectionState == ConnectionState.waiting) {
                  // show nothing for this vehicle until loaded (or a small loader)
                  return const SizedBox.shrink();
                }

                final requests = requestsSnapshot.data?.docs ?? [];

                if (requests.isEmpty) {
                  // no pending requests for this vehicle -> show nothing (or a small hidden container)
                  return const SizedBox.shrink();
                }

                // Show a header for the vehicle and its pending requests
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Vehicle: $vehicleName',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    // list of pending requests for this vehicle
                    ...requests.map((reqDoc) {
                      final reqData = reqDoc.data() as Map<String, dynamic>? ?? {};
                      final senderEmail = reqDoc.id;

                      if (!isRental) {
                        // Ride request card
                        final pickup = reqData['pickup_location'] ?? 'Unknown pickup';
                        final destination = reqData['destination_location'] ?? 'Unknown destination';
                        final time = reqData['time'] ?? ''; // optional
                        final fare = reqData['fare'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                  future: _getSenderName(senderEmail),
                                  builder: (context, snapName) {
                                    final displayName = snapName.data ?? senderEmail;
                                    return Row(
                                      children: [
                                        Text(displayName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(width: 8),
                                        if (reqData['isNew'] == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8)),
                                            child: const Text("New",
                                                style: TextStyle(
                                                    color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.circle, color: Colors.green, size: 10),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text("From: $pickup")),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.circle, color: Colors.red, size: 10),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text("To: $destination")),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 4),
                                        Text(time),
                                      ],
                                    ),
                                    Text(fare,
                                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // update status to accepted
                                        _updateRequestStatus(
                                          requestDocRef: reqDoc.reference,
                                          newStatus: 'accepted',
                                        );
                                      },
                                      icon: const Icon(Icons.check_circle_outline),
                                      label: const Text("Accept"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // update status to rejected
                                        _updateRequestStatus(
                                          requestDocRef: reqDoc.reference,
                                          newStatus: 'rejected',
                                        );
                                      },
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: const Text("Reject"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                        onPressed: () {
                                          // phone action - you can wire this up to call
                                        },
                                        icon: const Icon(Icons.phone, color: Colors.black54)),
                                    IconButton(
                                        onPressed: () {
                                          // chat action
                                        },
                                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Rental request card
                        final startDate = reqData['startDate'] ?? '';
                        final startTime = reqData['startTime'] ?? '';
                        final endDate = reqData['endDate'] ?? '';
                        final endTime = reqData['endTime'] ?? '';
                        final fare = reqData['fare'] ?? '';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                  future: _getSenderName(senderEmail),
                                  builder: (context, snapName) {
                                    final displayName = snapName.data ?? senderEmail;
                                    return Row(
                                      children: [
                                        Text(displayName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(width: 8),
                                        if (reqData['isNew'] == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8)),
                                            child: const Text("New",
                                                style: TextStyle(
                                                    color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.circle, color: Colors.green, size: 10),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text("Start: $startDate  $startTime")),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.circle, color: Colors.red, size: 10),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text("End: $endDate  $endTime")),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, size: 16),
                                        const SizedBox(width: 4),
                                        const Text("Rental"),
                                      ],
                                    ),
                                    Text(fare,
                                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // update status to accepted
                                        _updateRequestStatus(
                                          requestDocRef: reqDoc.reference,
                                          newStatus: 'accepted',
                                        );
                                      },
                                      icon: const Icon(Icons.check_circle_outline),
                                      label: const Text("Accept"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // update status to rejected
                                        _updateRequestStatus(
                                          requestDocRef: reqDoc.reference,
                                          newStatus: 'rejected',
                                        );
                                      },
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: const Text("Reject"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                        onPressed: () {
                                          // phone
                                        },
                                        icon: const Icon(Icons.phone, color: Colors.black54)),
                                    IconButton(
                                        onPressed: () {
                                          // chat
                                        },
                                        icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  ],
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
