import 'package:flutter/material.dart';
import 'chat_detail_screen.dart'; // Ensure correct path

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Messages',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Communities'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChatList(context),
            _buildCommunityList(context),
          ],
        ),
      ),
    );
  }

  /// ✅ Chats tab
  Widget _buildChatList(BuildContext context) {
    final List<Map<String, dynamic>> chats = [
      {
        'name': 'Alex',
        'message': 'See you tomorrow!',
        'time': '10:42 AM',
        'avatar': 'https://i.pravatar.cc/150?img=32',
        'isOnline': true
      },
      {
        'name': 'Maria',
        'message': 'Payment received, thank you!',
        'time': 'Yesterday',
        'avatar': 'https://i.pravatar.cc/150?img=31',
        'isOnline': false
      },
    ];

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];

        final String name = chat['name'] as String? ?? '';
        final String message = chat['message'] as String? ?? '';
        final String time = chat['time'] as String? ?? '';
        final String avatar = chat['avatar'] as String? ?? '';
        final bool isOnline = chat['isOnline'] as bool? ?? false;

        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(avatar),
              ),
              if (isOnline)
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.green,
                  ),
                ),
            ],
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  name: name,
                  avatar: avatar,
                  isOnline: isOnline,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ✅ Communities tab
  Widget _buildCommunityList(BuildContext context) {
    final List<Map<String, String>> communities = [
      {
        'name': 'Delhi Guides Union',
        'message': 'Ankit: New regulations announced...',
        'time': '1:15 PM',
        'avatar': 'https://i.pravatar.cc/150?img=50',
      },
    ];

    return ListView.builder(
      itemCount: communities.length,
      itemBuilder: (context, index) {
        final community = communities[index];

        final String name = community['name'] ?? '';
        final String message = community['message'] ?? '';
        final String time = community['time'] ?? '';
        final String avatar = community['avatar'] ?? '';

        return ListTile(
          leading: CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(avatar),
            child: const Align(
              alignment: Alignment.bottomRight,
              child: CircleAvatar(
                radius: 8,
                backgroundColor: Colors.white,
                child: Icon(Icons.group, size: 12, color: Colors.black),
              ),
            ),
          ),
          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
            message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatDetailScreen(
                  name: name,
                  avatar: avatar,
                  isOnline: true,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
