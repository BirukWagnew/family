import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../common/data/media_service.dart';
import '../../../common/presentation/utils/image_utils.dart';
import '../../../common/presentation/widgets/photo_source_picker_sheet.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({super.key});

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  bool _isUpdatingPhoto = false;

  void _showEditProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _EditProfileBottomSheet(),
    );
  }

  Future<void> _onPhotoActionSelected(PhotoSourceAction action) async {
    if (_isUpdatingPhoto) return;

    if (action == PhotoSourceAction.remove) {
      setState(() => _isUpdatingPhoto = true);
      try {
        await ref.read(authControllerProvider.notifier).updateProfile(
              photoUrl: '',
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile photo removed'),
              backgroundColor: AppColors.primaryRose,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove photo: $e'),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isUpdatingPhoto = false);
      }
      return;
    }

    final source = action == PhotoSourceAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final mediaService = ref.read(mediaServiceProvider);
    final user = ref.read(authControllerProvider).user;
    final userId = user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

    setState(() => _isUpdatingPhoto = true);
    try {
      final picked = await mediaService.pickImage(source: source);
      if (picked == null) {
        if (mounted) setState(() => _isUpdatingPhoto = false);
        return;
      }

      final downloadUrl = await mediaService.uploadMedia(
        file: picked,
        path: 'users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await ref.read(authControllerProvider.notifier).updateProfile(
            photoUrl: downloadUrl,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: AppColors.primaryRose,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().contains('denied')
            ? 'Permission denied. Please grant camera and photo permissions in device settings.'
            : 'Failed to update photo: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingPhoto = false);
      }
    }
  }

  List<PopupMenuEntry<PhotoSourceAction>> _buildPhotoMenuItems({
    required bool hasExistingPhoto,
  }) {
    return [
      const PopupMenuItem<PhotoSourceAction>(
        value: PhotoSourceAction.camera,
        child: Row(
          children: [
            Icon(Icons.camera_alt, color: AppColors.primaryRose, size: 20),
            SizedBox(width: 12),
            Text('Take Photo (Camera)', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      const PopupMenuItem<PhotoSourceAction>(
        value: PhotoSourceAction.gallery,
        child: Row(
          children: [
            Icon(Icons.photo_library, color: AppColors.primaryRose, size: 20),
            SizedBox(width: 12),
            Text('Choose from Device', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      if (hasExistingPhoto)
        const PopupMenuItem<PhotoSourceAction>(
          value: PhotoSourceAction.remove,
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
              SizedBox(width: 12),
              Text('Remove Photo', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final themeMode = ref.watch(themeModeProvider);

    final currentUser = authState.user;
    final fullName = currentUser?.fullName ?? 'Family Member';
    final username = currentUser?.username ?? 'user';
    final bio = currentUser?.bio;
    final photoUrl = currentUser?.photoUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: _showEditProfileSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          children: [
            // Profile Avatar with quick Camera/Device popup menu bar trigger
            Center(
              child: PopupMenuButton<PhotoSourceAction>(
                tooltip: 'Change Photo (Camera or Device)',
                enabled: !_isUpdatingPhoto,
                onSelected: _onPhotoActionSelected,
                itemBuilder: (ctx) => _buildPhotoMenuItems(
                  hasExistingPhoto: photoUrl != null && photoUrl.isNotEmpty,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.softRose,
                      backgroundImage: appImageProvider(photoUrl),
                      child: _isUpdatingPhoto
                          ? const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : (photoUrl == null || photoUrl.isEmpty)
                              ? Text(
                                  fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
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
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              fullName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '@$username',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (bio != null && bio.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.blush.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _showEditProfileSheet,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit profile'),
            ),
            const SizedBox(height: 28),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          themeMode == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: AppColors.primaryRose,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Appearance',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Light, dark, or match your device.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.light,
                          label: Text('Light'),
                          icon: Icon(Icons.light_mode_outlined, size: 18),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.dark,
                          label: Text('Dark'),
                          icon: Icon(Icons.dark_mode_outlined, size: 18),
                        ),
                        ButtonSegment<ThemeMode>(
                          value: ThemeMode.system,
                          label: Text('System'),
                          icon: Icon(Icons.brightness_auto_outlined, size: 18),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (Set<ThemeMode> newSelection) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setThemeMode(newSelection.first);
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Log out'),
                    content: const Text(
                      'Are you sure you want to log out of Family?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(authControllerProvider.notifier).logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Log out'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
              label: const Text(
                'Log out',
                style: TextStyle(
                  color: AppColors.danger,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileBottomSheet extends ConsumerStatefulWidget {
  const _EditProfileBottomSheet();

  @override
  ConsumerState<_EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState
    extends ConsumerState<_EditProfileBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  String? _newPhotoUrl;
  bool _isUploadingPhoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _newPhotoUrl = user?.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _onBottomSheetPhotoActionSelected(PhotoSourceAction action) async {
    if (_isUploadingPhoto) return;

    if (action == PhotoSourceAction.remove) {
      setState(() => _newPhotoUrl = '');
      try {
        await ref.read(authControllerProvider.notifier).updateProfile(
              photoUrl: '',
            );
      } catch (_) {}
      return;
    }

    final source = action == PhotoSourceAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    await _pickAndUploadPhoto(source);
  }

  Future<void> _pickAndUploadPhoto(ImageSource source) async {
    final mediaService = ref.read(mediaServiceProvider);
    final user = ref.read(authControllerProvider).user;
    final userId = user?.id ?? 'user_${DateTime.now().millisecondsSinceEpoch}';

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

      // Immediately save to profile so photo is not lost if user closes sheet
      await ref.read(authControllerProvider.notifier).updateProfile(
            photoUrl: downloadUrl,
          );

      if (mounted) {
        setState(() {
          _newPhotoUrl = downloadUrl;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated!'),
            backgroundColor: AppColors.primaryRose,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        final errorMsg = e.toString().contains('denied')
            ? 'Permission denied. Please grant camera and photo permissions in device settings.'
            : 'Failed to upload image: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
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
            bio: _bioController.text.trim(),
            photoUrl: _newPhotoUrl,
          );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.primaryRose,
          ),
        );
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
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Profile photo editor with PopupMenuButton
            Center(
              child: PopupMenuButton<PhotoSourceAction>(
                tooltip: 'Change Photo (Camera or Device)',
                enabled: !_isUploadingPhoto,
                onSelected: _onBottomSheetPhotoActionSelected,
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
                  if (_newPhotoUrl != null && _newPhotoUrl!.isNotEmpty)
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
                      radius: 46,
                      backgroundColor: AppColors.softRose,
                      backgroundImage: appImageProvider(_newPhotoUrl),
                      child: _isUploadingPhoto
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : (_newPhotoUrl == null || _newPhotoUrl!.isEmpty)
                              ? const Icon(Icons.person, size: 46, color: Colors.white)
                              : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryRose,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap photo to change',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.55),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'e.g. Mom of 2 · Coffee lover',
                prefixIcon: Icon(Icons.info_outline_rounded),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_isSaving || _isUploadingPhoto) ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
