import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

class SleepDisorderService {
  // Get the appropriate base URL depending on platform and environment
  static const String baseUrl='http://192.168.80.162:8000';

  Future<String> predictSleepDisorder({
    required String gender,
    required int age,
    required String occupation,
    required double sleepDuration,
    required int qualityOfSleep,
    required int physicalActivityLevel,
    required int stressLevel,
    required String bmiCategory,
    required String bloodPressure,
    required int heartRate,
    required int dailySteps,
  }) async {
    try {
      print('Making request to: ${baseUrl}/sleep_disorder'); 
      final response = await http.post(
        Uri.parse('$baseUrl/sleep_disorder'),
        headers: {'Content-Type': 'application/json','Accept': 'application/json',},
        body: jsonEncode({
          'Gender': gender,
          'Age': age,
          'Occupation': occupation,
          'Sleep Duration': sleepDuration,
          'Quality of Sleep': qualityOfSleep,
          'Physical Activity Level': physicalActivityLevel,
          'Stress Level': stressLevel,
          'BMI Category': bmiCategory,
          'Blood Pressure': bloodPressure,
          'Heart Rate': heartRate,
          'Daily Steps': dailySteps,
        }),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); 

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['prediction'];
        } else {
          throw Exception(data['error']);
        }
      } else {
        throw Exception('Failed to predict sleep disorder. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error details: $e'); // Debug log
      throw Exception('Error: $e');
    }
  }
}