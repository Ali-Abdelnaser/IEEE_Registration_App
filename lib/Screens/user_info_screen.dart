import 'package:flutter/material.dart';
import 'package:registration_qr/Data/participant.dart';
import 'package:registration_qr/Data/local_storage.dart';
import 'package:registration_qr/Server/Response.dart';

class UserInfoScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onConfirm;
  final Function(Map<String, dynamic>) onDelete;

  const UserInfoScreen({
    super.key,
    required this.data,
    required this.onConfirm,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Participant Details'),
        centerTitle: true,
        backgroundColor: const Color(0xff016da6),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xff016da6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("ID:", data['id']),
                      const SizedBox(height: 12),
                      _infoRow("Name:", data['name']),
                      const SizedBox(height: 12),
                      _infoRow("Email:", data['email']),
                      const SizedBox(height: 12),
                      _infoRow("Team:", data['team']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      

                      final success =
                          await ParticipantsService.confirmAttendance(
                            data['id'],
                          );
                      if (success) {
                        //هنا الدلة دي بتاخد  نسخه من البيانات بتاعت الشخص الي اتعمله كونفرم 
                        await LocalStorage.addParticipant(
                        Participant(
                          id: data['id'],
                          name: data['name'],
                          email: data['email'],
                          team: data['team'],
                        ),
                      );
                        data['attendance'] = true; // حط ترو عادي مش ✔
                        onConfirm(data);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Center(
                              child: Text('✔️ Attendance Confirmed'),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Center(
                              child: Text('❌ Failed to confirm attendance'),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text("Confirm"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      onDelete(data);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(
                            child: Text('Attendance Cancelled ❌ '),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text("Cancel"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title ",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              value ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
