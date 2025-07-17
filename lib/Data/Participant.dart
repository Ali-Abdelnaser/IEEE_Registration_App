import 'dart:convert';

class Participant {
  final String id;
  final String name;
  final String email;
  final String team;

  Participant({
    required this.id,
    required this.name,
    required this.email,
    required this.team,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'team': team,
    };
  }

  factory Participant.fromMap(Map<String, dynamic> map) {
    return Participant(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      team: map['team'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Participant.fromJson(String source) =>
      Participant.fromMap(json.decode(source));
}
