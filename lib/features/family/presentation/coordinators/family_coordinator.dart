import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../messages/presentation/screens/chat_screen.dart';
import '../widgets/invite_family_dialog.dart';
import '../../../groups/presentation/widgets/create_group_dialog.dart';

/// Abstract coordinator contract for all Family and Circle navigation/actions (OOP Abstraction & ISP).
abstract class IFamilyCoordinator {
  void inviteFamilyMember(BuildContext context);
  void createFamilyGroup(BuildContext context);
  void navigateToFamilyCircle(BuildContext context);
  void navigateToGroupChat(
    BuildContext context, {
    required String groupId,
    required String groupName,
  });
  void navigateToComposer(BuildContext context);
  void navigateToProfile(BuildContext context);
}

/// Concrete coordinator implementation binding UI actions through Riverpod (OOP Encapsulation & Polymorphism).
class FamilyCoordinator implements IFamilyCoordinator {
  const FamilyCoordinator();

  @override
  void inviteFamilyMember(BuildContext context) {
    showInviteFamilyDialog(context);
  }

  @override
  void createFamilyGroup(BuildContext context) {
    showCreateGroupDialog(context);
  }

  @override
  void navigateToFamilyCircle(BuildContext context) {
    context.push('/family');
  }

  @override
  void navigateToGroupChat(
    BuildContext context, {
    required String groupId,
    required String groupName,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          conversationId: groupId,
          title: groupName,
        ),
      ),
    );
  }

  @override
  void navigateToComposer(BuildContext context) {
    context.push('/composer');
  }

  @override
  void navigateToProfile(BuildContext context) {
    context.push('/profile');
  }
}

/// OOP Dependency Injection binding provider
final familyCoordinatorProvider = Provider<IFamilyCoordinator>((ref) {
  return const FamilyCoordinator();
});
