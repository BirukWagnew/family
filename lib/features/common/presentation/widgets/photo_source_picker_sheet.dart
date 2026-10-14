import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

enum PhotoSourceAction {
  camera,
  gallery,
  remove,
}

/// Displays a bottom sheet allowing the user to select Camera, Device Gallery, or Remove Photo.
Future<PhotoSourceAction?> showPhotoSourcePickerSheet({
  required BuildContext context,
  bool hasExistingPhoto = false,
  String title = 'Profile Photo',
  String subtitle = 'Take a new photo or select one from your device',
}) {
  return showModalBottomSheet<PhotoSourceAction>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final isDark = theme.brightness == Brightness.dark;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warmBrown,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Camera option
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.softRose.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryRose,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Take Photo (Camera)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Use camera to take a photo'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => Navigator.pop(ctx, PhotoSourceAction.camera),
              ),
              const SizedBox(height: 6),

              // Device Gallery option
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.softRose.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryRose,
                    size: 24,
                  ),
                ),
                title: const Text(
                  'Choose from Device',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Select a photo from device storage or gallery'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => Navigator.pop(ctx, PhotoSourceAction.gallery),
              ),

              if (hasExistingPhoto) ...[
                const SizedBox(height: 6),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                  subtitle: const Text('Delete current profile picture'),
                  onTap: () => Navigator.pop(ctx, PhotoSourceAction.remove),
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}
