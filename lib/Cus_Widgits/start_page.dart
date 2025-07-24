import 'package:flutter/material.dart';
import 'package:registration_qr/Screens/home_page.dart';
import 'package:registration_qr/Screens/main_shell.dart';
import 'package:registration_qr/Server/navigator.dart';
import 'package:registration_qr/main.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/img/page2.jpg', fit: BoxFit.cover),
          Column(
            children: [
              SizedBox(height: 150),
              ClipOval(
                child: Image.asset(
                  "assets/img/IEEE_White.png",
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: const [
                    SizedBox(height: 100),
                    Text(
                      'Get  Started',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Welcome To IEEE MET SB',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  AppNavigator.slideLikePageView(context, MainShell());
                },
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: BoxDecoration(
                    color: Color(0xFF03A9F4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(181, 0, 140, 255).withOpacity(0.7),
                        spreadRadius: 10,
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
