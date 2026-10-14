import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../common/presentation/widgets/app_empty_state.dart';
import '../../../common/presentation/widgets/app_error_view.dart';
import '../../data/message_repository.dart';
import '../controllers/conversations_controller.dart';
import 'chat_screen.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(conversationsControllerProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.55);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            tooltip: 'New chat',
            icon: const Icon(Icons.edit_square),
            onPressed: () => _showNewConversationDialog(context, ref),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'Messages couldn’t load. Check your connection and try again.',
          onRetry: () =>
              ref.read(conversationsControllerProvider.notifier).refresh(),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return AppEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No messages yet',
              message: 'Start a private chat with someone in your family.',
              actionLabel: 'Start chat',
              actionIcon: Icons.add_comment_rounded,
              onAction: () => _showNewConversationDialog(context, ref),
            );
          }
          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              indent: 72,
              color: theme.dividerColor,
            ),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final title = conv.groupName ?? 'Family member';
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: CircleAvatar(
                  backgroundColor: AppColors.softRose.withValues(alpha: 0.85),
                  child: Icon(
                    conv.isGroup ? Icons.group_rounded : Icons.person_rounded,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  conv.lastMessage ?? 'Say hi!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted),
                ),
                trailing: conv.unreadCount > 0
                    ? Container(
                        constraints: const BoxConstraints(minWidth: 22),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRose,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          conv.unreadCount > 99
                              ? '99+'
                              : conv.unreadCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        conversationId: conv.id,
                        title: title,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showNewConversationDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New conversation',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Give the chat a name so it’s easy to find later.',
                style: TextStyle(
                  color: Theme.of(ctx)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Chat name',
                  hintText: 'e.g. Mom, Family Chat',
                  prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final name = titleController.text.trim();
                  if (name.isEmpty) return;
                  Navigator.of(ctx).pop();

                  try {
                    final newConv = await ref
                        .read(messageRepositoryProvider)
                        .createConversation(
                          participantIds: [],
                          isGroup: false,
                          groupName: name,
                        );
                    await ref
                        .read(conversationsControllerProvider.notifier)
                        .refresh();

                    if (context.mounted) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            conversationId: newConv.id,
                            title: name,
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Couldn’t start chat. Please try again.'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Start chat'),
              ),
            ],
          ),
        );
      },
    );
  }
}
