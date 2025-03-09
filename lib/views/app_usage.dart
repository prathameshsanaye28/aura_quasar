import 'package:flutter/material.dart';
import 'package:app_usage/app_usage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class AppColors {
  static const Color paleGreen = Color(0xFFF3FDE8);
  static const Color lightGreen = Color(0xFF9CDBA6);
  static const Color mediumGreen = Color(0xFFDEF9C4);
  static const Color darkGreen = Color(0xFF4CAF50);
  static const Color lightGray = Color(0xFF9F9494);
  static const Color mediumGray = Color(0xFF7C6C6C);
  static const Color darkGray = Color(0xFFD9D9D9);
  static const Color lightPink = Color(0xFFFFB1C4);
  static const Color veryLightPink = Color(0xFFFFF6F6);
  static const Color lightRed = Color(0xFFFFDDDD);
  
  // Additional vibrant colors for pie chart
  static const List<Color> chartColors = [
    Color(0xFF4CAF50),  // Green
    Color(0xFFFF5722),  // Deep Orange
    Color(0xFF2196F3),  // Blue
    Color(0xFFFFEB3B),  // Yellow
    Color(0xFF9C27B0),  // Purple
    Color(0xFFE91E63),  // Pink
    Color(0xFF009688),  // Teal
    Color(0xFFFF9800),  // Orange
    Color(0xFF795548),  // Brown
    Color(0xFF607D8B),  // Blue Grey
  ];
}

class AppUsageApp extends StatefulWidget {
  const AppUsageApp({super.key});

  @override
  State<AppUsageApp> createState() => _AppUsageAppState();
}

class _AppUsageAppState extends State<AppUsageApp> {
  List<AppUsageInfo> _infos = [];
  String _selectedDuration = "1 hour"; // Default selection
  bool _isLoading = false;

  final Map<String, int> _durationMap = {
    "1 hour": 1,
    "10 hours": 10,
    "1 day": 24,
    "1 week": 24 * 7,
    "1 month": 24 * 30,
    "1 year": 24 * 365,
  };

  // Total usage time
  Duration _totalUsageTime = Duration.zero;
  
  // Map to store app usage percentages
  Map<String, double> _appPercentages = {};
  
  // Map to store app colors
  Map<String, Color> _appColors = {};

  void getUsageStats() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      DateTime endDate = DateTime.now();
      int hours = _durationMap[_selectedDuration] ?? 1;
      DateTime startDate = endDate.subtract(Duration(hours: hours));

      List<AppUsageInfo> infoList =
          await AppUsage().getAppUsage(startDate, endDate);

      // Sort by usage time in decreasing order & exclude "aura_techwizard"
      List<AppUsageInfo> sortedList = infoList
          .where((app) => app.appName != "aura_techwizard")
          .toList()
        ..sort((a, b) => b.usage.compareTo(a.usage));
      
      // Add Instagram and Netflix as requested
      Duration totalRealUsage = Duration.zero;
      for (var app in sortedList) {
        totalRealUsage += app.usage;
      }
      
      // Add synthetic data (Instagram and Netflix)
      final instagramUsage = Duration(microseconds: (totalRealUsage.inMicroseconds * 0.15).round());
      final netflixUsage = Duration(microseconds: (totalRealUsage.inMicroseconds * 0.19).round());
      
      // Create synthetic app usage info objects with all 5 required parameters
      final now = DateTime.now();
      final lastHour = now.subtract(const Duration(hours: 1));
      
      sortedList.add(AppUsageInfo(
        "instagram", 
        instagramUsage.inSeconds.toDouble(), 
        lastHour, 
        now,
        now.subtract(const Duration(minutes: 15)) // Last foreground time
      ));
      
      sortedList.add(AppUsageInfo(
        "netflix", 
        netflixUsage.inSeconds.toDouble(), 
        lastHour, 
        now,
        now.subtract(const Duration(minutes: 30)) // Last foreground time
      ));
      
      // Resort after adding synthetic data
      sortedList.sort((a, b) => b.usage.compareTo(a.usage));
      
      // Calculate total time including synthetic data
      _totalUsageTime = Duration.zero;
      for (var app in sortedList) {
        _totalUsageTime += app.usage;
      }
      
      // Calculate percentages and assign colors
      _appPercentages = {};
      _appColors = {};
      
      for (int i = 0; i < sortedList.length; i++) {
        var app = sortedList[i];
        String appName = formatAppName(app.appName);
        double percentage = app.usage.inMicroseconds / _totalUsageTime.inMicroseconds * 100;
        _appPercentages[appName] = percentage;
        
        // Assign color (cycle through the colors list)
        _appColors[appName] = AppColors.chartColors[i % AppColors.chartColors.length];
      }
      
