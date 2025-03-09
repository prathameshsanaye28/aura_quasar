import 'package:aura_techwizard/localization/locales.dart'; // Add this import
import 'package:aura_techwizard/models/user.dart';
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:aura_techwizard/views/HomeScreen/HomeScreen.dart';
import 'package:aura_techwizard/views/adopt_pet/adopt_pet_screen.dart';
import 'package:aura_techwizard/views/analyse_report.dart';
import 'package:aura_techwizard/views/analysis_screens/analysis_screen.dart';
import 'package:aura_techwizard/views/app_usage.dart';
import 'package:aura_techwizard/views/articles.dart';
import 'package:aura_techwizard/views/chat_screen.dart/chat_screen.dart';
import 'package:aura_techwizard/views/chat_screen.dart/search_screen.dart';
import 'package:aura_techwizard/views/diet_plan_screen.dart';
import 'package:aura_techwizard/views/habit_tracker/habit_tracker.dart';
import 'package:aura_techwizard/views/period_tracker.dart';
import 'package:aura_techwizard/views/quiz_screen/quiz_screen.dart';
import 'package:aura_techwizard/views/quiz_screen/virtualpet_screen.dart';
import 'package:aura_techwizard/views/sleep_prediction_screen.dart';
import 'package:aura_techwizard/views/stress_Chart.dart';
import 'package:aura_techwizard/views/therapist_screen.dart';
import 'package:aura_techwizard/views/video_call/home_page.dart';
import 'package:aura_techwizard/views/view_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aura_techwizard/views/gamification/gamification_feature.dart'; // Add this import

import '../views/CircadianScreens/weather_page.dart';

class AppDrawer extends StatefulWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  late FlutterLocalization _flutterLocalization;
  late bool isHindiLanguage;
  bool _isLoading = true;
  late String _currentLocale;

  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;
  }

  Future<void> _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isHindiLanguage = prefs.getBool('isHindiLanguage') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveLanguagePreference(bool isHindi) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isHindiLanguage', isHindi);
  }

  void _setLocale(String? value) {
    if (value == null) return;

    if (value == "en") {
      _flutterLocalization.translate("en");
    } else if (value == "hi") {
      _flutterLocalization.translate("hi");
    } else {
      return;
    }

    setState(() {
      _currentLocale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Drawer(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final User? user = Provider.of<UserProvider>(context).getUser;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Color.fromRGBO(174, 175, 247, 1), // Soft pink
                // Color.fromRGBO(253, 221, 236, 1), // Light peach
                Color(0xFFC5DEE3), // Pale blue
              ],
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleData.aura.getString(context), // Update this line
                  style: TextStyle(
                      fontSize: 50,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(context, LocaleData.home.getString(context),
                Icons.home, HomeScreen(), '/home'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.stress_chart.getString(context),
                Icons.receipt,
                StressChart(),
                '/stress_chart'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.period.getString(context),
                Icons.bloodtype,
                PeriodTrackerScreen(),
                '/periods'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.habit.getString(context),
                Icons.track_changes,
                RiveHouseTest(),
                '/habit'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.labReportAnalysis.getString(context),
                Icons.receipt,
                SummarizerScreen(),
                '/summarizer'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.dietPlanGenerator.getString(context),
                Icons.restaurant,
                DietPlanScreen(),
                '/diet_plan'),
          ),
             Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.usageAnalyser.getString(context),
                Icons.auto_graph,
                CombinedAnalysisScreen(),
                '/combined_analysis'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.video.getString(context),
                Icons.video_call,
                HomePage(),
                '/video_call'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.app_usage.getString(context),
                Icons.analytics,
                AppUsageApp(),
                '/app_usage'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
              context,
              LocaleData.viewTask.getString(context),
              Icons.task,
              ViewTask(),
              '/viewTask',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
              context,
              LocaleData.sleep_disorder.getString(context),
              Icons.snooze,
              SleepPredictionScreen(),
              '/sleep_disorder',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
              context,
              LocaleData.chat.getString(context),
              Icons.chat,
              SearchScreen(),
              '/chat',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
              context,
              LocaleData.articles.getString(context),
              Icons.article,
              NewsScreen(),
              '/articles',
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.therapistNearMe.getString(context),
                Icons.medical_services_outlined,
                TherapistScreen(
                  userUid: user!.uid,
                ),
                '/therapist'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.weather.getString(context), // Update this line
                Icons.wb_sunny,
                WeatherPage(),
                '/weather'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.challenges.getString(context), // Add this block
                Icons.flag,
                ChallengesScreen(userId: user!.uid),
                '/challenges'),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
               "Chatbot",
                Icons.chat_bubble_outline,
                ChatBotScreen(),
                '/Chatbot'),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.adoptPet.getString(context),
                Icons.pets,
                PetAdoptionScreen(),
                '/adopt_pet'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildDrawerItem(
                context,
                LocaleData.quiz.getString(context), // Add this block
                Icons.question_mark,
                QuizScreen(),
                '/quiz'),
          ),
          
          Divider(),
          SwitchListTile(
            title: Text(isHindiLanguage
                ? LocaleData.hindi.getString(context)
                : LocaleData.english.getString(context)),
            value: isHindiLanguage,
            onChanged: (bool value) {
              setState(() {
                isHindiLanguage = value;
              });
              _saveLanguagePreference(value);
              _setLocale(value ? "hi" : "en");
            },
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(BuildContext context, String title, IconData icon,
      Widget destination, String route) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      selected: widget.currentRoute == route,
      selectedTileColor: Color.fromRGBO(253, 221, 236, 1),
      onTap: () {
        if (widget.currentRoute != route) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => destination));
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
