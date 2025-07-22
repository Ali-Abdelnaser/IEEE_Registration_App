import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

Future<void> exportParticipantsAsCSV(
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

  List<List<String>> rows = [
    ['ID', 'Name', 'Email', 'Team', 'Attendance'],
  ];

  for (var p in participants) {
    rows.add([
      p['id'] ?? '',
      p['name'] ?? '',
      p['email'] ?? '',
      p['team'] ?? '',
      (p['attendance'] == true) ? '✔' : '✖',
    ]);
  }

  String csvData = const ListToCsvConverter().convert(rows);
  Uint8List bytes = Uint8List.fromList(csvData.codeUnits);
  final String timestamp = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final String fileName = 'participants_$timestamp';

  await FileSaver.instance.saveFile(
    name: fileName,
    bytes: bytes,
    ext: 'csv',
    mimeType: MimeType.csv,
  );

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('✅ Success'),
      content: Text('CSV saved in Downloads:\n$fileName'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
