import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../login.dart';

void main() {
  runApp(const ScreenOne());
}

class ScreenOne extends StatelessWidget {
  const ScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.sourceSans3TextTheme()),
      home: const ScreenOneContent(),
    );
  }
}

class ScreenOneContent extends StatelessWidget {
  const ScreenOneContent({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // gets the screen height so spacing can scale on different devices

    final double responsiveSpace = (height * 0.1).clamp(60.0, 100.0).toDouble();
    // replaces fixed 80px with ~10% of screen height (keeps it between 60–100)

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('lib/images/Umuhinzi.png', fit: BoxFit.cover),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 100),

                  Text(
                    "Grow Smarter With",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),

                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w800,
                        fontSize: 36,
                        color: Colors.white,
                        height: 1.1,
                      ),
                      children: const [
                        TextSpan(text: "Our "),
                        TextSpan(
                          text: "UMUHINZI+",
                          style: TextStyle(color: Color(0xFFFFF000)),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: responsiveSpace),

                  // responsive version of SizedBox(height: 80)
                  Image.asset('lib/images/logo1.png'),

                  SizedBox(height: responsiveSpace),

                  // Matching the space between elements
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3FAE4A),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Placeholder(),
                            ),
                          );
                        },
                        child: const Text(
                          "Get started",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
