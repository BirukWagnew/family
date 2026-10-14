import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../common/presentation/widgets/app_empty_state.dart';
import '../../../common/presentation/widgets/app_error_view.dart';
import '../../../messages/presentation/screens/chat_screen.dart';
import '../controllers/groups_controller.dart';
import '../widgets/create_group_dialog.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(groupsControllerProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            tooltip: 'Create group',
            icon: const Icon(Icons.group_add_rounded),
            onPressed: () => showCreateGroupDialog(context, ref),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => AppErrorView(
          message: 'Groups couldn’t load. Check your connection and try again.',
          onRetry: () => ref.read(groupsControllerProvider.notifier).refresh(),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return AppEmptyState(
              icon: Icons.groups_rounded,
              title: 'No groups yet',
              message:
                  'Create a smaller space for siblings, cousins, or any branch of the family.',
              actionLabel: 'Create group',
              actionIcon: Icons.add_rounded,
              onAction: () => showCreateGroupDialog(context, ref),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryRose,
            onRefresh: () =>
                ref.read(groupsControllerProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.softRose.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.groups_rounded, color: Colors.white),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${group.memberCount} members',
                      style: TextStyle(color: muted),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: muted,
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            conversationId: group.id,
                            title: group.name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateGroupDialog(context, ref),
        tooltip: 'Create group',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
