import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> exportParticipantsAsExcel(
  BuildContext context,
  List<Map<String, dynamic>> participants,
) async {
  var status = await Permission.storage.request();
  if (!status.isGranted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        content: Row(
          children: const [
            Icon(
              Icons
                  .sd_storage, // أو ممكن Icons.folder_off لو عايز تعبر عن المجلد مرفوض
              color: Colors.redAccent,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Storage permission denied!',
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
    return;
  }

  final excel = Excel.createExcel(); // Create new Excel
  final sheet = excel['Participants'];

  // Add header row
  sheet.appendRow(['ID', 'Name', 'Email', 'Team', 'Attendance']);

  // Add participant data
  for (var p in participants) {
    sheet.appendRow([
      p['id'] ?? '',
      p['name'] ?? '',
      p['email'] ?? '',
      p['team'] ?? '',
      (p['attendance'] == true) ? '✔' : '✖',
    ]);
  }

  // Convert to bytes
  final List<int>? fileBytes = excel.encode();
  if (fileBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        content: Row(
          children: const [
            Icon(
              Icons.insert_drive_file, // أيقونة ملف
              color: Colors.redAccent,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to generate Excel file!',
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
    return;
  }
  final Uint8List bytes = Uint8List.fromList(fileBytes);

  if (bytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        elevation: 4,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        content: Row(
          children: const [
            Icon(
              Icons.insert_drive_file, // أيقونة ملف
              color: Colors.redAccent,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to generate Excel file!',
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
    return;
  }

  final String timestamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final String fileName = 'participants_$timestamp';

  // Save file
  await FileSaver.instance.saveFile(
    name: fileName,
    bytes: bytes,
    ext: 'xlsx',
    mimeType: MimeType.microsoftExcel,
  );

  // Show success dialog
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.only(top: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actionsPadding: const EdgeInsets.only(bottom: 12, right: 12),
      title: const Icon(
        Icons.check_circle_rounded,
        color: Colors.green,
        size: 60,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Excel file saved successfully!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Saved to:\nDownloads/$fileName.xlsx',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text(
            'OK',
            style: TextStyle(
              color: Color(0xff016DA6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
