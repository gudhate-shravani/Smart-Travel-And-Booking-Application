import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationTile(
            title: 'New Tour Booking',
            message: 'A user booked your â€œTaj Mahal Sunrise Tourâ€.',
            time: '2h ago',
            icon: Icons.tour,
          ),
          _buildNotificationTile(
            title: 'Payment Received',
            message: 'â‚¹4,500 has been added to your wallet.',
            time: '5h ago',
            icon: Icons.payment,
          ),
          _buildNotificationTile(
            title: 'New Message',
            message: 'Sarah Johnson sent you a message.',
            time: '1d ago',
            icon: Icons.message_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required String title,
    required String message,
    required String time,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF5F2EEA).withValues(alpha: 0.1),
          child: Icon(icon, color: const Color(0xFF5F2EEA)),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(message,
            style: const TextStyle(fontSize: 13, color: Colors.grey)),
        trailing: Text(time,
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }
}
