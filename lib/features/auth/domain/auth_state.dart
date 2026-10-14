import 'user.dart';

abstract class AuthState {
  const AuthState();
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.unauthenticated() = AuthUnauthenticated;
  const factory AuthState.authenticating() = AuthAuthenticating;
  const factory AuthState.authenticated({required User user}) = AuthAuthenticated;
  const factory AuthState.error(String message) = AuthError;

  bool get isAuthenticating => this is AuthAuthenticating;
  bool get hasError => this is AuthError;
  String? get errorMessage => this is AuthError ? (this as AuthError).message : null;
  User? get user => this is AuthAuthenticated ? (this as AuthAuthenticated).user : null;
}

class AuthInitial extends AuthState { const AuthInitial(); }
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); }
class AuthAuthenticating extends AuthState { const AuthAuthenticating(); }
class AuthAuthenticated extends AuthState {
  @override
  final User user;
  const AuthAuthenticated({required this.user});
}
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
