import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final String nextRoute;
  final Duration duration;

  const SplashScreen({
    Key? key,
    required this.nextRoute,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(widget.duration, () {
      Navigator.of(context).pushReplacementNamed(widget.nextRoute);
    });
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
              
              child: Image.asset(
                "assets/img/logo.png",
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
