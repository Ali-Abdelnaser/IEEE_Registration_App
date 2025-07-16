import 'package:flutter/material.dart';
import 'package:registration_qr/Screens/dashboard_screen.dart';
import 'package:registration_qr/Screens/scanned_participants_screen.dart';
import 'package:registration_qr/Screens/q_r_view_screen.dart';
import 'package:registration_qr/Screens/splash_screen.dart';
import 'package:registration_qr/Screens/user_info_screen.dart';
import 'package:registration_qr/Server/Response.dart';

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
  void _startScan(BuildContext context) async {
    print('✅ Start scan called');

    // افتح شاشة المسح واستلم النتيجة
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const QRViewScreen()),
    );

    // تحقق من النتيجة
    if (result == null || result is! Map<String, dynamic>) {
      print('❌ Invalid result received');
      return;
    }

    // تجهيز الـ ID
    final String scannedId =
        (result['id']?.toString().toUpperCase().trim()) ?? "";
    print('✅ Scanned ID: $scannedId');

    // جلب الـ IDs المؤكدين
    print('✅ Fetching confirmed IDs...');
    final List<String> confirmedIDs =
        await GoogleSheetService.fetchConfirmedIDs();
    print('✅ Confirmed IDs: $confirmedIDs');

    // تحقق إذا كان الـ ID موجود في الـ confirmedIDs
    if (confirmedIDs.contains(scannedId)) {
      print('✅ This ID has already been registered');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Already Registered ⚠️'),
          content: const Text(
            'This participant has already been registered before.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // إذا لم يكن متسجل، افتح الـ UserInfoScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserInfoScreen(
          data: result,
          onConfirm: (participant) {
            setState(() {});
            Navigator.pop(context);
          },
          onDelete: (participant) {
            setState(() {});
          },
        ),
      ),
    );
  }

  void _goToScannedPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScannedParticipantsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
