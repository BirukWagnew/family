import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/family_member.dart';
import '../domain/family_request.dart';

/// Abstract interface defining Family data operations (OOP Abstraction & Interface Segregation).
abstract class IFamilyRepository {
  Future<List<FamilyMember>> getFamilyMembers();
  Future<List<FamilyRequest>> getPendingRequests();
  Future<void> sendFamilyRequest(String usernameOrEmail);
  Future<void> acceptRequest(String requestId);
  Future<void> rejectRequest(String requestId);
}

/// OOP Dependency Injection binding: Exposes the abstraction [IFamilyRepository]
final familyRepositoryProvider = Provider<IFamilyRepository>((ref) {
  return FirestoreFamilyRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

/// Concrete Firestore implementation of [IFamilyRepository] (OOP Polymorphism).
class FirestoreFamilyRepository implements IFamilyRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreFamilyRepository(this._firestore, this._auth);

  @override
  Future<List<FamilyMember>> getFamilyMembers() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('family_members')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['username'] = data['username'] ?? 'member';
        data['fullName'] = data['fullName'] ?? 'Family Member';
        if (data['connectedSince'] is Timestamp) {
          data['connectedSince'] = (data['connectedSince'] as Timestamp).toDate().toIso8601String();
        } else if (data['connectedSince'] == null) {
          data['connectedSince'] = DateTime.now().toIso8601String();
        }
        return FamilyMember.fromJson(data);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<List<FamilyRequest>> getPendingRequests() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final userEmail = user.email?.trim().toLowerCase() ?? '';
    String userUsername = user.email?.split('@')[0].toLowerCase() ?? '';

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        userUsername = (data['username'] as String? ?? userUsername).trim().toLowerCase();
      }
    } catch (_) {}

    try {
      final List<FamilyRequest> results = [];
      final Set<String> seenDocIds = {};

      // 1. Fetch outgoing requests sent by current user
      final outgoingSnap = await _firestore
          .collection('family_requests')
          .where('senderId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in outgoingSnap.docs) {
        seenDocIds.add(doc.id);
        final data = doc.data();
        final rawCreatedAt = data['createdAt'];
        final rawExpiresAt = data['expiresAt'];

        String createdAt = DateTime.now().toIso8601String();
        if (rawCreatedAt is Timestamp) {
          createdAt = rawCreatedAt.toDate().toIso8601String();
        } else if (rawCreatedAt is String) {
          createdAt = rawCreatedAt;
        }

        String expiresAt = DateTime.now().add(const Duration(days: 3)).toIso8601String();
        if (rawExpiresAt is Timestamp) {
          expiresAt = rawExpiresAt.toDate().toIso8601String();
        } else if (rawExpiresAt is String) {
          expiresAt = rawExpiresAt;
        }

        results.add(FamilyRequest(
          id: doc.id,
          otherUserId: data['recipientId'] as String? ?? data['targetIdentifier'] as String? ?? data['otherUserId'] as String? ?? '',
          otherUserFullName: data['recipientFullName'] as String? ?? data['otherUserFullName'] as String? ?? data['targetIdentifier'] as String? ?? 'Family Member',
          otherUserUsername: data['recipientUsername'] as String? ?? data['otherUserUsername'] as String? ?? data['targetIdentifier'] as String? ?? 'member',
          otherUserPhotoUrl: data['recipientPhotoUrl'] as String? ?? data['otherUserPhotoUrl'] as String?,
          status: RequestStatus.pending,
          direction: RequestDirection.outgoing,
          createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
          expiresAt: DateTime.tryParse(expiresAt) ?? DateTime.now().add(const Duration(days: 3)),
        ));
      }

      // 2. Fetch incoming requests
      final List<QuerySnapshot<Map<String, dynamic>>> incomingSnapshots = [];

      incomingSnapshots.add(await _firestore
          .collection('family_requests')
          .where('recipientId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get());

      if (userEmail.isNotEmpty) {
        incomingSnapshots.add(await _firestore
            .collection('family_requests')
            .where('targetEmail', isEqualTo: userEmail)
            .where('status', isEqualTo: 'pending')
            .get());
      }

      incomingSnapshots.add(await _firestore
          .collection('family_requests')
          .where('otherUserId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get());

      if (userEmail.isNotEmpty) {
        incomingSnapshots.add(await _firestore
            .collection('family_requests')
            .where('otherUserId', isEqualTo: userEmail)
            .where('status', isEqualTo: 'pending')
            .get());
      }

      if (userUsername.isNotEmpty) {
        incomingSnapshots.add(await _firestore
            .collection('family_requests')
            .where('otherUserId', isEqualTo: userUsername)
            .where('status', isEqualTo: 'pending')
            .get());
      }

      for (final snap in incomingSnapshots) {
        for (final doc in snap.docs) {
          if (seenDocIds.contains(doc.id)) continue;

          final data = doc.data();
          final senderId = data['senderId'] as String? ?? '';
          if (senderId == user.uid) continue;

          seenDocIds.add(doc.id);

          final rawCreatedAt = data['createdAt'];
          final rawExpiresAt = data['expiresAt'];

          String createdAt = DateTime.now().toIso8601String();
          if (rawCreatedAt is Timestamp) {
            createdAt = rawCreatedAt.toDate().toIso8601String();
          } else if (rawCreatedAt is String) {
            createdAt = rawCreatedAt;
          }

          String expiresAt = DateTime.now().add(const Duration(days: 3)).toIso8601String();
          if (rawExpiresAt is Timestamp) {
            expiresAt = rawExpiresAt.toDate().toIso8601String();
          } else if (rawExpiresAt is String) {
            expiresAt = rawExpiresAt;
          }

          results.add(FamilyRequest(
            id: doc.id,
            otherUserId: senderId,
            otherUserFullName: data['senderFullName'] as String? ?? 'Family Member',
            otherUserUsername: data['senderUsername'] as String? ?? 'member',
            otherUserPhotoUrl: data['senderPhotoUrl'] as String?,
            status: RequestStatus.pending,
            direction: RequestDirection.incoming,
            createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
            expiresAt: DateTime.tryParse(expiresAt) ?? DateTime.now().add(const Duration(days: 3)),
          ));
        }
      }

      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return results;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> sendFamilyRequest(String usernameOrEmail) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    final raw = usernameOrEmail.trim();
    if (raw.isEmpty) throw 'Please enter a valid email or username';
    final clean = raw.replaceAll('@', '');
    final cleanEmail = raw.toLowerCase();
    final cleanLower = clean.toLowerCase();

    if (cleanEmail == (user.email?.toLowerCase() ?? '') ||
        cleanLower == (user.email?.split('@')[0].toLowerCase() ?? '') ||
        clean == (user.displayName ?? '')) {
      throw 'You cannot invite yourself.';
    }

    try {
      String targetUid = '';
      String targetFullName = clean;
      String targetUsername = clean;
      String? targetPhotoUrl;
      String targetEmail = cleanEmail;

      QuerySnapshot<Map<String, dynamic>> userQuery = await _firestore
          .collection('users')
          .where('emailLower', isEqualTo: cleanEmail)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        userQuery = await _firestore
            .collection('users')
            .where('email', isEqualTo: raw)
            .limit(1)
            .get();
      }

      if (userQuery.docs.isEmpty) {
        userQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: clean)
            .limit(1)
            .get();
      }

      if (userQuery.docs.isEmpty) {
        userQuery = await _firestore
            .collection('users')
            .where('username', isEqualTo: raw)
            .limit(1)
            .get();
      }

      if (userQuery.docs.isNotEmpty) {
        final targetDoc = userQuery.docs.first;
        targetUid = targetDoc.id;
        final data = targetDoc.data();
        targetFullName = data['fullName'] as String? ?? targetFullName;
        targetUsername = data['username'] as String? ?? targetUsername;
        targetPhotoUrl = data['photoUrl'] as String?;
        targetEmail = data['email'] as String? ?? cleanEmail;

        if (targetUid == user.uid) {
          throw 'You cannot invite yourself.';
        }

        final memberDoc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('family_members')
            .doc(targetUid)
            .get();
        if (memberDoc.exists) {
          throw '$targetFullName is already in your family.';
        }
      } else {
        if (!raw.contains('@')) {
          throw 'No user found with username "@$clean". Please check the spelling or invite by email.';
        }
      }

      final existingPending = await _firestore
          .collection('family_requests')
          .where('senderId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'pending')
          .get();

      final alreadySent = existingPending.docs.any((doc) {
        final data = doc.data();
        final existingRecipientId = data['recipientId'] as String?;
        final existingEmail = (data['targetEmail'] as String?)?.toLowerCase();
        final existingOther = data['otherUserId'] as String?;
        return (targetUid.isNotEmpty && existingRecipientId == targetUid) ||
            existingEmail == cleanEmail ||
            existingOther == raw ||
            existingOther == targetUid;
      });

      if (alreadySent) {
        throw 'An invitation is already pending for this person.';
      }

      String senderFullName = user.displayName ?? 'Family Member';
      String senderUsername = user.email?.split('@')[0] ?? 'member';
      String? senderPhotoUrl = user.photoURL;

      try {
        final senderDoc = await _firestore.collection('users').doc(user.uid).get();
        if (senderDoc.exists && senderDoc.data() != null) {
          final data = senderDoc.data()!;
          senderFullName = data['fullName'] as String? ?? senderFullName;
          senderUsername = data['username'] as String? ?? senderUsername;
          senderPhotoUrl = data['photoUrl'] as String? ?? senderPhotoUrl;
        }
      } catch (_) {}

      final now = DateTime.now();
      await _firestore.collection('family_requests').add({
        'senderId': user.uid,
        'senderFullName': senderFullName,
        'senderUsername': senderUsername,
        'senderPhotoUrl': senderPhotoUrl,
        'recipientId': targetUid,
        'recipientFullName': targetFullName,
        'recipientUsername': targetUsername,
        'recipientPhotoUrl': targetPhotoUrl,
        'targetEmail': targetEmail.toLowerCase(),
        'targetIdentifier': raw,
        'otherUserId': targetUid.isNotEmpty ? targetUid : raw,
        'otherUserFullName': targetFullName,
        'otherUserUsername': targetUsername,
        'status': 'pending',
        'direction': 'outgoing',
        'createdAt': now.toIso8601String(),
        'expiresAt': now.add(const Duration(days: 7)).toIso8601String(),
      });
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> acceptRequest(String requestId) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    try {
      final reqDoc = await _firestore.collection('family_requests').doc(requestId).get();
      if (!reqDoc.exists) throw 'Invitation not found';

      final reqData = reqDoc.data() ?? {};
      final senderId = reqData['senderId'] as String? ?? '';
      if (senderId.isEmpty) throw 'Invalid invitation details';

      await _firestore
          .collection('family_requests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'recipientId': user.uid,
      });

      String senderFullName = reqData['senderFullName'] as String? ?? 'Family Member';
      String senderUsername = reqData['senderUsername'] as String? ?? 'member';
      String? senderPhotoUrl = reqData['senderPhotoUrl'] as String?;
      String? senderBio;

      try {
        final senderDoc = await _firestore.collection('users').doc(senderId).get();
        if (senderDoc.exists && senderDoc.data() != null) {
          final data = senderDoc.data()!;
          senderFullName = data['fullName'] as String? ?? senderFullName;
          senderUsername = data['username'] as String? ?? senderUsername;
          senderPhotoUrl = data['photoUrl'] as String? ?? senderPhotoUrl;
          senderBio = data['bio'] as String?;
        }
      } catch (_) {}

      String recipientFullName = user.displayName ?? 'Family Member';
      String recipientUsername = user.email?.split('@')[0] ?? 'member';
      String? recipientPhotoUrl = user.photoURL;
      String? recipientBio;

      try {
        final recipientDoc = await _firestore.collection('users').doc(user.uid).get();
        if (recipientDoc.exists && recipientDoc.data() != null) {
          final data = recipientDoc.data()!;
          recipientFullName = data['fullName'] as String? ?? recipientFullName;
          recipientUsername = data['username'] as String? ?? recipientUsername;
          recipientPhotoUrl = data['photoUrl'] as String? ?? recipientPhotoUrl;
          recipientBio = data['bio'] as String?;
        }
      } catch (_) {}

      final now = DateTime.now().toIso8601String();

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('family_members')
          .doc(senderId)
          .set({
        'id': senderId,
        'username': senderUsername,
        'fullName': senderFullName,
        'photoUrl': senderPhotoUrl,
        'bio': senderBio,
        'connectedSince': now,
      }, SetOptions(merge: true));

      await _firestore
          .collection('users')
          .doc(senderId)
          .collection('family_members')
          .doc(user.uid)
          .set({
        'id': user.uid,
        'username': recipientUsername,
        'fullName': recipientFullName,
        'photoUrl': recipientPhotoUrl,
        'bio': recipientBio,
        'connectedSince': now,
      }, SetOptions(merge: true));
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Future<void> rejectRequest(String requestId) async {
    try {
      await _firestore
          .collection('family_requests')
          .doc(requestId)
          .update({'status': 'rejected'});
    } catch (e) {
      throw e.toString();
    }
  }
}

/// Backward compatibility alias
typedef FamilyRepository = FirestoreFamilyRepository;
