import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final String severity;

  ResultScreen({required this.score, required this.severity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assessment Results')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Your Score: $score', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
              SizedBox(height: 16.0),
              Text('Severity: $severity', style: TextStyle(fontSize: 20.0, color: Colors.red)),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Back to Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
