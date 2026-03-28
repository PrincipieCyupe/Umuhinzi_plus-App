import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../service/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> loginWithEmail(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        // Block unverified email/password users until they verify
        if (!user.emailVerified) {
          emit(AuthEmailUnverified(user.email ?? email));
          return;
        }
        final prefs = await SharedPreferences.getInstance();
        final hasOnboarded =
            prefs.getString('selected_crop') != null &&
            prefs.getString('selected_district') != null;
        emit(AuthSuccess(user: user, hasOnboarded: hasOnboarded));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final hasOnboarded =
            prefs.getString('selected_crop') != null &&
            prefs.getString('selected_district') != null;
        emit(AuthSuccess(user: user, hasOnboarded: hasOnboarded));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name);
        await prefs.setString('user_email', email);
        // Send verification email and gate the app until verified
        await _authService.sendEmailVerification();
        emit(AuthEmailUnverified(user.email ?? email));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUpWithGoogle() async {
    emit(AuthLoading());
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', user.displayName ?? 'User');
        await prefs.setString('user_email', user.email ?? '');
        final hasOnboarded =
            prefs.getString('selected_crop') != null &&
            prefs.getString('selected_district') != null;
        emit(AuthSuccess(user: user, hasOnboarded: hasOnboarded));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(PasswordResetLoading());
    try {
      await _authService.sendPasswordResetEmail(email: email);
      emit(PasswordResetSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Reloads the Firebase user and checks if email has been verified.
  /// Called when the user taps "I've Verified — Continue" on the verification screen.
  Future<void> checkVerification() async {
    emit(AuthLoading());
    try {
      final verified = await _authService.reloadAndCheckVerified();
      if (verified) {
        final user = _authService.currentUser!;
        final prefs = await SharedPreferences.getInstance();
        final hasOnboarded =
            prefs.getString('selected_crop') != null &&
            prefs.getString('selected_district') != null;
        emit(AuthSuccess(user: user, hasOnboarded: hasOnboarded));
      } else {
        emit(AuthEmailUnverified(_authService.currentUser?.email ?? ''));
        // Surface a clear message to the user via AuthError briefly
        emit(const AuthError('Email not verified yet. Check your inbox.'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Resends the verification email to the currently signed-in user.
  Future<void> resendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
      emit(AuthVerificationSent());
      // Return to waiting state so the screen stays active
      await Future.delayed(const Duration(seconds: 2));
      emit(AuthEmailUnverified(_authService.currentUser?.email ?? ''));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
