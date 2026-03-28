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
        final hasOnboarded =
            prefs.getString('selected_crop') != null &&
            prefs.getString('selected_district') != null;
        emit(AuthSuccess(user: user, hasOnboarded: hasOnboarded));
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
}
