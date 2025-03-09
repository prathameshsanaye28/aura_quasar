import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class MentalHealthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🟢 Increments a specific feature when triggered
  Future<void> incrementFeature(String userId, String feature) async {
    String weekId = _getCurrentWeekId();

    DocumentReference docRef = _firestore
        .collection("mental_health_tracking")
        .doc("$userId-$weekId");

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // Create a new document for the week if not present
        transaction.set(docRef, {
          "userId": userId,
          "weekId": weekId,
          feature: 1,
          "timestamp": DateTime.now(),
        });
      } else {
        // Increment the existing feature count
        transaction.update(docRef, {
          feature: (snapshot[feature] ?? 0) + 1,
        });
      }
    });
  }

  Future<void> incrementQuiz(String userId, int score) async {
    String weekId = _getCurrentWeekId();

    DocumentReference docRef = _firestore
        .collection("mental_health_tracking")
        .doc("$userId-$weekId");

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // Create a new document for the week if not present
        transaction.set(docRef, {
          "userId": userId,
          "weekId": weekId,
          "quiz": score,
          "timestamp": DateTime.now(),
        });
      } else {
        // Increment the existing feature count
        transaction.update(docRef, {
          "quiz": (snapshot["quiz"] ?? 0) + 1,
        });
      }
    });
  }

  /// 🟢 Fetch Weekly Data for Graph Display
  Future<List<Map<String, dynamic>>> fetchWeeklyData(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection("mental_health_tracking")
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .limit(4) // Fetch last 4 weeks
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  /// 🟢 Generates a unique week ID (YYYY-WW format)
  String _getCurrentWeekId() {
    DateTime now = DateTime.now();
    int weekOfYear = ((now.day - 1) ~/ 7) + 1; // Approximate week calc
    return "${now.year}-W$weekOfYear";
  }
}