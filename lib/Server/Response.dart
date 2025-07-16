import 'dart:convert';
import 'package:http/http.dart' as http;

class ParticipantsService {
  static const String baseUrl =
      'https://my-api-production-0231.up.railway.app/people';

  /// ✅ Fetch all participants
  /// **Usage:** This function is used to fetch the list of all participants.
  /// Used in: ScannedParticipantsScreen, QRViewScreen
  static Future<List<Map<String, dynamic>>> fetchParticipants() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return (jsonDecode(response.body) as List).cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load participants');
    }
  }

  /// ✅ Fetch participants who have confirmed attendance
  /// **Usage:** This function is used to fetch the participants who have marked their attendance as true.
  /// Used in: DashboardScreen, ScannedParticipantsScreen
  static Future<List<Map<String, dynamic>>> fetchConfirmedParticipants() async {
    final response = await http.get(Uri.parse('$baseUrl/attended'));

    if (response.statusCode == 200) {
      final List participants = jsonDecode(response.body);
      // Return only the participants with attendance = true
      final confirmed = participants
          .where((p) => p['attendance'] == true)
          .toList();

      return confirmed
          .map<Map<String, dynamic>>(
            (p) => {
              'id': p['id'], // Return participant's ID
              'name': p['name'], // Return participant's name
              'email': p['email'], // Return participant's email
              'team': p['team'], // Return participant's team
              'attendance': p['attendance'], // Return participant's attendance status
            },
          )
          .toList();
    } else {
      throw Exception('Failed to fetch confirmed participants');
    }
  }

  /// ✅ Check if a participant has already been scanned
  /// **Usage:** This function is used to check if a participant with a specific ID has already been scanned (based on attendance).
  /// Used in: QRViewScreen
  static Future<Map<String, dynamic>?> checkID(String id) async {
    final participants = await fetchParticipants(); // Fetch all participants
    final match = participants.firstWhere(
      (p) => p['id'].toString().toLowerCase().trim() == id.toLowerCase().trim(),
      orElse: () => {}, // If no match is found, return an empty map
    );

    // If a match is found, return participant details
    if (match.isNotEmpty) {
      return {
        'id': match['id'],
        'name': match['name'],
        'email': match['email'],
        'team': match['team'],
        'attendance': match['attendance'],
      };
    }

    // If no match found, return null
    return null;
  }

  /// ✅ Fetch list of IDs of confirmed participants
  /// **Usage:** This function is used to fetch the list of participant IDs who have confirmed their attendance.
  /// Used in: HomePage, QRViewScreen
  static Future<List<String>> fetchConfirmedIDs() async {
    final response = await http.get(Uri.parse('$baseUrl/attended'));
    if (response.statusCode == 200) {
      final data = (jsonDecode(response.body) as List)
          .cast<Map<String, dynamic>>();
      final confirmedIDs = data
          .map<String>(
            (participant) => participant['id'].toString().toUpperCase(),
          )
          .toList();
      return confirmedIDs;
    } else {
      throw Exception('Failed to load confirmed IDs');
    }
  }

  /// ✅ Confirm attendance for a participant
  /// **Usage:** This function is used to confirm the attendance of a participant by ID.
  /// Used in: UserInfoScreen
  static Future<bool> confirmAttendance(String id) async {
    final response = await http.post(Uri.parse('$baseUrl/$id/confirm'));
    return response.statusCode == 200;
  }

  /// ✅ Unconfirm attendance for a participant (Cancel attendance)
  /// **Usage:** This function is used to unconfirm the attendance of a participant by ID.
  /// Used in: ScannedParticipantsScreen
  static Future<bool> unconfirmAttendance(String id) async {
    final response = await http.post(Uri.parse('$baseUrl/$id/unconfirm'));
    return response.statusCode == 200;
  }
}
