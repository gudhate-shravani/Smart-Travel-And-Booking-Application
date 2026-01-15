// lib/dashboard_screen.dart

import 'package:flutter/material.dart';
//import 'package.flutter/cupertino.dart';
import 'package:cupertino_icons/cupertino_icons.dart';
import 'package:table_calendar/table_calendar.dart';


// You can create a main.dart file to run this screen:
/*
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        cardTheme: CardTheme(
          elevation: 1,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
*/


// Main Screen Widget
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// Enum to manage the selected tab
enum DashboardTab { calendar, schedule, performance }

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardTab _selectedTab = DashboardTab.calendar;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 241, 247), // Light blue
      appBar: AppBar(
        title: const Text('Smart Calendar'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        automaticallyImplyLeading: true, // Shows back button if possible
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildTabs(),
              const SizedBox(height: 24),
              _buildContent(), // Content changes based on the selected tab
            ],
          ),
        ),
      ),
    );
  }

  // Header Section
  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: const Icon(Icons.calendar_today_outlined, color: Colors.blue, size: 28),
        ),
        const SizedBox(height: 12),
        const Text(
          'Calendar & Schedule',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage your rides and track performance',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  // Tabs for switching content
 /* Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTabItem(DashboardTab.calendar, 'Calendar', Icons.calendar_month_rounded),
        const SizedBox(width: 10),
        _buildTabItem(DashboardTab.schedule, "Today's Schedule", Icons.list_alt_rounded),
        const SizedBox(width: 10),
        _buildTabItem(DashboardTab.performance, 'Performance', Icons.bar_chart_rounded),
      ],
    );
  }*/
  Widget _buildTabs() {
    // Wrap the Row with a SingleChildScrollView
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal, // Allow horizontal scrolling
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTabItem(DashboardTab.calendar, 'Calendar', Icons.calendar_month_rounded),
          const SizedBox(width: 10),
          _buildTabItem(DashboardTab.schedule, "Schedule", Icons.list_alt_rounded),
          const SizedBox(width: 10),
          _buildTabItem(DashboardTab.performance, 'Sumary', Icons.bar_chart_rounded),
        ],
      ),
    );
  }/*
  Widget _buildTabs() {
    return Row(
      children: [
        // Wrap each button with Expanded to make them share space equally
        Expanded(
          child: _buildTabItem(DashboardTab.calendar, 'Calendar', Icons.calendar_month_rounded),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTabItem(DashboardTab.schedule, "Today's Schedule", Icons.list_alt_rounded),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTabItem(DashboardTab.performance, 'Performance', Icons.bar_chart_rounded),
        ),
      ],
    );
  }*/

  Widget _buildTabItem(DashboardTab tab, String label, IconData icon) {
    final bool isSelected = _selectedTab == tab;
    return isSelected
      ? ElevatedButton.icon(
        onPressed: () => setState(() => _selectedTab = tab),
        icon: Icon(icon, size: 14, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      )
      : OutlinedButton.icon(
        onPressed: () => setState(() => _selectedTab = tab),
        icon: Icon(icon, size: 14),
        label: Text(label),
      );
  }

  // Dynamically builds the content based on the selected tab
  Widget _buildContent() {
    switch (_selectedTab) {
      case DashboardTab.calendar:
        return _buildCalendarView();
      case DashboardTab.schedule:
        return _buildScheduleView();
      case DashboardTab.performance:
        return _buildPerformanceView();
    }
  }

  // --- Content for CALENDAR Tab ---
  Widget _buildCalendarView() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Monthly Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(color: Colors.blue.withOpacity(0.5), shape: BoxShape.circle),
                    selectedDecoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          )
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This Month', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('87', 'Rides Completed', 0.73, '33 more to goal', Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatCard('₹42,500', 'Earnings', 0.71, '₹17,500 more to goal', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildStatCard(String value, String label, double progress, String goal, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.2), color: color),
            const SizedBox(height: 4),
            Text(goal, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
  
  // --- Content for SCHEDULE Tab ---
  Widget _buildScheduleView() {
    return Column(
      children: [
        // You can add state management for these filters as well
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
               
                _filterChip('All', 3, true),
                _filterChip('Confirmed', 2, false),
                _filterChip('Pending', 1, false),
              ],
            ),
          )
        ),
        const SizedBox(height: 20),
        _buildRideCard('09:30 AM', '45 mins', 'Rahul Sharma', 'Connaught Place', 'IGI Airport', '₹850', 'confirmed', Icons.flight_takeoff_rounded),
        _buildRideCard('02:15 PM', '60 mins', 'Priya Gupta', 'Karol Bagh', 'Gurgaon Cyber City', '₹1200', 'pending', Icons.business_center_rounded),
        _buildRideCard('06:00 PM', '50 mins', 'Amit Kumar', 'India Gate', 'Dwarka', '₹950', 'confirmed', Icons.home_rounded),
      ],
    );
  }

  Widget _filterChip(String label, int count, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 13)),
          const SizedBox(width: 4),
          CircleAvatar(
            radius: 9,
            backgroundColor: isSelected ? Colors.white.withOpacity(0.3) : Colors.white,
            child: Text(count.toString(), style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildRideCard(String time, String duration, String name, String from, String to, String price, String status, IconData icon) {
    final Color statusColor = status == 'confirmed' ? Colors.green : Colors.orange;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(duration, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Icon(icon, color: Colors.blue.shade300, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(from, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    Text(to, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                Row(
                  children: [
                    OutlinedButton(onPressed: () {}, child: const Text('Navigate')),
                    const SizedBox(width: 10),
                    const Icon(Icons.circle, size: 30, color: Colors.black54),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }


  // --- Content for PERFORMANCE Tab ---
  Widget _buildPerformanceView() {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("This Week's Performance", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.8,
                  children: [
                    _perfStat('28', 'Total Rides', '+12% from last week', Colors.blue),
                    _perfStat('₹15,680', 'Total Earnings', '+8% from last week', Colors.green),
                    _perfStat('45h', 'Hours Worked', '₹348/hour', Colors.orange),
                    _perfStat('96%', 'Completion Rate', '27 of 28', Colors.purple),
                  ],
                ),
              ],
            ),
          )
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Monthly Goals Progress", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _progressGoal('Rides Target', '87 / 120', 87/120),
                const SizedBox(height: 12),
                _progressGoal('Earnings Target', '₹42,500 / ₹60,000', 42500/60000),
              ],
            ),
          )
        ),
      ],
    );
  }

  Widget _perfStat(String value, String label, String subtext, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 10)),
          const SizedBox(height: 4),
          Text(subtext, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _progressGoal(String title, String progressText, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(progressText, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: value, minHeight: 6, borderRadius: BorderRadius.circular(5)),
      ],
    );
  }

}