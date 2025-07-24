import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:registration_qr/Screens/dashboard_screen.dart';
import 'package:registration_qr/Screens/home_page.dart';
import 'package:registration_qr/Screens/main_shell.dart';
import 'package:registration_qr/Cus_Widgits/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration QR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: SplashScreen(),
    );
  }
}


