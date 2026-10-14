import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_wrapper.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/profile_setup_screen.dart';
import '../../features/profile/presentation/screens/my_profile_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/family_hub/presentation/screens/family_hub_screen.dart';
import '../../features/messages/presentation/screens/conversations_screen.dart';
import '../../features/posts/presentation/screens/composer_screen.dart';
import '../../features/groups/presentation/screens/groups_screen.dart';
import '../../features/family/presentation/screens/family_screen.dart';
import 'scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/auth',
    redirect: (context, state) {
      final isAuthRoute = state.matchedLocation == '/auth';

      if (authState.isAuthenticating) return null;

      if (authState is AuthAuthenticated) {
        if (isAuthRoute) {
          return (authState).user.onboardingCompleted ? '/hub' : '/onboarding';
        }
        return null;
      }

      if (!isAuthRoute) return '/auth';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthWrapper(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/profile_setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: '/composer',
        builder: (context, state) => const ComposerScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/hub',
            builder: (context, state) => const FamilyHubScreen(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const ConversationsScreen(),
          ),
          GoRoute(
            path: '/family',
            builder: (context, state) => const FamilyScreen(),
          ),
          GoRoute(
            path: '/groups',
            builder: (context, state) => const GroupsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const MyProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
