import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umuhinzi_plus/features/home/screens/login.dart';
import '../../../test_helpers/firebase_mock.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseMocks();
  });

  Widget buildLoginScreen() {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }

  group('LoginScreen form validation', () {
    testWidgets('renders all key UI elements', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('UMUHINZI+'), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('shows error when email field is empty', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      // Scroll to and tap the login button
      await tester.ensureVisible(find.byType(ElevatedButton).first);
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error when email is invalid', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'notanemail');
      await tester.ensureVisible(find.byType(ElevatedButton).first);
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('shows error when password is empty', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.ensureVisible(find.byType(ElevatedButton).first);
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows error when password is too short', (tester) async {
      await tester.pumpWidget(buildLoginScreen());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'test@example.com');
      await tester.enterText(fields.last, '123');
      await tester.ensureVisible(find.byType(ElevatedButton).first);
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pumpAndSettle();

      expect(find.text('Min 6 characters'), findsOneWidget);
    });
  });
}
