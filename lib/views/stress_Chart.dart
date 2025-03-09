import 'dart:io';

import 'package:aura_techwizard/models/mental_health_tracking.dart';
import 'package:aura_techwizard/resources/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';


class StressChart extends StatefulWidget {
  const StressChart({super.key});

  @override
  State<StressChart> createState() => _StressChartState();
}

class _StressChartState extends State<StressChart> {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    List<MentalHealthTracking> _tracks = [];
    bool _isLoading = true;
    bool _generatingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

    Future<void> _loadUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.refreshUser();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _loadTracks(userProvider.getUser!.uid);
    }
  }

    Future<void> _loadTracks(String userId) async {
          print('hi0');
    final QuerySnapshot snapshot = await _firestore
        .collection('mental_health_tracking')
        .where('userId', isEqualTo: userId)
        //.orderBy('timestamp', descending: true)
        //.limit(7)
        .get();
        print(snapshot.docs.length);
        print('hi1');
    final tracks = snapshot.docs.map((doc) => MentalHealthTracking.fromDocument(doc)).toList();
        print('hi2');
        tracks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _tracks = tracks;
    });
    print('hi3');
    print(_tracks);
  }

    MentalHealthTracking? get latestTrack {
    return _tracks.isNotEmpty ? _tracks.first : null;
  }

    String getStressMessage(int score) {
    if (score < 8) {
      return "Low stress level. You're doing well at managing your stress. Keep practicing healthy habits.";
    } else if (score < 13) {
      return "Moderate stress level. Consider incorporating more stress-relief activities into your routine.";
    } else {
      return "High stress level. It's important to address these stress factors and consider seeking support.";
    }
  }

    Color getStressColor(int score) {
    if (score < 8) {
      return Colors.green;
    } else if (score < 13) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String getMetricAnalysis(String metric, dynamic value) {
    String message="";
    int numValue = 0;
    
    if (value is int) {
      numValue = value;
    } else if (value is double) {
      numValue = value.toInt();
    } else if (value is String && int.tryParse(value) != null) {
      numValue = int.parse(value);
    }

    if (metric == "App Switches") {
      if (numValue <= 2) {
        message = "Great job! You're maintaining focus and avoiding unnecessary distractions, which helps improve productivity and reduces stress.";
      } else if (numValue <= 5) {
        message = "You're switching between apps moderately. Try to limit distractions and focus on one task at a time to enhance concentration and efficiency.";
      } else {
        message = "Frequent app switching detected! This may indicate restlessness or difficulty focusing. Consider using techniques like the Pomodoro method to stay engaged.";
      }
    } else if (metric == "Typing Errors") {
      if (numValue < 5) {
        message = "Excellent! Your low typing error rate suggests strong focus and precision, which is a sign of reduced stress and better cognitive function.";
      } else if (numValue <= 10) {
        message = "You're making some errors while typing. This could be a sign of mild stress or fatigue. Taking short breaks and stretching might help refresh your mind.";
      } else {
        message = "High typing error rate detected! This could be a result of stress, exhaustion, or lack of focus. Try slowing down and ensuring you get adequate rest.";
      }
    } else if (metric == "Water Intake") {
      if (numValue < 3) {
        message = "Your water intake is quite low! Staying hydrated is essential for concentration, mood regulation, and overall well-being. Aim for at least 8 glasses a day.";
      } else if (numValue <= 6) {
        message = "You're drinking a moderate amount of water, which is good! However, increasing your intake slightly could improve your energy levels and help with stress management.";
      } else {
        message = "You're staying well-hydrated! Proper hydration is crucial for reducing stress, maintaining focus, and ensuring optimal body function. Keep it up!";
      }
    } else if (metric == "Sleep Quality") {
      if (numValue < 5) {
        message = "Your sleep quality seems poor. Inconsistent or inadequate sleep can increase stress and affect daily performance. Try establishing a relaxing bedtime routine to improve it.";
      } else if (numValue <= 7) {
        message = "Your sleep quality is moderate, which means there's room for improvement. Consider reducing screen time before bed and maintaining a consistent sleep schedule for better rest.";
      } else {
        message = "You're getting excellent sleep! Quality sleep is one of the most effective ways to lower stress levels, boost mood, and improve mental clarity.";
      }
    } else if (metric == "Panic Attack") {
      if (numValue > 0) {
        message = "It looks like you've experienced a panic attack. This can be overwhelming, and it may help to practice breathing exercises or talk to a professional for support.";
      } else {
        message = "No panic attacks recorded. That's great! Maintaining good mental health practices can help keep stress levels low and prevent future occurrences.";
      }
    } else if (metric == "Steps Count") {
      if (numValue < 2000) {
        message = "Your step count is quite low. Regular movement is essential for reducing stress and improving overall well-being. Try to incorporate short walks into your daily routine.";
      } else if (numValue <= 6000) {
        message = "You're engaging in a moderate level of physical activity, which is beneficial! Increasing your step count slightly could further enhance your mood and energy levels.";
      } else {
        message = "Fantastic! Your high step count indicates an active lifestyle, which is excellent for managing stress, boosting mental health, and staying physically fit.";
      }
    } else if (metric == "Quiz Score") {
      if (numValue > 35) {
        message = "A low quiz score might indicate difficulty concentrating due to stress or fatigue. Try relaxation techniques like deep breathing or mindfulness exercises to improve focus.";
      } else if (numValue > 20) {
        message = "Your quiz score is moderate. While you're managing okay, small lifestyle changes like proper sleep and stress management techniques can help boost mental clarity.";
      } else {
        message = "Amazing! A high quiz score suggests strong cognitive function, good memory retention, and minimal stress interference. Keep up the great mental health habits!";
      }
      
    }
    return message;
  }

void _showInfoDialog(String metric, dynamic value, BuildContext context) {
    String message = getMetricAnalysis(metric, value);
    

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(metric),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }



 Widget buildLineChart() {
    if (_tracks.isEmpty) {
      return const Center(child: Text("No data available"));
    }
    
    return SizedBox(
      height: 250, // Fixed height for the chart
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: const Text(
                'Stress Score',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              axisNameSize: 20,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
                interval: 5,
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text(
                'Date',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              axisNameSize: 20,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= _tracks.length) {
                    return const SizedBox.shrink();
                  }
                  String formattedDate = DateFormat('dd/MM').format(
                      _tracks[index].timestamp.toDate());
                  return Text(formattedDate,
                      style: const TextStyle(fontSize: 12));
                },
              ),
            ),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: _tracks.asMap().entries.map((entry) {
                int index = entry.key;
                MentalHealthTracking track = entry.value;
                return FlSpot(index.toDouble(), track.getScore().toDouble());
              }).toList(),
              isCurved: true,
              gradient: const LinearGradient(
                colors: [Color.fromARGB(255, 100, 197, 99), Color.fromARGB(255, 28, 92, 21)],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: false,
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

   Widget buildMetricTile(String metric, dynamic value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.2),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      metric,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showInfoDialog(metric, value, context),
                    child: const Icon(Icons.info_outline, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMetricsGrid() {
    if (latestTrack == null) return const SizedBox.shrink();
    
    final track = latestTrack!;
    
    // Define colors for each metric
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
      Colors.pink,
      Colors.green,
    ];

    return Column(
      children: [
        Row(
          children: [
            buildMetricTile("App Switches", track.app_switches, colors[0]),
            buildMetricTile("Typing Errors", track.typing_errors, colors[1]),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            buildMetricTile("Water Intake", track.water_intake, colors[2]),
            buildMetricTile("Sleep Quality", track.sleep_quality, colors[3]),
          ],
        ),
        const SizedBox(height: 8),
                Row(
          children: [
            buildMetricTile("Panic Attack", track.panic_attack, colors[4]),
            buildMetricTile("Steps Count", track.steps_walked, colors[5]),
          ],
        ),
        const SizedBox(height: 8,width:8),
        Row(
          children: [
            buildMetricTile("Quiz Score", track.quiz_score, colors[6]),
            // Add more metrics if needed or leave some space
            Expanded(child: Container()),
            Expanded(child: Container()),
          ],
        ),
      ],
    );
  }

    Widget buildLatestScoreSection() {
    if (latestTrack == null) return const SizedBox.shrink();
    
    final score = latestTrack!.getScore();
    final color = getStressColor(score);
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Your Current Stress Score:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                score.toString(),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            getStressMessage(score),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            "Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(latestTrack!.timestamp.toDate())}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

Future<void> _generatePdf() async {
    if (latestTrack == null || _tracks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to generate PDF')),
      );
      return;
    }

    setState(() {
      _generatingPdf = true;
    });

    try {
      // Create a PDF document
      final pdf = pw.Document();
      final track = latestTrack!;
      //print("Track Data: ${track.toJson()}");
      final score = track.getScore();
      
      
     
      pdf.addPage(
  pw.Page(
    build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Title
          pw.Center(
            child: pw.Text(
              'Stress Analysis Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Date
          pw.Text(
            'Generated on: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
            style: pw.TextStyle(
              fontSize: 12,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Current Stress Score
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Current Stress Score:',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      score.toString(),
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  getStressMessage(score),
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Health Metrics
          pw.Text(
            'Your Health Metrics',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),

          // First 4 Metrics Table
          pw.Table(
              // columnWidths: {
              //   0: const pw.FlexColumnWidth(2), // Metric column width doubled
              //   1: const pw.FlexColumnWidth(2), // Value column width tripled
              //   2: const pw.FlexColumnWidth(0.5), // Analysis column remains the same
              // },
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Metric',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Value',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Analysis',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('App Switches')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(track.app_switches.toString())),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(getMetricAnalysis('App Switches', track.app_switches))),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Typing Errors')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(track.typing_errors.toString())),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(getMetricAnalysis('Typing Errors', track.typing_errors))),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Water Intake')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(track.water_intake.toString())),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(getMetricAnalysis('Water Intake', track.water_intake))),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Sleep Quality')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(track.sleep_quality.toString())),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(getMetricAnalysis('Sleep Quality', track.sleep_quality))),
                ],
              ),
            ],
          ),
        ],
      );
    },
  ),
);

