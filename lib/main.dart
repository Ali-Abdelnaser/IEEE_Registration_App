import 'package:flutter/material.dart';
import 'package:registration_qr/Screens/dashboard_screen.dart';
import 'package:registration_qr/Screens/scanned_participants_screen.dart';
import 'package:registration_qr/Screens/q_r_view_screen.dart';
import 'package:registration_qr/Screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Registration QR',
      color: Colors.white,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: "/",
      routes: {
        '/': (context) => SplashScreen(nextRoute: '/home'),
        "/home": (context) => const HomePage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _startScan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRViewScreen()),
    ).then((_) {
      setState(
        () {},
      ); // علشان لما يرجع من الاسكان يعمل refresh لو في حاجه اتغيرت
    });
  }

  void _goToScannedPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannedParticipantsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double logoSize = screenWidth < 400 ? 180 : 200;
    double iconSize = screenWidth < 400 ? 180 : 200;
    double buttonFontSize = screenWidth < 400 ? 14 : 16;
    double scanFontSize = screenWidth < 400 ? 18 : 20;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 100,
        title: const Text(
          'Registration',
          style: TextStyle(
            letterSpacing: 2.0,
            fontWeight: FontWeight.w900,
            color: Color(0xff016da6),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Image.asset(
                "assets/img/logo.png",
                width: logoSize,
                height: logoSize,
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: IconButton(
                iconSize: iconSize,
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xff016da6),
                ),
                onPressed: () => _startScan(context),
              ),
            ),
            Text(
              "Tap To Scan",
              style: TextStyle(
                fontSize: scanFontSize,
                color: const Color(0xff016da6),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.pie_chart_rounded),
              label: Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _goToScannedPage,
              icon: const Icon(Icons.list_alt),
              label: Text(
                'Participants Scanned',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff016da6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
