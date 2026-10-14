import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../common/presentation/widgets/app_empty_state.dart';
import '../controllers/family_controller.dart';
import '../coordinators/family_coordinator.dart';
import '../widgets/person_avatar.dart';
import '../../domain/base_person.dart';
import '../../domain/family_request.dart';

class FamilyScreen extends ConsumerWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coordinator = ref.watch(familyCoordinatorProvider);
    final familyState = ref.watch(familyControllerProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Circle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Invite member',
            onPressed: () => coordinator.inviteFamilyMember(context),
          ),
        ],
      ),
      body: familyState.isLoading && familyState.members.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppColors.primaryRose,
              onRefresh: () =>
                  ref.read(familyControllerProvider.notifier).refresh(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: AppColors.blush.withValues(alpha: 0.28),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: AppColors.primaryRose,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${familyState.members.length} of 40 members',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  familyState.availableSlots > 0
                                      ? '${familyState.availableSlots} slots left'
                                      : 'Circle is full',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: familyState.availableSlots > 5
                                        ? muted
                                        : AppColors.danger,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (familyState.availableSlots > 0)
                            FilledButton.tonalIcon(
                              onPressed: () =>
                                  coordinator.inviteFamilyMember(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Invite'),
                              style: FilledButton.styleFrom(
                                foregroundColor: AppColors.primaryRose,
                                backgroundColor:
                                    AppColors.softRose.withValues(alpha: 0.25),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  if (familyState.pendingRequests.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Pending (${familyState.pendingRequests.length})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...familyState.pendingRequests.map((req) {
                      final isIncoming =
                          req.direction == RequestDirection.incoming;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.softRose,
                            child: Text(
                              req.otherUserFullName.isNotEmpty
                                  ? req.otherUserFullName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            req.otherUserFullName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            isIncoming
                                ? '@${req.otherUserUsername} wants to join'
                                : 'Invite sent to @${req.otherUserUsername}',
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                          trailing: isIncoming
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Accept',
                                      icon: const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.success,
                                      ),
                                      onPressed: () => ref
                                          .read(
                                              familyControllerProvider.notifier)
                                          .acceptRequest(req.id),
                                    ),
                                    IconButton(
                                      tooltip: 'Decline',
                                      icon: const Icon(
                                        Icons.cancel_rounded,
                                        color: AppColors.danger,
                                      ),
                                      onPressed: () => ref
                                          .read(
                                              familyControllerProvider.notifier)
                                          .rejectRequest(req.id),
                                    ),
                                  ],
                                )
                              : Chip(
                                  label: Text(
                                    'Sent',
                                    style: TextStyle(fontSize: 11, color: muted),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 24),
                  Text(
                    'Members (${familyState.members.length})',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (familyState.members.isEmpty)
                    Card(
                      child: AppEmptyState(
                        icon: Icons.group_add_rounded,
                        title: 'No members yet',
                        message:
                            'Invite family to share stories, photos, and messages together.',
                        actionLabel: 'Invite member',
                        actionIcon: Icons.person_add_alt_1_rounded,
                        onAction: () =>
                            coordinator.inviteFamilyMember(context),
                      ),
                    )
                  else
                    ...familyState.members.map((member) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: PersonAvatar(
                            person: member,
                            radius: 20,
                            showLabel: false,
                          ),
                          title: Text(
                            member.displayName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '@${member.username}',
                            style: TextStyle(fontSize: 12, color: muted),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
