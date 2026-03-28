import 'package:flutter_test/flutter_test.dart';

// Tests the email validation regex used in AuthService, LoginScreen,
// SignupScreen, and ForgotPasswordScreen — without needing Firebase.
void main() {
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(email.trim());
  }

  group('Email validation regex', () {
    test('accepts standard valid email', () {
      expect(isValidEmail('user@example.com'), true);
    });

    test('accepts email with subdomain', () {
      expect(isValidEmail('name@mail.domain.co.rw'), true);
    });

    test('accepts email with dots and numbers', () {
      expect(isValidEmail('user.name123@gmail.com'), true);
    });

    test('rejects empty string', () {
      expect(isValidEmail(''), false);
    });

    test('rejects missing @', () {
      expect(isValidEmail('notanemail'), false);
    });

    test('rejects missing domain', () {
      expect(isValidEmail('user@'), false);
    });

    test('rejects missing username', () {
      expect(isValidEmail('@domain.com'), false);
    });

    test('trims whitespace before validating', () {
      expect(isValidEmail('  user@example.com  '), true);
    });

    test('rejects email with space inside', () {
      expect(isValidEmail('user @example.com'), false);
    });
  });
}
