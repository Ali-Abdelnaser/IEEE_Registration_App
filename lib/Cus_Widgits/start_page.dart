import 'package:flutter/material.dart';
import 'package:registration_qr/Screens/main_shell.dart';
import 'package:registration_qr/Server/navigator.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // الخلفية
          Image.asset('assets/img/page2.jpg', fit: BoxFit.cover),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.22),

              // اللوجو
              ClipOval(
                child: Image.asset(
                  "assets/img/IEEE_White.png",
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  fit: BoxFit.cover,
                ),
              ),

              const Spacer(), // يزق الكلام والزر لتحت

              // الكلام
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                child: Column(
                  children: [
                    Text(
                      'Get Started',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'poppins',
                        color: Colors.white,
                        fontSize: size.width * 0.09,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Welcome To IEEE MET SB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: size.width * 0.04,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * 0.06),

              // الزر
              GestureDetector(
                onTap: () {
                  AppNavigator.fade(context, MainShell());
                },
                child: Container(
                  width: size.width * 0.15,
                  height: size.width * 0.15,
                  margin: EdgeInsets.only(bottom: size.height * 0.04),
                  decoration: BoxDecoration(
                    color: const Color(0xFF03A9F4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(181, 0, 140, 255).withOpacity(0.7),
                        spreadRadius: 8,
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
