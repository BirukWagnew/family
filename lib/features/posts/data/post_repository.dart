import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/post.dart';
import '../domain/comment.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository(
    FirebaseFirestore.instance,
    FirebaseAuth.instance,
  );
});

class PostRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  PostRepository(this._firestore, this._auth);

  Future<List<Post>> getFeed() async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Post.fromJson(data);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Stream<List<Post>> watchFeed() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Post.fromJson(data);
      }).toList();
    });
  }

  Future<void> createPost(
    String content, {
    PostType type = PostType.text,
    String? mediaUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    String authorName = user.displayName ?? 'Family Member';
    String? authorPhotoUrl = user.photoURL;
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        authorName = data['fullName'] as String? ?? authorName;
        authorPhotoUrl = data['photoUrl'] as String? ?? authorPhotoUrl;
      }
    } catch (_) {}

    try {
      await _firestore.collection('posts').add({
        'authorId': user.uid,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'content': content,
        'type': type.name,
        'mediaUrl': mediaUrl,
        'reactionCount': 0,
        'commentCount': 0,
        'likedBy': [],
        'createdAt': DateTime.now().toIso8601String(),
        'isEdited': false,
      });
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> toggleLike(String postId) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    final postRef = _firestore.collection('posts').doc(postId);

    try {
      final postDoc = await postRef.get();
      if (!postDoc.exists) throw 'Post not found';

      final postData = postDoc.data() ?? {};
      final likedBy = (postData['likedBy'] as List?)?.map((e) => e.toString()).toList() ?? [];

      if (likedBy.contains(user.uid)) {
        await postRef.update({
          'likedBy': FieldValue.arrayRemove([user.uid]),
          'reactionCount': FieldValue.increment(-1),
        });
      } else {
        await postRef.update({
          'likedBy': FieldValue.arrayUnion([user.uid]),
          'reactionCount': FieldValue.increment(1),
        });
      }
    } catch (e) {
      throw e.toString();
    }
  }

  Stream<List<Comment>> watchComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['postId'] = postId;
        return Comment.fromJson(data);
      }).toList();
    });
  }

  Future<List<Comment>> getComments(String postId) async {
    try {
      final snapshot = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['postId'] = postId;
        return Comment.fromJson(data);
      }).toList();
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> addComment(String postId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not authenticated';

    final trimmed = content.trim();
    if (trimmed.isEmpty) throw 'Comment cannot be empty';

    String authorName = user.displayName ?? 'Family Member';
    String? authorPhotoUrl = user.photoURL;
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        authorName = data['fullName'] as String? ?? authorName;
        authorPhotoUrl = data['photoUrl'] as String? ?? authorPhotoUrl;
      }
    } catch (_) {}

    try {
      final now = DateTime.now();
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
        'postId': postId,
        'authorId': user.uid,
        'authorName': authorName,
        'authorPhotoUrl': authorPhotoUrl,
        'content': trimmed,
        'createdAt': now.toIso8601String(),
      });

      await _firestore.collection('posts').doc(postId).update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw e.toString();
    }
  }
}
