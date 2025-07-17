import 'package:shared_preferences/shared_preferences.dart';
import '../Data/participant.dart';

class LocalStorage {
  static const String key = 'confirmed_participants';

  static Future<void> addParticipant(Participant participant) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current =
        prefs.getStringList(key) ?? <String>[];

    current.add(participant.toJson());
    await prefs.setStringList(key, current);
  }

  static Future<List<Participant>> getParticipants() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> current =
        prefs.getStringList(key) ?? <String>[];

    return current.map((e) => Participant.fromJson(e)).toList();
  }

  static Future<void> clearParticipants() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
