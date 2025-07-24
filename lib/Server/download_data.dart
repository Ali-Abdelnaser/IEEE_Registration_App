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
      const SnackBar(content: Text('❌ Storage permission denied')),
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
    const SnackBar(content: Text('❌ Failed to generate Excel file')),
  );
  return;
}
final Uint8List bytes = Uint8List.fromList(fileBytes);

  if (bytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Failed to generate Excel file')),
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
      title: const Text('✅ Success'),
      content: Text('Excel saved in Downloads:\n$fileName.xlsx'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
