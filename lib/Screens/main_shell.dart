import 'package:flutter/material.dart';
import 'package:registration_qr/Screens/dashboard_screen.dart';
import 'package:registration_qr/Screens/home_page.dart';
import 'package:registration_qr/Screens/scanned_participants_screen.dart';
import 'package:registration_qr/Screens/q_r_view_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 1; // ← يبدأ على الهوم الحقيقي

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return const ScannedParticipantsScreen();
      case 2:
        return const DashboardScreen();
      default:
        return const HomePage(); // ← الهوم الحقيقي
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      extendBodyBehindAppBar: true,
      // ✅ AppBar يظهر بس في الهوم
      appBar: _selectedIndex == 1
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 80,
              title: const Text(
                'Registration',
                style: TextStyle(
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              centerTitle: true,
            )
          : null,

      body: _getSelectedPage(),

      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRViewScreen()),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF03A9F4),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(181, 0, 140, 255).withOpacity(0.7),
                spreadRadius: 10,
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomAppBar(
          
          color: Colors.black87,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          child: SizedBox(
            
            height: 77,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              
              children: [
                GestureDetector(
                  onTap: () => _onItemTapped(0),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people,
                          color: _selectedIndex == 0 ? Colors.blue : Colors.white70,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Participants',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedIndex == 0 ? Colors.blue : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 40),
                GestureDetector(
                  onTap: () => _onItemTapped(2),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.dashboard,
                          color: _selectedIndex == 2 ? Colors.blue : Colors.white70,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dashboard',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedIndex == 2 ? Colors.blue : Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
