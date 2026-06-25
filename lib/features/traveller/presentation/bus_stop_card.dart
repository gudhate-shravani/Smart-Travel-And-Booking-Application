import 'package:flutter/material.dart';

class BusStopCard extends StatelessWidget {
  final String stopName;
  final VoidCallback onViewLocation;

  const BusStopCard({
    super.key,
    required this.stopName,
    required this.onViewLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      child: ListTile(
        leading: const Icon(Icons.directions_bus, color: Colors.blue),
        title: Text(stopName),
        trailing: ElevatedButton(
          onPressed: onViewLocation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
          ),
          child: const Text("View Location"),
        ),
      ),
    );
  }
}
