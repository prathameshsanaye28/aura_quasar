import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class PeriodTrackerScreen extends StatefulWidget {
  const PeriodTrackerScreen({super.key});

  @override
  _PeriodTrackerScreenState createState() => _PeriodTrackerScreenState();
}

class _PeriodTrackerScreenState extends State<PeriodTrackerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Period Tracker"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Dashboard"),
            Tab(text: "Calendar"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CycleDashboardScreen(),
          CycleCalendarScreen(),
        ],
      ),
    );
  }
}

class CycleDashboardScreen extends StatefulWidget {
  @override
  _CycleDashboardScreenState createState() => _CycleDashboardScreenState();
}

class _CycleDashboardScreenState extends State<CycleDashboardScreen> {
  // Currently selected phase
  String _selectedPhase = "Period";

  // Phase information
  final Map<String, Color> phaseColors = {
    "Period": Colors.pink,
    "Follicular": Colors.purple,
    "Ovulation": Colors.blue,
    "Luteal": Colors.orange,
  };

  // Light version of phase colors for app bar
  Map<String, Color> get lightPhaseColors => {
        for (var entry in phaseColors.entries)
          entry.key: entry.value.withOpacity(0.7)
      };

  // Phase recommendations
  final Map<String, Map<String, List<String>>> phaseRecommendations = {
    "Period": {
      "self_care": [
        "Rest more and prioritize sleep",
        "Apply heat to relieve cramps",
        "Stay hydrated",
        "Take warm baths with Epsom salts",
        "Gentle massage of lower back and abdomen"
      ],
      "mental_health": [
        "Practice mindfulness meditation",
        "Allow yourself to feel emotions without judgment",
        "Keep a mood journal",
        "Set boundaries and say no when needed",
        "Connect with supportive friends"
      ],
      "activities": [
        "Gentle yoga or stretching",
        "Light walking",
        "Reading or creative hobbies",
        "Nesting and organizing space",
        "Avoid high-intensity workouts"
      ]
    },
    "Follicular": {
      "self_care": [
        "Focus on skin care routine",
        "Increase protein intake",
        "Try new hairstyles or beauty treatments",
        "Get plenty of vitamin D",
        "Use this energy boost for deeper cleaning"
      ],
      "mental_health": [
        "Set new goals and make plans",
        "Brainstorm creative projects",
        "Network and socialize more",
        "Try something new and challenging",
        "Journal about your aspirations"
      ],
      "activities": [
        "Strength training",
        "Cardio workouts",
        "Dancing or group fitness classes",
        "Outdoor activities",
        "Start new projects or learning activities"
      ]
    },
    "Ovulation": {
      "self_care": [
        "Stay extra hydrated",
        "Eat foods rich in antioxidants",
        "Get adequate sleep despite high energy",
        "Wear comfortable clothing",
        "Monitor fertility signs if tracking"
      ],
      "mental_health": [
        "Channel higher energy into productivity",
        "Practice assertive communication",
        "Use confidence boost for important conversations",
        "Balance social activities with alone time",
        "Be mindful of decision-making (may be more impulsive)"
      ],
      "activities": [
        "High-intensity interval training",
        "Team sports or group activities",
        "Public speaking or presentations",
        "Date nights or social gatherings",
        "Creative expression through art or music"
      ]
    },
    "Luteal": {
      "self_care": [
        "Increase calcium and magnesium intake",
        "Limit caffeine, sugar, and salt",
        "Warm herbal teas (chamomile, ginger)",
        "Extra sleep and rest periods",
        "Loose, comfortable clothing"
      ],
      "mental_health": [
        "Practice self-compassion",
        "Reduce external stressors when possible",
        "Create calm environments",
        "Schedule downtime in advance",
        "Avoid making major decisions if emotionally volatile"
      ],
      "activities": [
        "Pilates or barre workouts",
        "Swimming or water exercises",
        "Yin yoga or gentle stretching",
        "Walking in nature",
        "Cooking or baking comfort foods"
      ]
    }
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phase selection bar
            Container(
              height: 100,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: PhaseSelectionBar(
                phases: phaseColors.keys.toList(),
                phaseColors: phaseColors,
                selectedPhase: _selectedPhase,
                onPhaseSelected: (phase) {
                  setState(() {
                    _selectedPhase = phase;
                  });
                },
              ),
            ),

            // Current phase title
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Your $_selectedPhase Phase",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: phaseColors[_selectedPhase],
                ),
              ),
            ),

            // Phase description
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: phaseColors[_selectedPhase]?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getPhaseDescription(_selectedPhase),
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            ),

            // Recommendations sections
            RecommendationSection(
              title: "Self-Care",
              icon: Icons.spa,
              color: phaseColors[_selectedPhase] ?? Colors.pink,
              recommendations:
                  phaseRecommendations[_selectedPhase]?["self_care"] ?? [],
            ),

            RecommendationSection(
              title: "Mental Health",
              icon: Icons.psychology,
              color: phaseColors[_selectedPhase] ?? Colors.pink,
              recommendations:
                  phaseRecommendations[_selectedPhase]?["mental_health"] ?? [],
            ),

            RecommendationSection(
              title: "Recommended Activities",
              icon: Icons.directions_run,
              color: phaseColors[_selectedPhase] ?? Colors.pink,
              recommendations:
                  phaseRecommendations[_selectedPhase]?["activities"] ?? [],
            ),

            SizedBox(height: 20),
          ],
        ),
      
      
    );
  }

  String getPhaseDescription(String phase) {
    switch (phase) {
      case "Period":
        return "During menstruation, your body sheds the uterine lining. Energy levels are typically at their lowest. It's a time for rest, reflection, and gentle movement. Focus on nurturing yourself and allowing for extra downtime.";
      case "Follicular":
        return "After your period ends, estrogen rises and you may notice increasing energy. This is a great time for starting new projects, being social, and pushing yourself physically. Your creativity and outgoing nature are heightened.";
      case "Ovulation":
        return "Estrogen peaks around ovulation, and testosterone rises briefly. You may feel at your most confident, energetic, and social. Communication skills are enhanced, making this an ideal time for important conversations or presentations.";
      case "Luteal":
        return "After ovulation, progesterone rises. Early luteal phase may still feel energetic, but as you get closer to your period, you might experience PMS symptoms. This is a time to start winding down, focus on completion rather than starting new things, and practice extra self-care.";
      default:
        return "";
    }
  }
}

