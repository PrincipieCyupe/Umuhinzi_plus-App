import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Custom/backgroundimage.dart';

void main() {
  runApp(const ScreenThree());
}

class ScreenThree extends StatelessWidget {
  const ScreenThree({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.sourceSans3TextTheme()),
      home: const ThirdScreen(),
    );
  }
}

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CustomBgImg(),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.1),
                    Image.asset('lib/images/logo.png'),
                    SizedBox(height: screenHeight * 0.07),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: "Access easy-to-follow "),
                          TextSpan(
                            text: "farming tips",
                            style: TextStyle(
                              color: Color(0xFFFFF000),
                            ), // Yellow
                          ),
                          TextSpan(text: " and "),
                          TextSpan(
                            text: "best practices",
                            style: TextStyle(
                              color: Color(0xFFFFF000),
                            ), // Yellow
                          ),
                          TextSpan(
                            text: " that supports healthy crops, reduce losses, and improve overall harvest results using, real-world advices. ",
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.1),

                    Row(
                      children: [
                        // Next Button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Placeholder(),
                                ),
                              );
                            },
                            child: const Text(
                              "Next",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 20,
                        ), // Space between the two buttons
                        // Skip Button
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFF000),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {},
                            child: const Text(
                              "Skip  >>",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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
