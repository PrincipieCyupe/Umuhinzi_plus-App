import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umuhinzi_plus/features/home/screens/forgot_password.dart';
import '../../../test_helpers/firebase_mock.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseMocks();
  });

  Widget buildScreen() {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ForgotPasswordScreen(),
    );
  }

  group('ForgotPasswordScreen', () {
    testWidgets('renders key UI elements', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.text('UMUHINZI+'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);
    });

    testWidgets('shows error when email is empty', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows error when email is invalid', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      await tester.enterText(find.byType(TextFormField), 'bademail');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('Back to Login pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordScreen(),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Send Reset Link'), findsOneWidget);

      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();

      expect(find.text('Open'), findsOneWidget);
    });
  });
}
