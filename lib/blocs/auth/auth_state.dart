part of 'auth_cubit.dart';

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent() : super(status: AuthStatus.unauthenticated);
}

class AuthPasswordChanged extends AuthState {
  const AuthPasswordChanged() : super(status: AuthStatus.authenticated);
}

class AuthEmailVerificationSent extends AuthState {
  const AuthEmailVerificationSent() : super(status: AuthStatus.authenticated);
} 