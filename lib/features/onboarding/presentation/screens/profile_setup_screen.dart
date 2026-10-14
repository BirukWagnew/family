import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../common/data/media_service.dart';
import '../../../common/presentation/utils/image_utils.dart';
import '../../../common/presentation/widgets/photo_source_picker_sheet.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;

  String? _photoUrl;
  bool _isUploadingPhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _photoUrl = user?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onPhotoActionSelected(PhotoSourceAction action) async {
    if (action == PhotoSourceAction.remove) {
      setState(() => _photoUrl = '');
      return;
    }

    final source = action == PhotoSourceAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final mediaService = ref.read(mediaServiceProvider);
    final user = ref.read(authControllerProvider).user;
    final userId = user?.id ?? 'setup_${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isUploadingPhoto = true);
    try {
      final picked = await mediaService.pickImage(source: source);
      if (picked == null) {
        if (mounted) setState(() => _isUploadingPhoto = false);
        return;
      }

      final downloadUrl = await mediaService.uploadMedia(
        file: picked,
        path: 'users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (mounted) {
        setState(() {
          _photoUrl = downloadUrl;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo ready!'),
            backgroundColor: AppColors.primaryRose,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        final errorMsg = e.toString().contains('denied')
            ? 'Permission denied. Please grant camera and storage permissions in device settings.'
            : 'Failed to access camera/device photo: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _finishSetup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            fullName: name,
            username: _usernameController.text.trim(),
            bio: _bioController.text.trim(),
            photoUrl: _photoUrl,
          );

      if (mounted) {
        context.go('/hub');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set up your profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: PopupMenuButton<PhotoSourceAction>(
                tooltip: 'Change Photo (Camera or Device)',
                enabled: !(_isUploadingPhoto || _isSaving),
                onSelected: _onPhotoActionSelected,
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: PhotoSourceAction.camera,
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt, color: AppColors.primaryRose, size: 20),
                        SizedBox(width: 12),
                        Text('Take Photo (Camera)', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: PhotoSourceAction.gallery,
                    child: Row(
                      children: [
                        Icon(Icons.photo_library, color: AppColors.primaryRose, size: 20),
                        SizedBox(width: 12),
                        Text('Choose from Device', style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  if (_photoUrl != null && _photoUrl!.isNotEmpty)
                    const PopupMenuItem(
                      value: PhotoSourceAction.remove,
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                          SizedBox(width: 12),
                          Text('Remove Photo', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                ],
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.softRose.withValues(alpha: 0.35),
                      backgroundImage: appImageProvider(_photoUrl),
                      child: _isUploadingPhoto
                          ? const SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                color: AppColors.primaryRose,
                                strokeWidth: 3,
                              ),
                            )
                          : (_photoUrl == null || _photoUrl!.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 52,
                                  color: AppColors.primaryRose,
                                )
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRose,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Tap photo to add a picture',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                ),
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixText: '@',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio (optional)',
                hintText: 'A little note to your family…',
                prefixIcon: Icon(Icons.info_outline_rounded),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: (_isSaving || _isUploadingPhoto) ? null : _finishSetup,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enter Family Hub'),
            ),
          ],
        ),
      ),
    );
  }
}