// Horizontal phase selection bar with dots
class PhaseSelectionBar extends StatelessWidget {
  final List<String> phases;
  final Map<String, Color> phaseColors;
  final String selectedPhase;
  final Function(String) onPhaseSelected;

  const PhaseSelectionBar({
    required this.phases,
    required this.phaseColors,
    required this.selectedPhase,
    required this.onPhaseSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      child: Stack(
        children: [
          // Connecting line
          Positioned(
            top: 15,
            left: 65,
            right: 65,
            child: Container(
              height: 3,
              color: Colors.grey.shade300,
            ),
          ),

          // Phase dots and labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: phases.map((phase) {
              bool isSelected = phase == selectedPhase;
              Color phaseColor = phaseColors[phase] ?? Colors.grey;

              return GestureDetector(
                onTap: () => onPhaseSelected(phase),
                child: Container(
                  width: 80,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dot
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: isSelected ? 30 : 24,
                        width: isSelected ? 30 : 24,
                        decoration: BoxDecoration(
                          color: isSelected ? phaseColor : Colors.white,
                          border: Border.all(
                            color: phaseColor,
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: phaseColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Label
                      Text(
                        phase,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? phaseColor : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Recommendation section widget
class RecommendationSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> recommendations;

  const RecommendationSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.recommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(icon, color: color),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Recommendations list
          ...recommendations.map((recommendation) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6),
                    height: 8,
                    width: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Integration code to connect with your existing app
class CycleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cycle Wellness App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      routes: {
        '/': (context) => CycleDashboardScreen(),
        '/calendar': (context) => CycleCalendarScreen(),
      },
    );
  }
}

class CycleCalendarScreen extends StatefulWidget {
  @override
  _CycleCalendarScreenState createState() => _CycleCalendarScreenState();
}

class _CycleCalendarScreenState extends State<CycleCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime _lastPeriodStartDate = DateTime.now(); // Default to today
  Map<DateTime, String> _cyclePhases = {};
  bool _hasSetPeriodDate = false;

  // Define colors for each phase
  final Map<String, Color> phaseColors = {
    "Period": const Color.fromARGB(255, 236, 111, 153),
    "Follicular": const Color.fromARGB(249, 181, 101, 210),
    "Ovulation": const Color.fromARGB(255, 112, 115, 207),
    "Luteal": const Color.fromARGB(255, 255, 185, 79),
  };

  // Cycle parameters that could also be made configurable
  int cycleLength = 28;
  int periodLength = 5;
  int follicularLength = 9; // Days 6-14 (after period)
  int ovulationLength = 3; // Days 14-16

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay; // Set today as the initially selected day

    // We'll prompt for the date rather than generating phases immediately
    // If we want to show something by default, we could do:
    // _generateCyclePhases(_lastPeriodStartDate);
  }

  void _generateCyclePhases(DateTime startDate) {
    // Clear existing phases first
    _cyclePhases.clear();

    for (int i = 0; i < 6; i++) {
      // Generate for multiple cycles (increased from 3 to 6)
      DateTime cycleStart = startDate.add(Duration(days: i * cycleLength));

      // Period phase (Days 1-5)
      for (int j = 0; j < periodLength; j++) {
        DateTime day =
            DateTime(cycleStart.year, cycleStart.month, cycleStart.day + j);
        _cyclePhases[day] = "Period";
      }

      // Follicular phase (Days 6-14)
      for (int j = periodLength; j < 14; j++) {
        DateTime day =
            DateTime(cycleStart.year, cycleStart.month, cycleStart.day + j);
        _cyclePhases[day] = "Follicular";
      }

      // Ovulation phase (Days 14-16)
      for (int j = 14; j < 17; j++) {
        DateTime day =
            DateTime(cycleStart.year, cycleStart.month, cycleStart.day + j);
        _cyclePhases[day] = "Ovulation";
      }

      // Luteal phase (Days 17-28)
      for (int j = 17; j < cycleLength; j++) {
        DateTime day =
            DateTime(cycleStart.year, cycleStart.month, cycleStart.day + j);
        _cyclePhases[day] = "Luteal";
      }
    }
  }

  // Get the current phase based on selected day
  String getCurrentPhase() {
    if (_selectedDay == null) return "Unknown";
    // if (!_hasSetPeriodDate) return "Set your last period date to see phase";

    // Create a date without time for comparison
    DateTime compareDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    return _cyclePhases[compareDate] ?? "Not in tracked cycle";
  }

  // Get next period start date
  DateTime getNextPeriodDate() {
    // Find the most recent period start before today
    DateTime lastPeriodStart = _lastPeriodStartDate;
    while (lastPeriodStart
        .add(Duration(days: cycleLength))
        .isBefore(_focusedDay)) {
      lastPeriodStart = lastPeriodStart.add(Duration(days: cycleLength));
    }

    // Next period will be one cycle length after the last
    return lastPeriodStart.add(Duration(days: cycleLength));
  }

  // Calculate days until next period
  int getDaysUntilNextPeriod() {
    DateTime nextPeriod = getNextPeriodDate();
    return nextPeriod.difference(_focusedDay).inDays;
  }

  // Get phase description
  String getPhaseDescription(String phase) {
    switch (phase) {
      case "Period":
        return "Menstruation: Your body sheds the uterine lining. You may experience cramps, fatigue, and mood changes.";
      case "Follicular":
        return "Follicular phase: Follicles in your ovaries develop, and estrogen levels rise. Energy levels typically increase during this time.";
      case "Ovulation":
        return "Ovulation: An egg is released from the ovary. You may notice increased energy, heightened senses, and changes in cervical fluid.";
      case "Luteal":
        return "Luteal phase: The body prepares for possible pregnancy. You may experience PMS symptoms like bloating, mood changes, or breast tenderness.";
      default:
        return "";
    }
  }

  // Show date picker to select last period start date
  Future<void> _selectLastPeriodDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodStartDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      helpText: 'SELECT YOUR LAST PERIOD START DATE',
    );

    if (picked != null && picked != _lastPeriodStartDate) {
      setState(() {
        _lastPeriodStartDate = picked;
        _generateCyclePhases(_lastPeriodStartDate);
        _hasSetPeriodDate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentPhase = getCurrentPhase();

    return SingleChildScrollView(
        child: Column(
          children: [
            // Date selection button (only show if period date hasn't been set)
            if (!_hasSetPeriodDate)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        "Please set your last period start date to generate your cycle calendar",
                        style: GoogleFonts.poppins(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _selectLastPeriodDate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          child: Text("Set Last Period Date",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Once date is set, show the option to change it
            if (_hasSetPeriodDate)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: Icon(Icons.edit, size: 16),
                      label: Text("Change period date"),
                      onPressed: _selectLastPeriodDate,
                    ),
                  ],
                ),
              ),

            TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.5),
                    shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(
                    color: Colors.deepPurple, shape: BoxShape.circle),
                weekendTextStyle: TextStyle(color: Colors.red),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, _) {
                  // Create a date without time for comparison
                  DateTime compareDate = DateTime(
                    date.year,
                    date.month,
                    date.day,
                  );

                  String? phase = _cyclePhases[compareDate];
                  if (phase != null) {
                    return Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: phaseColors[phase],
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(6),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),

            // Current phase information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: phaseColors[currentPhase] ?? Colors.grey,
                      width: 2),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 16,
                          width: 16,
                          decoration: BoxDecoration(
                            color: phaseColors[currentPhase] ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text("Current Phase: \n${currentPhase}",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: phaseColors[currentPhase] ?? Colors.black,
                            )),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(getPhaseDescription(currentPhase)),
                    Divider(height: 24),
                    if (_hasSetPeriodDate) ...[
                      Text("Cycle Information:",
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(
                          "Last period started: ${DateFormat.yMMMd().format(_lastPeriodStartDate)}"),
                      Text("Period length: $periodLength days"),
                      Text("Cycle length: $cycleLength days"),
                      Text(
                        "Next period expected: ${DateFormat.yMMMd().format(getNextPeriodDate())} (in ${getDaysUntilNextPeriod()} days)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 10),
            

            // Phase color legend
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phase Legend:",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: phaseColors.entries.map((entry) {
                      return Row(
                        children: [
                          Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(entry.key),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      
    );
  }
}