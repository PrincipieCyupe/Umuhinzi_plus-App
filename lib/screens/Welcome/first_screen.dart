import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:umuhinzi_plus/screens/Welcome/second_screen.dart';
import '../login.dart';
import '../Custom/backgroundimage.dart';

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
      home: const FirstScreen(),
    );
  }
}

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.07),

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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(vertical: 14),

                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SecondScreen(),
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
