/*import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DriverDashboard(),
    );
  }
}

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Icon + Notification ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  Stack(
                    children: [
                      const Icon(Icons.notifications_none, size: 28),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                              color: Colors.red, borderRadius: BorderRadius.circular(20)),
                          child: const Center(
                            child: Text('3',
                                style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),

              const SizedBox(height: 16),

              
                    

              const Text(
                "Welcome, Rajesh Kumar 👋",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
                              borderRadius: BorderRadius.circular(6)),
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

              // --- Ride Requests Section ---
              const Text(
                "Requests from Users",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30)),
                        alignment: Alignment.center,
                        child: const Text("Ride Requests",
                            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: const Text("Rental Requests"),
                       
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // --- Requests List ---
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
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
            Text(fare, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.phone, color: Colors.black54)),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54)),
          ],
        )
      ]),
    );
  }
}





import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DriverDashboard(),
    );
  }
}

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  bool isRideSelected = true; // true = Ride, false = Rental

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile + Notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  Stack(
                    children: [
                      const Icon(Icons.notifications_none, size: 28),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          height: 14,
                          width: 14,
                          decoration: BoxDecoration(
                              color: Colors.red, borderRadius: BorderRadius.circular(20)),
                          child: const Center(
                            child: Text('3',
                                style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                "Welcome, Rajesh Kumar 👋",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Text("Ready to start earning today?"),
              const SizedBox(height: 16),

              // Stats Grid
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

              // Today's Summary
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
                              borderRadius: BorderRadius.circular(6)),
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
                              borderRadius: BorderRadius.circular(30)),
                          alignment: Alignment.center,
                          child: Text("Ride Requests",
                              style: TextStyle(
                                color: isRideSelected ? Colors.blue : Colors.black54,
                                fontWeight:
                                    isRideSelected ? FontWeight.bold : FontWeight.normal,
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
                              borderRadius: BorderRadius.circular(30)),
                          alignment: Alignment.center,
                          child: Text("Rental Requests",
                              style: TextStyle(
                                color: !isRideSelected ? Colors.blue : Colors.black54,
                                fontWeight:
                                    !isRideSelected ? FontWeight.bold : FontWeight.normal,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Requests List (Conditional Rendering)
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
                  rentaltime :"2 hour",
                  time: "1:30 PM",
                  fare: "₹500",
                  isNew: true,
                ),
                const SizedBox(height: 12),
                buildRentalRequestCard(
                  name: "Simran Kaur",
                  from: "Saket",
                   rentaltime :"2 hour",
                  time: "4:00 PM",
                  fare: "₹350",
                  isNew: false,
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
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
            Text(fare, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.phone, color: Colors.black54)),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54)),
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
                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
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
            Text("Rental time : $rentaltime"),
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
            Text(fare, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.phone, color: Colors.black54)),
            IconButton(
                onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline, color: Colors.black54)),
          ],
        )
      ]),
    );
  }
}
*/






















































/*


import 'package:flutter/material.dart';
import 'request_pae.dart';
import 'homepae.dart';
import 'messages.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DriverDashboard(),
    );
  }
}

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  bool isRideSelected = true; // true = Ride tab selected
  int _selectedIndex = 0; // bottom navigation current index

 final List<Widget> _pages = const [
    HomePage(),
    RequestsPage(),
   MessagesScreen(),
   // PaymentsPage(),
  ];




  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

   

 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(



      appBar: AppBar(
         backgroundColor: Colors.grey[100],
     // backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false, // remove default back arrow
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Profile Avatar
          
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),

          // Notification Icon with Badge
          Stack(
            children: [
              const Icon(Icons.notifications_none, size: 28, color: Colors.black),
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



      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Requests"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "Payments"),
        ],
      ),
      body: 
       _pages[_selectedIndex],
  );}
*/






































































































  /*    
      SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Profile Icon + Notification ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  Stack(
                    children: [
                      const Icon(Icons.notifications_none, size: 28),
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
                            child: Text('3',
                                style: TextStyle(color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                "Welcome, Rajesh Kumar 👋",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
    );}*/
  
/*
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
  }*/



  

import 'package:flutter/material.dart';
import 'homepage.dart';
import 'request_pae.dart';
import 'messages.dart';
import 'driver_drawer.dart'; // ⬅️ your drawer file
import 'payment.dart';
import 'add_vehicle.dart';
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
