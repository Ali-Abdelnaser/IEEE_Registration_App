import 'dart:ui';

import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ الخلفية
        Image.asset(
          'assets/img/home.jpg', // غير المسار حسب صورتك
          fit: BoxFit.cover,
        ),

        // ✅ البلور
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), // النعومة
          child: Container(
            color: Colors.black54.withOpacity(0.2), // لون شفاف فوق البلور
          ),
        ),

        // ✅ النص
        Center(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  // ignore: prefer_const_constructors
                  'Welcome Registration Team',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 12),
                const Text(
                  // ignore: prefer_const_☻constructors
                  'Let\'s scan, verify & organize participants ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromARGB(200, 255, 255, 255),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
