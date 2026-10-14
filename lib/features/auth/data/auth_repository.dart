import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../domain/user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebase.FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

class AuthRepository {
  final firebase.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

  Stream<firebase.User?> get authStateChanges => _auth.authStateChanges();

  firebase.User? get currentFirebaseUser => _auth.currentUser;

  Future<User?> getCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(fbUser.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return User(
          id: fbUser.uid,
          username: data['username'] as String? ?? fbUser.email?.split('@')[0] ?? 'user',
          fullName: data['fullName'] as String? ?? fbUser.displayName ?? 'Family Member',
          photoUrl: data['photoUrl'] as String? ?? fbUser.photoURL,
          bio: data['bio'] as String?,
          onboardingCompleted: data['onboardingCompleted'] as bool? ?? true,
        );
      }
    } catch (_) {}

    return User(
      id: fbUser.uid,
      username: fbUser.email?.split('@')[0] ?? 'user',
      fullName: fbUser.displayName ?? 'Family Member',
      photoUrl: fbUser.photoURL,
      onboardingCompleted: true,
    );
  }

  Future<User> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final fbUser = credential.user;
      if (fbUser != null) {
        _firestore.collection('users').doc(fbUser.uid).set({
          'email': fbUser.email ?? email,
          'emailLower': (fbUser.email ?? email).trim().toLowerCase(),
        }, SetOptions(merge: true)).ignore();
      }

      final user = await getCurrentUser();
      if (user != null) return user;

      return User(
        id: credential.user!.uid,
        username: credential.user!.email!.split('@')[0],
        fullName: credential.user!.displayName ?? 'Family Member',
        photoUrl: credential.user!.photoURL,
        onboardingCompleted: true,
      );
    } on firebase.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  Future<User> register(String email, String password, String fullName) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(fullName);

      final newUser = User(
        id: credential.user!.uid,
        username: email.split('@')[0],
        fullName: fullName,
        onboardingCompleted: true,
      );

      // Save user record to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'username': newUser.username,
        'fullName': fullName,
        'email': email,
        'emailLower': email.trim().toLowerCase(),
        'onboardingCompleted': true,
        'createdAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      return newUser;
    } on firebase.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: ${e.toString()}';
    }
  }

  Future<User> updateProfile({
    String? fullName,
    String? username,
    String? bio,
    String? photoUrl,
  }) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) throw 'User not authenticated';

    try {
      final updates = <String, dynamic>{};
      if (fullName != null && fullName.isNotEmpty) {
        updates['fullName'] = fullName;
        await fbUser.updateDisplayName(fullName);
      }
      if (username != null && username.trim().isNotEmpty) {
        updates['username'] = username.trim().replaceAll('@', '');
      }
      if (bio != null) {
        updates['bio'] = bio;
      }
      if (photoUrl != null) {
        final cleanPhotoUrl = photoUrl.trim();
        updates['photoUrl'] = cleanPhotoUrl.isEmpty ? null : cleanPhotoUrl;
        if (cleanPhotoUrl.isEmpty) {
          try {
            await fbUser.updatePhotoURL(null);
          } catch (_) {}
        } else if (cleanPhotoUrl.startsWith('http://') || cleanPhotoUrl.startsWith('https://')) {
          try {
            await fbUser.updatePhotoURL(cleanPhotoUrl);
          } catch (_) {
            // Firebase Auth updatePhotoURL may reject certain URL formats or lengths,
            // but the URL is safely stored in Firestore for the profile.
          }
        }
      }

      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(fbUser.uid)
            .set(updates, SetOptions(merge: true));
      }

      final currentUser = await getCurrentUser();
      final resolvedUsername = (username != null && username.trim().isNotEmpty)
          ? username.trim().replaceAll('@', '')
          : (currentUser?.username ?? fbUser.email?.split('@')[0] ?? 'user');
      return User(
        id: fbUser.uid,
        username: resolvedUsername,
        fullName: (fullName != null && fullName.isNotEmpty)
            ? fullName
            : (currentUser?.fullName ?? fbUser.displayName ?? 'Family Member'),
        photoUrl: photoUrl != null
            ? (photoUrl.isEmpty ? null : photoUrl)
            : (currentUser?.photoUrl ?? fbUser.photoURL),
        bio: bio ?? currentUser?.bio,
        onboardingCompleted: true,
      );
    } catch (e) {
      throw 'Failed to update profile: $e';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _handleAuthException(firebase.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'invalid-credential':
        return 'No account found with this email or password. Please check your credentials or click Sign Up below.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'The email address is formatted incorrectly.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Try logging in instead.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'multi-factor-auth-required':
      case 'mfa-required':
      case 'second-factor-required':
        return 'Two-Step Verification (2SV) is required for this account. Please complete 2SV verification or disable MFA in Firebase Console for testing.';
      case 'operation-not-allowed':
        return 'Email/Password login is not enabled in Firebase Console. Please enable it in Firebase Console -> Authentication -> Sign-in method.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }
}
