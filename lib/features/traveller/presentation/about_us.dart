import 'package:flutter/material.dart';
class TeamMember {
  final String name;
  final String role;
  final String description;

  TeamMember({required this.name, required this.role, required this.description});
}

final List<TeamMember> teamMembers = [
];

class ProjectInfoCard extends StatelessWidget {
  const ProjectInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50, 
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: Colors.deepPurple.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'About the Project: Let\'s Explore ðŸŒ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Let\'s Explore is a comprehensive travel companion application built using Flutter. Its core mission is to **simplify and enhance the travel experience** through features like real-time translation, itinerary planning, essential service finding, and a secure document vault. This app aims to be the only tool a traveler needs.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Technologies Used:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildPill('Flutter/Dart', Colors.blue),
              const SizedBox(width: 8),
              _buildPill('Firebase/Backend', Colors.orange),
              const SizedBox(width: 8),
              _buildPill('UI/UX', Colors.pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class TeamCard extends StatelessWidget {
  final TeamMember member;

  const TeamCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(); 
  }
}

class MentorCard extends StatelessWidget {
  final String name;
  final String description;
  static const String mentorImagePath = 'assets/images/shashi_bagal.jpg';

  const MentorCard({
    super.key,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade600, Colors.purple.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(17.0),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          const Text(
            'Guided by Wisdom and Inspiration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.white70,
            ),
          ),
          const Text(
            'Special Thanks To',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          // --- Asset Image Implementation ---
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              // Use DecorationImage with AssetImage
              image: const DecorationImage(
                image: AssetImage(mentorImagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // --- End Asset Image Implementation ---
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});
  final int totalItems = 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), 
      appBar: AppBar(
        title: const Text('About Us'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: totalItems, 
        itemBuilder: (context, index) {
          if (index == 0) {
            return const ProjectInfoCard();
          }  else if (index == 1) {
            return const MentorCard(
              name: 'Shashi Bagal Sir',
              description:
                  'A true mentor whose clarity and enthusiasm make every concept come alive. His teaching inspires innovation and teamwork in every student. Thank you for guiding us.',
            );
          } else {
            // Index 3: Footer Section
            return const Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text(
                  "Let's Explore Â© 2025 | Developed with â¤ï¸ by the Team",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}