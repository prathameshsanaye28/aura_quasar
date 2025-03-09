import 'package:flutter_localization/flutter_localization.dart';

const List<MapLocale> LOCALES = [
  MapLocale("en", LocaleData.EN),
  MapLocale("hi", LocaleData.HI),
];

mixin LocaleData {
  static const String home = "home";
  static const String adoptPet = "adoptPet";
  static const String labReportAnalysis = "labReportAnalysis";
  static const String dietPlanGenerator = "dietPlanGenerator";
  static const String usageAnalyser = "usageAnalyser";
  static const String therapistNearMe = "therapistNearMe";
  static const String sleep_disorder = "sleep_disorder";
  static const String hindi = "hindi";
   static const String viewTask = "viewTask";
  static const String stress_chart = "stress_chart";
  static const String app_usage = "app_usage";
  static const String video = "video";
  static const String habit = "habit";
  static const String english = "english";
  static const String aura = "aura";
  static const String welcomeBack = "welcomeBack";
  static const String howAreYouFeeling = "howAreYouFeeling";
  static const String happy = "happy";
  static const String calm = "calm";
  static const String low = "low";
  static const String stressed = "stressed";
  static const String therapySessions = "therapySessions";
  static const String openUp = "openUp";
  static const String matterMost = "matterMost";
  static const String bookNow = "bookNow";
  static const String yourTasks = "yourTasks";
  static const String journal = "journal";
  static const String music = "music";
  static const String meditation = "meditation";
  static const String games = "games";
  static const String articles = "articles";
  static const String weather = "weather";
  static const String calmNow = "calmNow";
  static const String challenges = "challenges";
  static const String quiz = "quiz";
  static const String chat = "chat";
  static const String period= "period";

  static const Map<String, dynamic> EN = {
    home: "Home",
    adoptPet: "Adopt Pet",
    labReportAnalysis: "Lab Report Analysis",
    dietPlanGenerator: "Diet Plan Generator",
    usageAnalyser: "Usage Analyser",
    therapistNearMe: "Therapist Near Me",
    app_usage:"Digital Data Usage",
    viewTask: "Organize your Tasks",
    stress_chart:"View Your Stress Patterns",
    habit: "Habit Tracking",
    hindi: "Hindi",
    sleep_disorder:"Sleep Disorder Prediction",
    english: "English",
    aura: "Aura",
    welcomeBack: "Welcome back",
    howAreYouFeeling: "How are you feeling today?",
    happy: "Happy",
    calm: "Calm",
    low: "Low",
    stressed: "Stressed",
    therapySessions: "Therapy Sessions",
    openUp: "Let's open up to the things that",
    matterMost: "matter the most.",
    bookNow: "Book Now",
    yourTasks: "Your Tasks",
    journal: "Journal",
    music: "Music",
    meditation: "Meditation",
    games: "Games",
    articles: "Articles",
    weather: "Weather",
    calmNow: "Calm Now",
    challenges: "Challenges",
    quiz: "Quiz",
    chat: "Chat",
    period: "Period Tracker",
    video: "Video Call",
  };

  static const Map<String, dynamic> HI = {
    home: "होम",
    adoptPet: "पालतू जानवर अपनाएं",
    labReportAnalysis: "लैब रिपोर्ट विश्लेषण",
    dietPlanGenerator: "आहार योजना जनरेटर",
    usageAnalyser: "उपयोग विश्लेषक",
    therapistNearMe: "मेरे पास चिकित्सक",
    hindi: "हिंदी",
    english: "अंग्रेज़ी",
    aura: "ऑरा",
    welcomeBack: "वापसी पर स्वागत है",
    viewTask: "कार्य आयोजक",
    stress_chart:"अपने तनाव पैटर्न देखें",
    app_usage:"डिजिटल डेटा उपयोग",
    howAreYouFeeling: "आज आप कैसा महसूस कर रहे हैं?",
    happy: "खुश",
    calm: "शांत",
    low: "कम",
    stressed: "तनावग्रस्त",
    therapySessions: "चिकित्सा सत्र",
    openUp: "आइए उन चीजों के बारे में खुलकर बात करें जो",
    matterMost: "सबसे ज्यादा मायने रखती हैं।",
    bookNow: "अभी बुक करें",
    sleep_disorder:"नींद विकार विश्लेषण",
    yourTasks: "आपके कार्य",
    journal: "पत्रिका",
    music: "संगीत",
    meditation: "ध्यान",
    games: "खेल",
    articles: "समाचार",
    weather: "मौसम",
    calmNow: "शांत हो जाओ",
    challenges: "चुनौतियाँ",
    quiz: "प्रश्नोत्तरी",
    chat: "बातचीत करना",
    period: 'पीरियड ट्रैकर',
    habit: 'आदत ट्रैकिंग',
    video: "वीडियो कॉल"
  };
}
