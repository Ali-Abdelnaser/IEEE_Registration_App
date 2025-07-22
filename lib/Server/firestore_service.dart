import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class FirestoreService {
  final CollectionReference _attendeesCollection = FirebaseFirestore.instance
      .collection('attendees');

  /// ✅ تجيب كل البيانات من Firestore
  Future<List<Map<String, dynamic>>> fetchAllParticipants() async {
    final snapshot = await _attendeesCollection.get();
    return snapshot.docs
        .map(
          (doc) => {
            'id': doc['id'],
            'name': doc['name'],
            'email': doc['email'],
            'team': doc['team'],
            'attendance': doc['attendance'],
          },
        )
        .toList();
  }

  /// ✅ تبحث عن شخص بـ ID وتجيب بياناته
  Future<Map<String, dynamic>?> getParticipantById(String id) async {
    final querySnapshot = await _attendeesCollection
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      return {
        'docId': doc.id, // ده علشان نستخدمه لما نيجي نعمل update
        'id': doc['id'],
        'name': doc['name'],
        'email': doc['email'],
        'team': doc['team'],
        'attendance': doc['attendance'],
      };
    } else {
      return null;
    }
  }

  /// ✅ تأكيد الحضور (تحديث attendance = true)
  static Future<bool> confirmAttendance(String id) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('attendees')
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('attendees')
          .doc(docId)
          .update({'attendance': true});
      return true;
    }
    return false;
  }

  /// ✅ إلغاء الحضور (تحديث attendance = false)
  Future<bool> unconfirmAttendance(String id) async {
    final querySnapshot = await _attendeesCollection
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) { 
      final docId = querySnapshot.docs.first.id;
      await _attendeesCollection.doc(docId).update({'attendance': false});
      return true;
    }
    return false;
  }

  /// تجيب المشاركين اللي attendance = true
  Future<List<Map<String, dynamic>>> fetchConfirmedParticipants() async {
    final snapshot = await _attendeesCollection
        .where('attendance', isEqualTo: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => {
            'id': doc['id'],
            'name': doc['name'],
            'email': doc['email'],
            'team': doc['team'],
            'attendance': doc['attendance'],
          },
        )
        .toList();
  }

  Future<void> loginUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final uid = userCredential.user!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      final isAdmin = userDoc.data()?['isAdmin'] ?? false;

      if (isAdmin) {
        Navigator.pushNamed(context, '/dashboard');
      } else {
        Navigator.pushNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ ${e.message}')));
    }
  }
}
