import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/post.dart';
import '../../data/post_repository.dart';

final feedControllerProvider = AsyncNotifierProvider<FeedController, List<Post>>(() {
  return FeedController();
});

class FeedController extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repo = ref.watch(postRepositoryProvider);
    return repo.getFeed();
  }

  Future<void> refresh() async {
    try {
      final repo = ref.read(postRepositoryProvider);
      final posts = await repo.getFeed();
      state = AsyncValue.data(posts);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createPost(
    String content, {
    PostType type = PostType.text,
    String? mediaUrl,
  }) async {
    final repo = ref.read(postRepositoryProvider);
    await repo.createPost(content, type: type, mediaUrl: mediaUrl);
    await refresh();
  }

  Future<void> toggleLike(String postId) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final currentPosts = state.value;
    if (currentPosts != null && currentUserId != null) {
      final updatedPosts = currentPosts.map((p) {
        if (p.id == postId) {
          final isLiked = p.isLikedBy(currentUserId);
          final newLikedBy = isLiked
              ? p.likedBy.where((id) => id != currentUserId).toList()
              : [...p.likedBy, currentUserId];
          final newCount = isLiked ? (p.reactionCount - 1).clamp(0, 999999) : p.reactionCount + 1;
          return p.copyWith(
            likedBy: newLikedBy,
            reactionCount: newCount,
          );
        }
        return p;
      }).toList();
      state = AsyncValue.data(updatedPosts);
    }

    try {
      final repo = ref.read(postRepositoryProvider);
      await repo.toggleLike(postId);
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> addComment(String postId, String content) async {
    final repo = ref.read(postRepositoryProvider);
    await repo.addComment(postId, content);
    await refresh();
  }
}
