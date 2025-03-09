import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  String id;
  String title;
  bool isCompleted;
  String priority;
  String userId;
  int hours;
  int minutes;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.priority,
    required this.userId,
    required this.hours,
    required this.minutes,
  });

  factory Task.fromDocument(DocumentSnapshot doc) {
    return Task(
      id: doc.id,
      title: doc['title'],
      isCompleted: doc['isCompleted'],
      priority: doc['priority'],
      userId: doc['userId'],
      hours: doc['hours'],
      minutes: doc['minutes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'isCompleted': isCompleted,
      'priority': priority,
      'userId': userId,
      'hours': hours,
      'minutes': minutes,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? priority,
    String? userId,
    int? hours,
    int? minutes,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      userId: userId ?? this.userId,
      hours: hours ?? this.hours,
      minutes:minutes ?? this.minutes,
    );
  }

  int getTotalMinutes() {
    return hours * 60 + minutes;
  }
}
