import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  final bool hasOnboarded;

  const AuthSuccess({required this.user, required this.hasOnboarded});

  @override
  List<Object?> get props => [user.uid, hasOnboarded];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordResetLoading extends AuthState {}

class PasswordResetSent extends AuthState {}

/// Emitted after email/password signup or login when the email is not yet verified.
class AuthEmailUnverified extends AuthState {
  final String email;

  const AuthEmailUnverified(this.email);

  @override
  List<Object?> get props => [email];
}

/// Emitted briefly after a verification email is (re)sent successfully.
class AuthVerificationSent extends AuthState {}
