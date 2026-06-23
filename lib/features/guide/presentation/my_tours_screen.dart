import 'package:flutter/material.dart';
import 'my_tours_screen.dart';
import 'tour_task_screen.dart' show TourTaskScreen;

class MyToursScreen extends StatelessWidget {
  const MyToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Tours'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTourList(context, 'upcoming'),
            const Center(child: Text('No Active Tours')),
            _buildTourList(context, 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildTourList(BuildContext context, String type) {
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: [
        if (type == 'upcoming')
          _buildTourCard(context, name: 'Tour with The Smiths', location: 'Old Delhi', time: 'Tomorrow, 10:00 AM', isUpcoming: true),
        if (type == 'completed')
          _buildTourCard(context, name: 'Tour with Maria', location: 'Agra Fort', time: '2 days ago'),
      ],
    );
  }

  Widget _buildTourCard(BuildContext context, {required String name, required String location, required String time, bool isUpcoming = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(location),
                  Text(time, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (isUpcoming)
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TourTaskScreen())),
                child: const Text('Start'),
              ),
          ],
        ),
      ),
    );
  }
}
