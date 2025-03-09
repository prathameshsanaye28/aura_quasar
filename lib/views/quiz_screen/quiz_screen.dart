import 'package:aura_techwizard/services/mental_health_service.dart';
import 'package:aura_techwizard/views/quiz_screen/result_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';


class Question {
  final String text;
  final List<String> options;
  int? selectedOption;

  Question({required this.text, required this.options});
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
   final List<Question> questions = [
    Question(text: 'Little interest or pleasure in doing things?', options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day']),
    Question(text: 'Feeling down, depressed, or hopeless?', options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day']),
    Question(text: 'Trouble sleeping or sleeping too much?', options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day']),
    Question(text: 'Feeling tired or having little energy?', options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day']),
    Question(text: 'Feeling bad about yourself or like a failure?', options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day']),
    Question(text: 'Trouble concentrating on things like reading or watching TV?', options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day']),
    Question(text: 'Feeling restless or moving too slowly?', options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day']),
    Question(text: 'Thoughts of being better off dead or hurting yourself?', options: ['Not at all', 'Several days', 'More than half the days', 'Nearly every day']),
  ];

  int currentQuestionIndex = 0;
  SMIInput<double>? waveInput;
  Artboard? riveArtboard;
  double opacity = 1.0;

  @override
  void initState() {
    super.initState();
    loadRive();
  }

  void loadRive() async {
    final data = await RiveFile.asset('assets/RiveAssets/penguin.riv');
    final artboard = data.mainArtboard;
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      waveInput = controller.findInput('wave');
    }
    setState(() => riveArtboard = artboard);
    triggerWave();
  }

  void triggerWave() {
    if (waveInput != null) {
      waveInput!.value = 1;
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          waveInput!.value = 0;
          opacity = 1.0;
        });
      });
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        opacity = 0.0;
      });
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          currentQuestionIndex++;
          triggerWave();
        });
      });
    } else {
      submitQuiz();
    }
  }

  int calculateScore() {
    int score = 0;
    for (var question in questions) {
      if (question.selectedOption != null) {
        score += question.selectedOption!;
      }
    }
    return score;
  }

  String getSeverity(int score) {
    if (score <= 4) return 'Minimal Depression';
    if (score <= 9) return 'Mild Depression';
    if (score <= 14) return 'Moderate Depression';
    if (score <= 19) return 'Moderately Severe Depression';
    return 'Severe Depression';
  }

  final MentalHealthService _service = MentalHealthService();
    final User? user = FirebaseAuth.instance.currentUser;

void onFeatureTriggered(String userId, int score) {
  _service.incrementQuiz(userId, score);
}

  void submitQuiz() {
    int totalScore = calculateScore();
    String severity = getSeverity(totalScore);

    onFeatureTriggered(user!.uid, totalScore);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(score: totalScore, severity: severity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mental Health Assessment')),
      body: Column(
        children: [
          SizedBox(height: 20),
          riveArtboard != null
              ? SizedBox(height: 200, child: Rive(artboard: riveArtboard!))
              : CircularProgressIndicator(),
          SizedBox(height: 20),
          AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: opacity,
            child: Column(
              children: [
                Text(questions[currentQuestionIndex].text, textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Column(
                  children: List.generate(questions[currentQuestionIndex].options.length, (optionIndex) {
                    return RadioListTile<int>(
                      title: Text(questions[currentQuestionIndex].options[optionIndex]),
                      value: optionIndex,
                      groupValue: questions[currentQuestionIndex].selectedOption,
                      onChanged: (value) {
                        setState(() {
                          questions[currentQuestionIndex].selectedOption = value;
                        });
                        nextQuestion();
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}