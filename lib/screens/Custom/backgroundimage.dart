import 'package:flutter/material.dart';

void main() {
  runApp(const CustomBgImg());
}

class CustomBgImg extends StatelessWidget {
  const CustomBgImg({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Image.asset('lib/images/Umuhinzi.png', fit: BoxFit.cover),
    );
  }
}