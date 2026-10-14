import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.7);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.blush.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 56,
                    color: AppColors.primaryRose,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Your family’s\ndigital living room',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryRose,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'A private space for your closest people — share photos, posts, and chats without a public feed.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
              _FeatureRow(
                icon: Icons.lock_outline_rounded,
                title: 'Private by design',
                subtitle: 'No followers. No public discovery.',
              ),
              const SizedBox(height: 12),
              _FeatureRow(
                icon: Icons.groups_rounded,
                title: 'Up to 40 members',
                subtitle: 'Keep your circle close and intentional.',
              ),
              const SizedBox(height: 12),
              _FeatureRow(
                icon: Icons.photo_library_outlined,
                title: 'Share together',
                subtitle: 'Posts, photos, and family chats in one place.',
              ),
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () => context.go('/profile_setup'),
                child: const Text('Get started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.softRose.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryRose, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Text(subtitle, style: TextStyle(fontSize: 13, color: muted)),
            ],
          ),
        ),
      ],
    );
  }
}
