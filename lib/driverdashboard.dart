

import 'package:flutter/material.dart';
import 'package:travelapplication/features/driver/presentation/add_vehicle.dart';
import 'package:travelapplication/features/driver/presentation/driver_drawer.dart';
import 'package:travelapplication/features/driver/presentation/payment.dart';
import 'package:travelapplication/features/guide/presentation/messages_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

String? driverName;
bool _isLoading = true;





class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {

  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    RequestsPage(),
    RootWidget(),
    MessagesScreen(),
    PaymentBody(),
  ];

  void _onItemTapped(int index) {

     if (index == 2) {
    // 👇 Show Add Vehicle Form as modal overlay
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: const AddVehicleForm(),
      ),
    ); 
  } else {
    setState(() => _selectedIndex = index);}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DriverDrawer(), // ✅ Add Drawer
      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ✅ Profile Icon that opens Drawer
            GestureDetector(
              onTap: () => _scaffoldKey.currentState!.openDrawer(),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),

          ShaderMask(
        shaderCallback: (Rect bounds) => const LinearGradient(
          colors: [Color.fromARGB(255, 59, 169, 236), Color.fromARGB(255, 1, 1, 78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Text(
          "Let's Explore",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // color gets replaced by shader
            letterSpacing: 1.2,
          ),
        ),
      ),



            // 🔔 Notification icon with badge
            Stack(
              children: [
                const Icon(Icons.notifications_none,
                    size: 28, color: Colors.black),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    height: 14,
                    width: 14,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // ✅ Body changes according to bottom navigation
      body: _pages[_selectedIndex],

      // ✅ Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.access_time), label: "Requests"),
               BottomNavigationBarItem(
              icon: Icon(Icons.add), label: "Add vehicle"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          BottomNavigationBarItem(
              icon: Icon(Icons.payment), label: "Payments"),
        ],
      ),
    );
  }
}
