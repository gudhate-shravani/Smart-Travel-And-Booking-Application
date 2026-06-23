import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'search-bar',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search guides or communities...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('My Communities', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          _buildCommunityItem(name: 'Delhi Guides Union', members: 128),
          const SizedBox(height: 24),
          const Text('Top Guides', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          _buildGuideItem(name: 'Anjali Verma', specialty: 'History & Culture'),
          _buildGuideItem(name: 'Rohan Singh', specialty: 'Food & Street Art'),
        ],
      ),
    );
  }

  Widget _buildCommunityItem({required String name, required int members}) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.group)),
        title: Text(name),
        subtitle: Text('$members members'),
        trailing: ElevatedButton(onPressed: () {}, child: const Text('View')),
      ),
    );
  }
  
  Widget _buildGuideItem({required String name, required String specialty}) {
     return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$name')),
        title: Text(name),
        subtitle: Text(specialty),
        trailing: OutlinedButton(onPressed: () {}, child: const Text('Follow')),
      ),
    );
  }
}
