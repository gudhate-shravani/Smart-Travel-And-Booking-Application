// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:travelapplication/features/guide/presentation/home_screen.dart' as guide;
import 'package:travelapplication/features/traveller/presentation/drawer.dart';
import 'package:travelapplication/features/traveller/presentation/homepae.dart';
import 'package:travelapplication/features/traveller/presentation/nearby_essential.dart';
import 'package:travelapplication/features/traveller/presentation/ride.dart';
import 'package:travelapplication/features/traveller/presentation/search_people_screen.dart';


class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<UserDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TravelDashboardBody(),
   SearchPeopleScreen(),
  //  const TransportPlannerScreen(),
     guide.HomeScreen(),
    BookRideScreen(),
     guide.HomeScreen(),
  ];

 void _onItemTapped(int index) {

    /* if (index == 2) {
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
  } else {*/
    setState(() => _selectedIndex = index);}
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(), // ✅ Add Drawer
      backgroundColor: Colors.grey[100],

      /*appBar: AppBar(
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
            
            // 🔔 Notification icon with badge
             ShaderMask(
        shaderCallback: (Rect bounds) => const LinearGradient(
          colors: [Colors.purpleAccent, Colors.blueAccent],
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

           
             
          ],
        ),
      ),*/
      appBar: AppBar(
  backgroundColor: Colors.grey[100],
  elevation: 0,
  automaticallyImplyLeading: false,
  title: Stack(
    alignment: Alignment.center,
    children: [
      // 👤 Left profile icon
      Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () => _scaffoldKey.currentState!.openDrawer(),
          child: const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
        ),
      ),

      // 🌈 Center title
      ShaderMask(
        shaderCallback: (Rect bounds) => const LinearGradient(
          colors: [Colors.purpleAccent, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        child: const Text(
          "Let's Explore",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    ],
  ),
),


      // ✅ Body changes according to bottom navigation
      body: _pages[_selectedIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NearbyEssentialsScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child:  Icon(Icons.location_city_outlined, color: Colors.white),
      ),

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
              icon: Icon(Icons.search), label: "search people"),
             //  BottomNavigationBarItem(
             // icon: Icon(Icons.add), label: "track your trip"),
          BottomNavigationBarItem(
              icon: Icon(Icons.travel_explore), label: "book guide"),
          BottomNavigationBarItem(
              icon: Icon(Icons.directions_bike), label: "book vehicle"),
               BottomNavigationBarItem(
              icon: Icon(Icons.train), label: "public transport")
        ],
      ),
    );
  }

}