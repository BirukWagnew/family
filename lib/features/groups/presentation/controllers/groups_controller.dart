import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/family_group.dart';
import '../../data/group_repository.dart';

final groupsControllerProvider = AsyncNotifierProvider<GroupsController, List<FamilyGroup>>(() {
  return GroupsController();
});

class GroupsController extends AsyncNotifier<List<FamilyGroup>> {
  @override
  Future<List<FamilyGroup>> build() async {
    final repo = ref.watch(groupRepositoryProvider);
    return repo.getMyGroups();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(groupRepositoryProvider);
      final groups = await repo.getMyGroups();
      state = AsyncValue.data(groups);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> createGroup(String name, String description, List<String> initialMembers) async {
    final repo = ref.read(groupRepositoryProvider);
    await repo.createGroup(name, description, initialMembers);
    await refresh();
  }
}
