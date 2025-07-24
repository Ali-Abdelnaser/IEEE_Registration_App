import 'dart:async';
import 'package:flutter/material.dart';
import 'package:registration_qr/Cus_Widgits/start_page.dart';
import 'package:registration_qr/Server/navigator.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;

  const SplashScreen({Key? key, this.duration = const Duration(seconds: 2)})
    : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      AppNavigator.slideLikePageView(context, OnBoardingScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                "assets/img/IEEE_White.png",
                width: 300,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            // Text("Registration",style: TextStyle(
            //   fontSize: 20,
            //   color: const Color.fromARGB(255, 0, 0, 0),
            //   fontWeight: FontWeight.w900,
            // ),)
          ],
        ),
      ),
    );
  }
}
