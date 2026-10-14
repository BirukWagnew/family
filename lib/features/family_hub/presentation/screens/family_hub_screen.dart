import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../common/presentation/utils/image_utils.dart';
import '../../../common/presentation/utils/time_utils.dart';
import '../../../common/presentation/widgets/app_empty_state.dart';
import '../../../common/presentation/widgets/app_error_view.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../../../family/presentation/coordinators/family_coordinator.dart';
import '../../../family/presentation/widgets/person_avatar.dart';
import '../../../groups/presentation/controllers/groups_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../posts/domain/post.dart';
import '../../../posts/domain/comment.dart';
import '../../../posts/data/post_repository.dart';
import '../../../posts/presentation/controllers/feed_controller.dart';

/// Family Hub — home feed with circle, groups, and recent posts.
class FamilyHubScreen extends ConsumerWidget {
  const FamilyHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(familyCoordinatorProvider);
    final familyState = ref.watch(familyControllerProvider);
    final groupsState = ref.watch(groupsControllerProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline_rounded),
            tooltip: 'Family Circle',
            onPressed: () => coordinator.navigateToFamilyCircle(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryRose,
        onRefresh: () async {
          await ref.read(familyControllerProvider.notifier).refresh();
          await ref.read(groupsControllerProvider.notifier).refresh();
          ref.invalidate(feedControllerProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (familyState.error != null) ...[
                AppErrorBanner(
                  message: 'Couldn’t refresh your family circle. Pull to try again.',
                  onRetry: () =>
                      ref.read(familyControllerProvider.notifier).refresh(),
                ),
                const SizedBox(height: 16),
              ],

              // Quick actions — single CTA station (FAB handles new post)
              Card(
                color: AppColors.blush.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: AppColors.softRose.withValues(alpha: 0.28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Invite',
                          onTap: () => coordinator.inviteFamilyMember(context),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.warmBrown.withValues(alpha: 0.15),
                      ),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.group_add_rounded,
                          label: 'New group',
                          onTap: () => coordinator.createFamilyGroup(context),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: AppColors.warmBrown.withValues(alpha: 0.15),
                      ),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.edit_note_rounded,
                          label: 'Write',
                          onTap: () => coordinator.navigateToComposer(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Family Circle
              _SectionHeader(
                icon: Icons.favorite_rounded,
                title: 'Family Circle',
                actionLabel: familyState.members.isEmpty ? null : 'See all',
                onAction: () => coordinator.navigateToFamilyCircle(context),
              ),
              const SizedBox(height: 10),
              if (familyState.isLoading && familyState.members.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (familyState.members.isEmpty)
                Card(
                  child: AppEmptyState(
                    icon: Icons.group_add_rounded,
                    title: 'Build your circle',
                    message:
                        'Invite up to 40 family members to share photos, posts, and chats.',
                    actionLabel: 'Invite member',
                    actionIcon: Icons.person_add_alt_1_rounded,
                    onAction: () => coordinator.inviteFamilyMember(context),
                  ),
                )
              else
                SizedBox(
                  height: 96,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: familyState.members.length +
                        (familyState.availableSlots > 0 ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == familyState.members.length) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () =>
                                coordinator.inviteFamilyMember(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      AppColors.softRose.withValues(alpha: 0.25),
                                  child: const Icon(
                                    Icons.add_rounded,
                                    color: AppColors.primaryRose,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Invite',
                                  style: TextStyle(fontSize: 12, color: muted),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final member = familyState.members[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: PersonAvatar(
                          person: member,
                          onTap: () =>
                              coordinator.navigateToFamilyCircle(context),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 28),

              // Groups
              _SectionHeader(
                icon: Icons.groups_rounded,
                title: 'Groups',
                actionLabel: 'See all',
                onAction: () => context.go('/groups'),
              ),
              const SizedBox(height: 10),
              groupsState.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, _) => AppErrorBanner(
                  message: 'Groups couldn’t load right now.',
                  onRetry: () =>
                      ref.read(groupsControllerProvider.notifier).refresh(),
                ),
                data: (groups) {
                  if (groups.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.softRose.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                color: AppColors.primaryRose,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No groups yet',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Create circles like Siblings or Cousins.',
                                    style: TextStyle(fontSize: 12, color: muted),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  coordinator.createFamilyGroup(context),
                              child: const Text('Create'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SizedBox(
                    height: 108,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Material(
                            color: theme.cardTheme.color ??
                                theme.colorScheme.surface,
                            shape: theme.cardTheme.shape,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => coordinator.navigateToGroupChat(
                                context,
                                groupId: group.id,
                                groupName: group.name,
                              ),
                              child: Container(
                                width: 156,
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.primaryRose
                                              .withValues(alpha: 0.15),
                                          child: const Icon(
                                            Icons.groups_rounded,
                                            size: 18,
                                            color: AppColors.primaryRose,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          size: 16,
                                          color: muted,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          group.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          '${group.memberCount} members',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              // Feed
              _SectionHeader(
                icon: Icons.auto_stories_rounded,
                title: 'Recent posts',
              ),
              const SizedBox(height: 10),
              Consumer(
                builder: (context, ref, _) {
                  final feedState = ref.watch(feedControllerProvider);

                  return feedState.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, _) => AppErrorView(
                      message:
                          'Posts couldn’t load. Check your connection and try again.',
                      onRetry: () => ref.invalidate(feedControllerProvider),
                    ),
                    data: (posts) {
                      if (posts.isEmpty) {
                        return Card(
                          child: AppEmptyState(
                            icon: Icons.post_add_rounded,
                            title: 'No posts yet',
                            message:
                                'Share the first photo or thought with your family.',
                            actionLabel: 'Create post',
                            actionIcon: Icons.edit_rounded,
                            onAction: () =>
                                coordinator.navigateToComposer(context),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return _PostCard(post: posts[index]);
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 72),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => coordinator.navigateToComposer(context),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('Post'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryRose, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryRose, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerWidget {
  final Post post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isLiked = post.isLikedBy(currentUserId);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.softRose,
                  backgroundImage: appImageProvider(post.authorPhotoUrl),
                  child: post.authorPhotoUrl == null ||
                          post.authorPhotoUrl!.isEmpty
                      ? Text(
                          post.authorName.isNotEmpty
                              ? post.authorName[0].toUpperCase()
                              : 'F',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Family · ${formatRelativeTime(post.createdAt)}',
                        style: TextStyle(fontSize: 12, color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(post.content, style: theme.textTheme.bodyLarge),
            if (post.type == PostType.photo &&
                post.mediaUrl != null &&
                post.mediaUrl!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                constraints: const BoxConstraints(maxHeight: 280),
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  post.mediaUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 140,
                    color: AppColors.blush.withValues(alpha: 0.3),
                    child: Icon(Icons.broken_image_outlined, size: 40, color: muted),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 140,
                      color: AppColors.blush.withValues(alpha: 0.15),
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              )
            else if (post.type == PostType.video &&
                post.mediaUrl != null &&
                post.mediaUrl!.isNotEmpty)
              Container(
                height: 180,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_fill_rounded,
                          size: 52, color: Colors.white),
                      SizedBox(height: 8),
                      Text(
                        'Video',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Divider(height: 1, color: theme.dividerColor),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    ref.read(feedControllerProvider.notifier).toggleLike(post.id);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 20,
                          color: isLiked ? AppColors.primaryRose : muted,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.reactionCount}',
                          style: TextStyle(
                            color: isLiked ? AppColors.primaryRose : muted,
                            fontWeight: isLiked ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => _CommentsBottomSheet(post: post),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 20, color: muted),
                        const SizedBox(width: 6),
                        Text(
                          '${post.commentCount}',
                          style: TextStyle(color: muted, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsBottomSheet extends ConsumerStatefulWidget {
  final Post post;

  const _CommentsBottomSheet({required this.post});

  @override
  ConsumerState<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<_CommentsBottomSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    _commentController.clear();

    try {
      await ref.read(feedControllerProvider.notifier).addComment(widget.post.id, text);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post comment: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentsStream = ref.watch(postRepositoryProvider).watchComments(widget.post.id);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 20, color: AppColors.primaryRose),
                  const SizedBox(width: 8),
                  Text(
                    'Comments',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: StreamBuilder<List<Comment>>(
                stream: commentsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final comments = snapshot.data ?? [];
                  if (comments.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 48,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No comments yet',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Be the first to share your thoughts!',
                              style: TextStyle(
                                fontSize: 13,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: comments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.softRose,
                            backgroundImage: appImageProvider(comment.authorPhotoUrl),
                            child: comment.authorPhotoUrl == null || comment.authorPhotoUrl!.isEmpty
                                ? Text(
                                    comment.authorName.isNotEmpty ? comment.authorName[0].toUpperCase() : 'F',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? theme.colorScheme.surface
                                    : const Color(0xFFF3EFEF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        comment.authorName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatRelativeTime(comment.createdAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    comment.content,
                                    style: const TextStyle(fontSize: 14, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write a comment…',
                        filled: true,
                        fillColor: isDark ? theme.scaffoldBackgroundColor : AppColors.warmCream,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryRose,
                      foregroundColor: Colors.white,
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
                    onPressed: _isSubmitting ? null : _submitComment,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
