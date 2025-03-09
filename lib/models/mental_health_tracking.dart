import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class MentalHealthTracking {
  int app_switches;
  int panic_attack;
  int quiz_score;
  int sleep_quality;
  int steps_walked;
  int typing_errors;
  int water_intake;
  Timestamp timestamp;
  String userId;
  String weekId;

  MentalHealthTracking({
    required this.app_switches,
    required this.panic_attack,
    required this.quiz_score,
    required this.sleep_quality,
    required this.steps_walked,
    required this.typing_errors,
    required this.water_intake,
    required this.timestamp,
    required this.userId,
    required this.weekId,
  });

  factory MentalHealthTracking.fromDocument(DocumentSnapshot doc) {
    return MentalHealthTracking(
      app_switches: doc['app_switches'] ?? 0,
      panic_attack: doc['panic_attack'] ?? 0,
      quiz_score: doc['quiz_score'] ?? 0,
      sleep_quality: doc['sleep_quality'] ?? 0,
      steps_walked: doc['steps_walked'] ?? 0,
      typing_errors: doc['typing_errors'] ?? 0,
      water_intake: doc['water_intake'] ?? 0,
      timestamp: doc['timestamp'] ?? Timestamp.now(),
      userId: doc['userId'] ?? '',
      weekId: doc['weekId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'app_switches': app_switches,
      'panic_attack': panic_attack,
      'quiz_score': quiz_score,
      'sleep_quality': sleep_quality,
      'steps_walked': steps_walked,
      'typing_errors': typing_errors,
      'water_intake': water_intake,
      'timestamp': timestamp,
      'userId': userId,
      'weekId': weekId,
    };
  }

  MentalHealthTracking copyWith({
    int? app_switches,
    int? panic_attack,
    int? quiz_score,
    int? sleep_quality,
    int? steps_walked,
    int? typing_errors,
    int? water_intake,
    Timestamp? timestamp,
    String? userId,
    String? weekId,
  }) {
    return MentalHealthTracking(
      app_switches: app_switches ?? this.app_switches,
      panic_attack: panic_attack ?? this.panic_attack,
      quiz_score: quiz_score ?? this.quiz_score,
      sleep_quality: sleep_quality ?? this.sleep_quality,
      steps_walked: steps_walked ?? this.steps_walked,
      typing_errors: typing_errors ?? this.typing_errors,
      water_intake: water_intake ?? this.water_intake,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      weekId: weekId ?? this.weekId,
    );
  }

  int getScore() {
    double x=(0.10*app_switches)+(0.30*panic_attack)+(0.25*quiz_score)+(0.10*(10-typing_errors))+(0.15*(10-sleep_quality))+(0.05*(5000-((steps_walked<2000)?steps_walked:2000))/2000)+(0.05*water_intake);
    return x.toInt();
  }
}
