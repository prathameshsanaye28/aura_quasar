

import 'package:flutter/material.dart';
import 'package:aura_techwizard/services/sleep_disorder_service.dart';

class SleepPredictionScreen extends StatefulWidget {
  @override
  _SleepPredictionScreenState createState() => _SleepPredictionScreenState();
}

class _SleepPredictionScreenState extends State<SleepPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = SleepDisorderService();
  String? _prediction;
  bool _isLoading = false;

  // Form controllers
  final _ageController = TextEditingController();
  final _sleepDurationController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _dailyStepsController = TextEditingController();
  final _bloodPressureController = TextEditingController();

  // Dropdown values
  String _selectedGender = 'Male';
  String _selectedOccupation = 'Engineer';
  String _selectedBMI = 'Normal';
  
  // Slider values
  double _qualityOfSleep = 5;
  double _physicalActivityLevel = 50;
  double _stressLevel = 5;

  // Dropdown options
  final List<String> _genders = ['Male', 'Female'];
  final List<String> _occupations = [
    'Accountant','Doctor','Engineer','Lawyer','Manager','Nurse','Salesperson','Scientist','Software Engineer','Teacher'
  ];
  final List<String> _bmiCategories = [
    'Normal', 'Overweight', 'Obese'
  ];

  Future<void> _predict() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final prediction = await _service.predictSleepDisorder(
          gender: _selectedGender,
          age: int.parse(_ageController.text),
          occupation: _selectedOccupation,
          sleepDuration: double.parse(_sleepDurationController.text),
          qualityOfSleep: _qualityOfSleep.round(),
          physicalActivityLevel: _physicalActivityLevel.round(),
          stressLevel: _stressLevel.round(),
          bmiCategory: _selectedBMI,
          bloodPressure: _bloodPressureController.text,
          heartRate: int.parse(_heartRateController.text),
          dailySteps: int.parse(_dailyStepsController.text),
        );

        setState(() {
          _prediction = prediction;
          _isLoading = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sleep Disorder Prediction')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown for Gender
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: _genders.map((String gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() => _selectedGender = value!);
                },
              ),
              SizedBox(height: 16),

              // Text input for Age
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Dropdown for Occupation
              DropdownButtonFormField<String>(
                value: _selectedOccupation,
                decoration: InputDecoration(labelText: 'Occupation'),
                items: _occupations.map((String occupation) {
                  return DropdownMenuItem(
                    value: occupation,
                    child: Text(occupation),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() => _selectedOccupation = value!);
                },
              ),
              SizedBox(height: 16),

              // Text input for Sleep Duration
              TextFormField(
                controller: _sleepDurationController,
                decoration: InputDecoration(
                  labelText: 'Sleep Duration (hours)',
                  hintText: 'Enter hours (e.g., 7.5)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sleep duration';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Slider for Quality of Sleep
              Text('Quality of Sleep (1-10)'),
              Slider(
                value: _qualityOfSleep,
                min: 1,
                max: 10,
                divisions: 9,
                label: _qualityOfSleep.round().toString(),
                onChanged: (value) {
                  setState(() => _qualityOfSleep = value);
                },
              ),
              SizedBox(height: 16),

              // Slider for Physical Activity Level
              Text('Physical Activity Level (0-100)'),
              Slider(
                value: _physicalActivityLevel,
                min: 0,
                max: 100,
                divisions: 20,
                label: _physicalActivityLevel.round().toString(),
                onChanged: (value) {
                  setState(() => _physicalActivityLevel = value);
                },
              ),
              SizedBox(height: 16),

              // Slider for Stress Level
              Text('Stress Level (1-10)'),
              Slider(
                value: _stressLevel,
                min: 1,
                max: 10,
                divisions: 9,
                label: _stressLevel.round().toString(),
                onChanged: (value) {
                  setState(() => _stressLevel = value);
                },
              ),
              SizedBox(height: 16),

              // Dropdown for BMI Category
              DropdownButtonFormField<String>(
                value: _selectedBMI,
                decoration: InputDecoration(labelText: 'BMI Category'),
                items: _bmiCategories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() => _selectedBMI = value!);
                },
              ),
              SizedBox(height: 16),

              // Text input for Blood Pressure
              TextFormField(
                controller: _bloodPressureController,
                decoration: InputDecoration(
                  labelText: 'Blood Pressure',
                  hintText: 'Format: 120/80',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter blood pressure';
                  }
                  if (!RegExp(r'^\d{2,3}\/\d{2,3}$').hasMatch(value)) {
                    return 'Please use format: 120/80';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Text input for Heart Rate
              TextFormField(
                controller: _heartRateController,
                decoration: InputDecoration(
                  labelText: 'Heart Rate (bpm)',
                  hintText: 'Enter beats per minute',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter heart rate';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Text input for Daily Steps
              TextFormField(
                controller: _dailyStepsController,
                decoration: InputDecoration(
                  labelText: 'Daily Steps',
                  hintText: 'Enter number of steps',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter daily steps';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Predict Button and Result
              Center(
                child: Column(
                  children: [
                    if (_isLoading)
                      CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _predict,
                        child: Text('Predict Sleep Disorder'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    
                    if (_prediction != null)
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Predicted Sleep Disorder: $_prediction',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _sleepDurationController.dispose();
    _heartRateController.dispose();
    _dailyStepsController.dispose();
    _bloodPressureController.dispose();
    super.dispose();
  }
}