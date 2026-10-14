import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/auth_state.dart';
import '../../data/auth_repository.dart';
import '../../domain/user.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    // Listen to Firebase Auth state changes
    _authRepository.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        state = const AuthState.unauthenticated();
      } else {
        // Fetch full profile from Firestore
        final user = await _authRepository.getCurrentUser() ??
            User(
              id: firebaseUser.uid,
              username: firebaseUser.email?.split('@')[0] ?? 'user',
              fullName: firebaseUser.displayName ?? 'Family Member',
              photoUrl: firebaseUser.photoURL,
              onboardingCompleted: true,
            );
        state = AuthState.authenticated(user: user);
      }
    });

    return const AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.authenticating();
    try {
      final user = await _authRepository.login(email, password);
      state = AuthState.authenticated(user: user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    state = const AuthState.authenticating();
    try {
      final user = await _authRepository.register(email, password, fullName);
      state = AuthState.authenticated(user: user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    try {
      final updatedUser = await _authRepository.updateProfile(
        fullName: fullName,
        username: username,
        bio: bio,
        photoUrl: photoUrl,
      );
      state = AuthState.authenticated(user: updatedUser);
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthState.unauthenticated();
  }
}
