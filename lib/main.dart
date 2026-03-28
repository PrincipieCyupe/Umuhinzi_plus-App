import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, User;
import 'package:http/http.dart' as http;

import 'firebase_options.dart';
import 'features/home/screens/Welcome/first_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/market/data/datasources/market_csv_data_source.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with options from firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pre-load market data in background
  _preloadMarketData();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      theme: ThemeData(textTheme: GoogleFonts.sourceSans3TextTheme()),
    ),
  );
}

/// Pre-load market data in background when app starts
void _preloadMarketData() async {
  try {
    final csvDataSource = MarketCsvDataSource(client: http.Client());
    await csvDataSource.fetchAndSync();
    debugPrint('Market data pre-loaded successfully');
  } catch (e) {
    debugPrint('Failed to pre-load market data: $e');
  }
}

/// AuthWrapper - Handles auth state and redirects to appropriate screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0C4D32),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF3FAE4A)),
            ),
          );
        }

        // If user is logged in, go to home, otherwise go to first screen
        if (snapshot.hasData && snapshot.data != null) {
          return const Home();
        }

        return const FirstScreen();
      },
    );
  }
}