// Second Page
pdf.addPage(
  pw.Page(
    build: (pw.Context context) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Your Health Metrics',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),

          // Remaining 3 Metrics Table
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Metric',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Value',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      'Analysis',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Panic Attack')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(track.panic_attack.toString())),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(getMetricAnalysis('Panic Attack', track.panic_attack))),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Steps Count')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(track.steps_walked.toString())),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(getMetricAnalysis('Steps Count', track.steps_walked))),
                ],
              ),
              pw.TableRow(
                children: [
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Quiz Score')),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(track.quiz_score.toString())),
                  pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(getMetricAnalysis('Quiz Score', track.quiz_score))),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          
          pw.Text(
            'Note: This report is generated based on your tracked health metrics. It is intended for personal reference only.',
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(track.timestamp.toDate())}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      );
    },
  ),
);



      


  Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    } finally {
      setState(() {
        _generatingPdf = false;
      });
    }
  }



@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Stress Analysis"),
        actions: [
          _generatingPdf 
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Download PDF"),
                    onPressed: _isLoading || _tracks.isEmpty ? null : _generatePdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
        ],
      ),
      backgroundColor: const Color.fromARGB(223, 245, 235, 235),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: buildLineChart(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (latestTrack != null) buildLatestScoreSection(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          "Your Health Metrics",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (latestTrack != null) buildMetricsGrid(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
  
