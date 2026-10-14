import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../controllers/family_controller.dart';

void showInviteFamilyDialog(BuildContext context, [WidgetRef? ref]) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => const _InviteFamilyBottomSheet(),
  );
}

class _InviteFamilyBottomSheet extends ConsumerStatefulWidget {
  const _InviteFamilyBottomSheet();

  @override
  ConsumerState<_InviteFamilyBottomSheet> createState() =>
      _InviteFamilyBottomSheetState();
}

class _InviteFamilyBottomSheetState
    extends ConsumerState<_InviteFamilyBottomSheet> {
  final _identifierController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    final identifier = _identifierController.text.trim();
    if (identifier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an email or username'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref
          .read(familyControllerProvider.notifier)
          .sendRequest(identifier);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to "$identifier"!'),
            backgroundColor: AppColors.primaryRose,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send invite: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final familyState = ref.watch(familyControllerProvider);
    final availableSlots = familyState.availableSlots;

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
                child: const Icon(Icons.person_add, color: AppColors.primaryRose),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invite to Family Circle',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepCharcoal,
                          ),
                    ),
                    Text(
                      '$availableSlots of 40 member slots remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: availableSlots > 5
                            ? AppColors.warmBrown
                            : AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _identifierController,
            decoration: const InputDecoration(
              labelText: 'Email or Username *',
              hintText: 'e.g., sister@gmail.com or username',
              prefixIcon: Icon(Icons.mail_outline, color: AppColors.primaryRose),
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          const Text(
            'Invited members can view shared posts, join group chats, and stay in touch.',
            style: TextStyle(fontSize: 12, color: AppColors.warmBrown),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (_isLoading || availableSlots <= 0) ? null : _sendInvite,
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
                    'Send Invitation',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}
