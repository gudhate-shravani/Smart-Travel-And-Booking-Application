import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create or get existing chat between user and guide
  Future<String> getOrCreateChat(String userId, String guideId) async {
    final chatQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .get();

    // ✅ Properly typed check with safe orElse returning same type
    final existingChat = chatQuery.docs.firstWhere(
      (doc) {
        final participants = List<String>.from(doc['participants'] ?? []);
        return participants.contains(guideId);
      },
      orElse: () => null as QueryDocumentSnapshot<Map<String, dynamic>>,
    );

    if (existingChat != null) {
      return existingChat.id;
    } else {
      final newChat = await _firestore.collection('chats').add({
        'participants': [userId, guideId],
        'createdAt': FieldValue.serverTimestamp(),
      });
      return newChat.id;
    }
  }

  /// Send a message in a chat
  Future<void> sendMessage(String chatId, String senderId, String message) async {
    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Stream chat messages in real-time
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  /// Get all chats for a user (for chat list screen)
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots();
  }
}
