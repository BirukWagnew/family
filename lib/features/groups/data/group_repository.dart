import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/family_group.dart';

/// Abstract interface for Family Groups data operations (OOP Abstraction).
abstract class IGroupRepository {
  Future<List<FamilyGroup>> getMyGroups();
  Future<FamilyGroup> createGroup(String name, String description, List<String> initialMemberIds);
}

/// OOP Dependency Injection binding for [IGroupRepository]
final groupRepositoryProvider = Provider<IGroupRepository>((ref) {
  return FirestoreGroupRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

/// Concrete Firestore implementation of [IGroupRepository] (OOP Polymorphism)
class FirestoreGroupRepository implements IGroupRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreGroupRepository(this._firestore, this._auth);

  @override
  Future<List<FamilyGroup>> getMyGroups() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('groups')
          .where('memberIds', arrayContains: user.uid)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return FamilyGroup.fromJson(data);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<FamilyGroup> createGroup(String name, String description, List<String> initialMemberIds) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    final memberIds = [user.uid, ...initialMemberIds];

    try {
      final now = DateTime.now();
      final docRef = await _firestore.collection('groups').add({
        'name': name,
        'description': description,
        'ownerId': user.uid,
        'memberIds': memberIds,
        'memberCount': memberIds.length,
        'createdAt': now.toIso8601String(),
      });

      // Synchronize with conversations collection so ChatScreen and Messages list work seamlessly
      await _firestore.collection('conversations').doc(docRef.id).set({
        'participantIds': memberIds,
        'isGroup': true,
        'groupName': name,
        'lastMessage': null,
        'lastMessageAt': now.toIso8601String(),
        'unreadCount': 0,
      }, SetOptions(merge: true));

      return FamilyGroup(
        id: docRef.id,
        name: name,
        ownerId: user.uid,
        description: description,
        memberIds: memberIds,
        memberCount: memberIds.length,
        createdAt: now,
      );
    } catch (e) {
      throw e.toString();
    }
  }
}

/// Backward compatibility alias
typedef GroupRepository = FirestoreGroupRepository;

