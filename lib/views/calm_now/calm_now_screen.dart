import 'dart:async';

import 'package:aura_techwizard/components/colors.dart'; // Add this import
import 'package:aura_techwizard/services/mental_health_service.dart';
import 'package:aura_techwizard/views/music_screen/app.dart'; // Add this import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CalmNowScreen extends StatefulWidget {
  @override
  _CalmNowScreenState createState() => _CalmNowScreenState();
}

class _CalmNowScreenState extends State<CalmNowScreen> {
  int _breathCount = 0;
  bool _isBreathing = false;
  Timer? _breathingTimer;
  Timer? _hapticTimer;
  final List<String> _affirmations = [
    "You are safe",
    "This moment will pass",
    "Take it one breath at a time",
    "You are stronger than you know",
    "You've got this",
  ];

  final Map<String, String> emergencyContacts = {
    'AASRA': '91-9820466726',
    'Vandrevala Foundation': '1860-2662-345',
    'iCall': '+91-9152987821',
    'Sneha Foundation': '044-24640050',
  };

    final MentalHealthService _service = MentalHealthService();
    final User? user = FirebaseAuth.instance.currentUser;

void onFeatureTriggered(String userId, String feature) {
  _service.incrementFeature(userId, feature);
}

  void init(){
    onFeatureTriggered(user!.uid, 'panic_attack');
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _hapticTimer?.cancel();
    super.dispose();
  }

  void _startBreathingExercise() {
    setState(() {
      _isBreathing = true;
      _breathCount = 0;
    });

    // Initial haptic feedback to indicate start
    HapticFeedback.mediumImpact();

    // Timer for breath counting
    _breathingTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      setState(() {
        _breathCount++;
        if (_breathCount >= 12) {
          // 3 complete breath cycles
          _isBreathing = false;
          timer.cancel();
          _hapticTimer?.cancel();
          // Final haptic feedback to indicate completion
          HapticFeedback.heavyImpact();
        }
      });
    });

    // Haptic feedback timer for breathing guidance
    _hapticTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (_isBreathing) {
        if (_breathCount.isEven) {
          // Gentle vibration pattern for inhale
          _breatheInHaptic();
        } else {
          // Different vibration pattern for exhale
          _breatheOutHaptic();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _stopBreathingExercise() {
    setState(() {
      _isBreathing = false;
      _breathCount = 0;
    });
    _breathingTimer?.cancel();
    _hapticTimer?.cancel();
  }

  Future<void> _breatheInHaptic() async {
    await HapticFeedback.lightImpact();
  }

  Future<void> _breatheOutHaptic() async {
    await HapticFeedback.selectionClick();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Widget _buildBreathingCircle() {
    return AnimatedContainer(
      duration: Duration(seconds: 4),
      curve: Curves.easeInOut,
      width: _breathCount.isEven ? 200.0 : 150.0,
      height: _breathCount.isEven ? 200.0 : 150.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGreen.withOpacity(0.3),
        border: Border.all(
          color: AppColors.lightGreen,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGreen.withOpacity(0.2),
            spreadRadius: _breathCount.isEven ? 10 : 5,
            blurRadius: _breathCount.isEven ? 15 : 10,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _breathCount.isEven ? "Breathe In" : "Breathe Out",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Feel the vibration",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroundingExercise() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.veryLightPink,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGray.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "5-4-3-2-1 Grounding Exercise",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.mediumGray,
            ),
          ),
          SizedBox(height: 12),
          Text("👀 See 5 things around you"),
          Text("👆 Feel 4 things you can touch"),
          Text("👂 Hear 3 different sounds"),
          Text("👃 Notice 2 things you can smell"),
          Text("👅 Taste 1 thing"),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calm Now"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Emergency Call Card
              Card(
                color: const Color.fromARGB(255, 255, 234, 255),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Need immediate help?",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      SizedBox(height: 12),
                      ...emergencyContacts.entries
                          .map((contact) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.phone),
                                  label:
                                      Text("${contact.key}: ${contact.value}"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 228, 226, 249),
                                    foregroundColor: Colors.black,
                                  ),
                                  onPressed: () =>
                                      _makePhoneCall(contact.value),
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Breathing Exercise
              Card(
                color: AppColors.paleGreen,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Breathing Exercise with Haptic Feedback",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      SizedBox(height: 16),
                      _isBreathing
                          ? Column(
                              children: [
                                _buildBreathingCircle(),
                                SizedBox(height: 16),
                                ElevatedButton.icon(
                                  icon: Icon(Icons.stop),
                                  label: Text("Stop Breathing Exercise"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 255, 234, 255),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  onPressed: _stopBreathingExercise,
                                ),
                              ],
                            )
                          : ElevatedButton.icon(
                              icon: Icon(Icons.air),
                              label: Text("Start Breathing Exercise"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightGreen,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              onPressed: _startBreathingExercise,
                            ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Grounding Exercise
              _buildGroundingExercise(),
              SizedBox(height: 24),

              // Affirmations
              Card(
                color: AppColors.veryLightPink,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Positive Affirmations",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      SizedBox(height: 16),
                      ..._affirmations
                          .map((affirmation) => Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  affirmation,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color:
                                        const Color.fromARGB(206, 35, 47, 37),
                                  ),
                                ),
                              ))
                          .toList(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Listen to Music
              Card(
                color: AppColors.paleGreen,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Listen to Music",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mediumGray,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: Icon(Icons.music_note),
                        label: Text("Go to Music Section"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MusicAppScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
