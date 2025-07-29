import 'package:flutter/material.dart';
import 'package:registration_qr/Screens/q_r_view_screen.dart';
import 'package:registration_qr/Server/firestore_service.dart';
import 'package:registration_qr/Server/navigator.dart';

class UserInfoScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onConfirm;

  const UserInfoScreen({
    super.key,
    required this.data,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // الخلفية (الصورة)
          SizedBox(
            height: height * 0.3,
            width: width,
            child: Image.asset('assets/img/IEEE_Blue.png', fit: BoxFit.cover),
          ),

          // الجزء الأبيض فوق الصورة
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: height * 0.7,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _infoRow("ID", data['id'], Icons.assignment_ind),
                        _infoRow("Name", data['name'], Icons.person),
                        _infoRow("Email", data['email'], Icons.email),
                        _infoRow("Team", data['team'], Icons.groups),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            final success =
                                await FirestoreService.confirmAttendance(
                                  data['id'],
                                );
                            if (success) {
                              data['attendance'] = true;
                              onConfirm(data);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.white,
                                  elevation: 4,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                  content: Row(
                                    children: const [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Attendance confirmed successfully!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                              Navigator.pop(context, true);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.white,
                                  elevation: 4,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.all(16),
                                  duration: const Duration(seconds: 2),
                                  content: Row(
                                    children: const [
                                      Icon(
                                        Icons.error,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Failed to confirm attendance!',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff016da6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),

                  //Icons.assignment_ind ,Icons.person , Icons.email ,Icons.groups
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffe0e0e0)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 5,
          ),
          leading: Icon(icon, color: Color(0xff016da6), size: 28),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            value ?? '',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}
