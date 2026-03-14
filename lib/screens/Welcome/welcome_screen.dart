import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Custom/backgroundimage.dart';

void main() {
  runApp(const WelcomeScreen());
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreenContent(),
    );
  }
}

class WelcomeScreenContent extends StatefulWidget {
  const WelcomeScreenContent({super.key});

  @override
  State<WelcomeScreenContent> createState() => _WelcomeScreenContentState();
}

class _WelcomeScreenContentState extends State<WelcomeScreenContent> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final double responsiveSpace = (screenHeight * 0.1)
        .clamp(60.0, 100.0)
        .toDouble();

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomBgImg(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.07),
                    Image.asset('lib/images/logo.png'),
                    SizedBox(height: responsiveSpace),

                    const Text(
                      "Welcome To\nUMUHINZI+",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        fontSize: 40,
                        color: Colors.yellow,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Choose Language",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "≡",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            "English",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Kinyarwanda",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              // decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.08),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {},
                        child: const Text(
                          "Click to continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}