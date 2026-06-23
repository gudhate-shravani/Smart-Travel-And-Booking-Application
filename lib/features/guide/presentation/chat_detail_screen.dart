import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatDetailScreen extends StatefulWidget {
  final String name;
  final String avatar;
  final bool isOnline;

  const ChatDetailScreen({
    super.key,
    required this.name,
    required this.avatar,
    this.isOnline = true,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();

  // ✅ Sample conversation
  final List<Map<String, dynamic>> messages = [
    {
      "text": "Hi! I'm interested in the Golden Triangle Tour.",
      "isMe": false,
      "time": "9:45 AM"
    },
    {
      "text":
          "Great choice! I'd be happy to guide you. When would you like to start?",
      "isMe": true,
      "time": "9:47 AM"
    },
    {"text": "How about next Monday?", "isMe": false, "time": "10:15 AM"},
    {"text": "Perfect! I'll prepare everything.", "isMe": true, "time": "10:20 AM"},
    {"text": "Thanks for the amazing tour!", "isMe": false, "time": "10:30 AM"},
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({
          "text": text,
          "isMe": true,
          "time":
              "${TimeOfDay.now().hourOfPeriod}:${TimeOfDay.now().minute.toString().padLeft(2, '0')} ${TimeOfDay.now().period == DayPeriod.am ? 'AM' : 'PM'}"
        });
      });
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAsset = !widget.avatar.startsWith('http');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leadingWidth: 40,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: isAsset
                  ? AssetImage(widget.avatar) as ImageProvider
                  : NetworkImage(widget.avatar),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black),
                ),
                Text(
                  widget.isOnline ? "Online" : "Offline",
                  style: TextStyle(
                    color: widget.isOnline ? Colors.green : Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            )
          ],
        ),
        actions: const [
          Icon(CupertinoIcons.phone, color: Colors.black87),
          SizedBox(width: 16),
          Icon(CupertinoIcons.videocam, color: Colors.black87),
          SizedBox(width: 16),
          Icon(CupertinoIcons.ellipsis_vertical, color: Colors.black87),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // ✅ Chat messages list
          Expanded(
            child: ListView.builder(
              reverse: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final bool isMe = msg["isMe"] as bool;
                final String text = msg["text"] as String;
                final String time = msg["time"] as String;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color(0xFF7B61FF)
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft:
                            isMe ? const Radius.circular(14) : Radius.zero,
                        bottomRight:
                            isMe ? Radius.zero : const Radius.circular(14),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          text,
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: TextStyle(
                            color: isMe
                                ? Colors.white70
                                : Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ Message input field
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.add_circled),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      CupertinoIcons.paperplane_fill,
                      color: Color(0xFF7B61FF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
