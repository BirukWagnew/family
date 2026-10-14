import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../controllers/groups_controller.dart';

void showCreateGroupDialog(BuildContext context, [WidgetRef? ref]) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => const _CreateGroupBottomSheet(),
  );
}

class _CreateGroupBottomSheet extends ConsumerStatefulWidget {
  const _CreateGroupBottomSheet();

  @override
  ConsumerState<_CreateGroupBottomSheet> createState() =>
      _CreateGroupBottomSheetState();
}

class _CreateGroupBottomSheetState
    extends ConsumerState<_CreateGroupBottomSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final Set<String> _selectedMemberIds = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(groupsControllerProvider.notifier).createGroup(
            name,
            _descController.text.trim(),
            _selectedMemberIds.toList(),
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Family Group "$name" created successfully!'),
            backgroundColor: AppColors.primaryRose,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create group: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyControllerProvider);
    final availableMembers = familyState.members;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.softRose.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.group_add, color: AppColors.primaryRose),
              ),
              const SizedBox(width: 14),
              Text(
                'Create Family Group',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepCharcoal,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Group Name *',
              hintText: 'e.g., Immediate Family, Cousins, Vacation',
              prefixIcon: Icon(Icons.groups, color: AppColors.primaryRose),
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'What is this group for?',
              prefixIcon: Icon(Icons.description, color: AppColors.warmBrown),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          if (availableMembers.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Add Family Members (${_selectedMemberIds.length} selected):',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableMembers.length,
                itemBuilder: (context, index) {
                  final member = availableMembers[index];
                  final isSelected = _selectedMemberIds.contains(member.id);
                  return CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(member.fullName),
                    subtitle: Text('@${member.username}'),
                    value: isSelected,
                    activeColor: AppColors.primaryRose,
                    onChanged: (bool? val) {
                      setState(() {
                        if (val == true) {
                          _selectedMemberIds.add(member.id);
                        } else {
                          _selectedMemberIds.remove(member.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRose,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Create Group',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