      // Add "Other" category if there are more than 5 apps
      if (sortedList.length > 5) {
        List<AppUsageInfo> topApps = sortedList.sublist(0, 5);
        Duration otherUsage = Duration.zero;
        
        for (int i = 5; i < sortedList.length; i++) {
          otherUsage += sortedList[i].usage;
        }
        
        if (otherUsage.inMicroseconds > 0) {
          sortedList = [...topApps];
          // Add "Other" with all 5 required parameters
          sortedList.add(AppUsageInfo(
            "other", 
            otherUsage.inSeconds.toDouble(), 
            startDate, 
            endDate,
            now.subtract(const Duration(minutes: 5)) // Last foreground time
          ));
          
          // Add "Other" to percentages and colors
          double otherPercentage = otherUsage.inMicroseconds / _totalUsageTime.inMicroseconds * 100;
          _appPercentages["Other"] = otherPercentage;
          _appColors["Other"] = AppColors.chartColors[5 % AppColors.chartColors.length];
        }
      }
      
      setState(() {
        _infos = sortedList;
        _isLoading = false;
      });
    } catch (exception) {
      print(exception);
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatTime(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    return "${hours}h ${minutes}m";
  }

  String formatAppName(String appName) {
    if (appName == "other") return "Other";
    if (appName == "instagram") return "Instagram";
    if (appName == "netflix") return "Netflix";
    
    return appName
        .split('_')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : "")
        .join(" ");
  }

  List<PieChartSectionData> getSections() {
    List<PieChartSectionData> sections = [];
    
    _appPercentages.forEach((appName, percentage) {
      sections.add(
        PieChartSectionData(
          color: _appColors[appName] ?? Colors.grey,
          value: percentage,
          title: '', // Keep title empty as requested
          radius: 70, // Slightly reduced radius to prevent overflow
          titleStyle: const TextStyle(
            fontSize: 0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });
    
    return sections;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleGreen,
      appBar: AppBar(
        title: const Text("📊 App Usage Analysis"),
        backgroundColor: const Color.fromARGB(255, 177, 201, 144),
        centerTitle: true,
        elevation: 5,
      ),
      // Make the entire content scrollable
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  "Understanding your app usage can help you manage your digital well-being and reduce stress caused by excessive screen time.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w500, 
                    color: Color.fromARGB(255, 83, 105, 83)
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.mediumGreen,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDuration,
                        dropdownColor: AppColors.mediumGreen,
                        style: TextStyle(fontSize: 16, color: AppColors.darkGreen),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDuration = newValue!;
                          });
                        },
                        items: _durationMap.keys
                            .map<DropdownMenuItem<String>>(
                                (String duration) => DropdownMenuItem<String>(
                                      value: duration,
                                      child: Text(duration),
                                    ))
                            .toList(),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : getUsageStats,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            "Show",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _infos.isEmpty
                ? SizedBox(
                    height: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/usage.jpeg', width: 250),
                        const SizedBox(height: 10),
                        const Text("No data available. Tap 'Show' to fetch usage.",
                            style: TextStyle(fontSize: 16, color: AppColors.lightGray)),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Pie chart section with increased height
                      Container(
                        height: 300, // Increased height to avoid overflow
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              "App Usage Distribution",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mediumGray,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1.3, // Control the aspect ratio
                                child: PieChart(
                                  PieChartData(
                                    sections: getSections(),
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                    pieTouchData: PieTouchData(enabled: false),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Total usage time
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          "Total Usage Time: ${formatTime(_totalUsageTime)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mediumGray,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // App list
                      ListView.builder(
                        shrinkWrap: true, // Important for scrolling within SingleChildScrollView
                        physics: const NeverScrollableScrollPhysics(), // Disable ListView scrolling
                        itemCount: _infos.length,
                        itemBuilder: (context, index) {
                          final app = _infos[index];
                          final appName = formatAppName(app.appName);
                          final color = _appColors[appName] ?? Colors.grey;
                          final percentage = _appPercentages[appName]?.toStringAsFixed(1) ?? "0.0";
                          
                          return Card(
                            color: AppColors.veryLightPink,
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color,
                                radius: 20,
                                child: Icon(
                                  appName == "Instagram" 
                                      ? Icons.camera_alt
                                      : appName == "Netflix"
                                          ? Icons.movie
                                          : appName == "Other"
                                              ? Icons.apps
                                              : Icons.phone_android,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                appName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mediumGray,
                                ),
                              ),
                              subtitle: Text(
                                "$percentage% of total",
                                style: TextStyle(
                                  color: color.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              trailing: Text(
                                formatTime(app.usage),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkGreen,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Text(
                "Analyze your screen time and make mindful digital choices! 📱✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16, 
                  fontWeight: FontWeight.w500, 
                  color: const Color.fromARGB(255, 45, 53, 45)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
