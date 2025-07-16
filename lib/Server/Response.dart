import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleSheetService {
  static const String sheetUrl =
      'https://script.google.com/macros/s/AKfycbyuz2RXd5s7uRUWPtfKmp1ZclCWnnHYAa3TVWJgup-SvQVNCZUGLkAlyfheNy20grImbw/exec';

  /// ✅ Fetch scanned participants from Google Sheet (Live Only)
  static Future<List<Map<String, dynamic>>> fetchParticipants() async {
    try {
      final response = await http.get(Uri.parse(sheetUrl));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        final List<Map<String, dynamic>> participants = data
            .cast<Map<String, dynamic>>();
        return participants;
      } else {
        throw Exception('Failed to load participants');
      }
    } catch (e) {
      throw Exception("No internet connection, and no cached data anymore.");
    }
  }

  static Future<List<Map<String, dynamic>>> fetchConfirmedParticipants() async {
    final response = await http.get(Uri.parse(sheetUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final participants = data.cast<Map<String, dynamic>>();

      // هنا الفلتر: رجع بس اللي قدامهم Attendance = ✔
      final confirmedParticipants = participants.where((participant) {
        return participant['attendance'] == '✔';
      }).toList();

      return confirmedParticipants;
    } else {
      throw Exception('Failed to load participants');
    }
  }

  static Future<Map<String, dynamic>?> checkIfAlreadyScanned(String id) async {
    try {
      final response = await http.get(Uri.parse(sheetUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final participants = data.cast<Map<String, dynamic>>();

        final found = participants.firstWhere(
          (participant) =>
              participant['id']?.toLowerCase().trim() ==
              id.toLowerCase().trim(),
          orElse: () => {},
        );

        if (found.isNotEmpty && found['attendance'] == '✔') {
          return found; // موجود ومعاه علامة صح
        } else if (found.isNotEmpty) {
          return {
            'id': found['id'],
            'alreadyScanned': false,
          }; // موجود بس لسه مش متعلم عليه ✔
        } else {
          return null; // مش موجود اصلاً
        }
      } else {
        throw Exception('Failed to load participants');
      }
    } catch (e) {
      throw Exception("Error checking scanned participants");
    }
  }

  static Future<List<String>> fetchConfirmedIDs() async {
    try {
      final response = await http.get(Uri.parse(sheetUrl));
      print(
        '✅ Response status: ${response.statusCode}',
      ); // طباعة حالة الاستجابة

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final participants = data.cast<Map<String, dynamic>>();

        final confirmedIDs = participants
            .where((participant) => participant['attendance'] == '✔')
            .map<String>(
              (participant) =>
                  participant['id']?.toString().toUpperCase().trim() ?? '',
            )
            .where((id) => id.isNotEmpty)
            .toList();

        print('✅ Fetched confirmed IDs: $confirmedIDs');
        return confirmedIDs;
      } else {
        throw Exception('Failed to load participants');
      }
    } catch (e) {
      print('❌ Error fetching confirmed IDs: $e');
      throw Exception("No internet connection, and no cached data anymore.");
    }
  }

  static Future<bool> removeParticipant(String participantId) async {
    try {
      final response = await http.post(
        Uri.parse(sheetUrl), // ضع هنا الـ URL الخاص بـ Google Apps Script
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': participantId,
          'action': 'delete', // إضافة action هنا للإشارة إلى الحذف
        }),
      );

      if (response.statusCode == 200) {
        return true; // تم الحذف بنجاح
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        throw Exception('Failed to remove participant');
      }
    } catch (e) {
      print('❌ Error removing participant: $e');
      return false;
    }
  }

  /// ✅ Confirm attendance in Sheet
  static Future<bool> confirmAttendance(
    Map<String, dynamic> participant,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(sheetUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(participant..putIfAbsent('confirmed', () => '✔')),
      );

      if (response.statusCode == 200 || response.statusCode == 302) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
