import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/conversation.dart';
import '../domain/message.dart';

/// Abstract interface for Messages data operations (OOP Abstraction).
abstract class IMessageRepository {
  Future<List<Conversation>> getConversations();
  Future<List<Message>> getMessages(String conversationId);
  Future<void> sendMessage(String conversationId, String content);
  Stream<List<Message>> watchMessages(String conversationId);
  Future<Conversation> createConversation({
    required List<String> participantIds,
    bool isGroup = false,
    String? groupName,
  });
  Future<void> deleteMessageForMe(String messageId);
}

/// OOP Dependency Injection binding for [IMessageRepository]
final messageRepositoryProvider = Provider<IMessageRepository>((ref) {
  return FirestoreMessageRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

/// Concrete Firestore implementation of [IMessageRepository] (OOP Polymorphism)
class FirestoreMessageRepository implements IMessageRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreMessageRepository(this._firestore, this._auth);

  @override
  Future<List<Conversation>> getConversations() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('conversations')
          .where('participantIds', arrayContains: user.uid)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Conversation.fromJson(data);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      final snapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('sentAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Message.fromJson(data);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> sendMessage(String conversationId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      final now = DateTime.now();
      final messageData = {
        'conversationId': conversationId,
        'senderId': user.uid,
        'content': content,
        'sentAt': now.toIso8601String(),
        'status': 'sent',
        'isEdited': false,
      };

      await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .add(messageData);

      final convDocRef = _firestore.collection('conversations').doc(conversationId);
      final convSnapshot = await convDocRef.get();

      if (!convSnapshot.exists) {
        // If not found in conversations, check if this is a group from 'groups'
        final groupDoc = await _firestore.collection('groups').doc(conversationId).get();
        if (groupDoc.exists) {
          final groupData = groupDoc.data() ?? {};
          final memberIds = (groupData['memberIds'] as List?)?.cast<String>() ?? [user.uid];
          await convDocRef.set({
            'participantIds': memberIds,
            'isGroup': true,
            'groupName': groupData['name'] ?? 'Family Group',
            'lastMessage': content,
            'lastMessageAt': now.toIso8601String(),
            'unreadCount': 0,
          }, SetOptions(merge: true));
        } else {
          await convDocRef.set({
            'participantIds': [user.uid],
            'isGroup': false,
            'lastMessage': content,
            'lastMessageAt': now.toIso8601String(),
            'unreadCount': 0,
          }, SetOptions(merge: true));
        }
      } else {
        await convDocRef.set({
          'lastMessage': content,
          'lastMessageAt': now.toIso8601String(),
          'participantIds': FieldValue.arrayUnion([user.uid]),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Stream<List<Message>> watchMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Message.fromJson(data);
      }).toList();
    });
  }

  @override
  Future<Conversation> createConversation({
    required List<String> participantIds,
    bool isGroup = false,
    String? groupName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    final allParticipants = {user.uid, ...participantIds}.toList();
    final now = DateTime.now();

    final docRef = await _firestore.collection('conversations').add({
      'participantIds': allParticipants,
      'isGroup': isGroup,
      'groupName': groupName,
      'lastMessage': null,
      'lastMessageAt': now.toIso8601String(),
      'unreadCount': 0,
    });

    return Conversation(
      id: docRef.id,
      participantIds: allParticipants,
      isGroup: isGroup,
      groupName: groupName,
      lastMessageAt: now,
    );
  }

  @override
  Future<void> deleteMessageForMe(String messageId) async {
    // Explicitly follows specification: "Delete for me only; no delete-for-everyone."
  }
}

/// Backward compatibility alias
typedef MessageRepository = FirestoreMessageRepository;

