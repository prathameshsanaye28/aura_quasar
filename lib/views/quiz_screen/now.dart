import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class EmotionTrackerScreen extends StatefulWidget {
  @override
  _EmotionTrackerScreenState createState() => _EmotionTrackerScreenState();
}

class _EmotionTrackerScreenState extends State<EmotionTrackerScreen> {
  final TextEditingController _thoughtsController = TextEditingController();
  bool _isLoading = false;
  String _currentEmotion = "";
  List<Map<String, dynamic>> _emotionHistory = [];
  bool _useMockApi = false; // Set to false when you have a working API key

  // Replace with your actual Gemini API key
  final String _apiKey = "AIzaSyBMc0wdwqUWEcdipHkbRQPW9d7Q1Enu7Tg";
  
  // Updated correct URL for Gemini API
  final String _geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBMc0wdwqUWEcdipHkbRQPW9d7Q1Enu7Tg";
  
  @override
  void initState() {
    super.initState();
    _loadEmotionHistory();
  }

  Future<void> _loadEmotionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('emotion_history');
    
    if (historyJson != null) {
      setState(() {
        _emotionHistory = List<Map<String, dynamic>>.from(
          jsonDecode(historyJson).map((item) => Map<String, dynamic>.from(item))
        );
      });
    }
  }

  Future<void> _saveEmotionHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emotion_history', jsonEncode(_emotionHistory));
  }

  // Mock function that simulates AI analysis
  String _mockEmotionAnalysis(String text) {
    final validEmotions = ['Happy', 'Sad', 'Excited'];
    
    // Simple keyword-based analysis
    text = text.toLowerCase();
    if (text.contains('happy') || 
        text.contains('joy') || 
        text.contains('good') || 
        text.contains('great')) {
      return 'Happy';
    } else if (text.contains('sad') || 
              text.contains('depressed') || 
              text.contains('upset') || 
              text.contains('unhappy')) {
      return 'Sad';
    } else if (text.contains('excited') || 
              text.contains('thrilled') || 
              text.contains('amazing') || 
              text.contains('fantastic')) {
      return 'Excited';
    }
    
    // If no keywords match, randomly select an emotion with some bias
    // based on text sentiment heuristics
    final random = Random();
    int sentimentScore = 0;
    
    // Very simple sentiment analysis
    final positiveWords = ['love', 'like', 'wonderful', 'fun', 'enjoy', 'pleased'];
    final negativeWords = ['hate', 'dislike', 'terrible', 'awful', 'annoyed', 'frustrated'];
    
    for (var word in positiveWords) {
      if (text.contains(word)) sentimentScore += 1;
    }
    
    for (var word in negativeWords) {
      if (text.contains(word)) sentimentScore -= 1;
    }
    
    if (sentimentScore > 0) {
      return random.nextDouble() > 0.3 ? 'Happy' : 'Excited';
    } else if (sentimentScore < 0) {
      return 'Sad';
    } else {
      // If no clear sentiment, truly random
      return validEmotions[random.nextInt(validEmotions.length)];
    }
  }

  Future<String> _analyzeEmotionWithGemini(String text) async {
    // Use mock analysis if setting is enabled
    if (_useMockApi) {
      // Add artificial delay to simulate API call
      await Future.delayed(Duration(milliseconds: 800));
      return _mockEmotionAnalysis(text);
    }
    
    try {
      final url = Uri.parse("$_geminiUrl");
      
      // Create the prompt to restrict the response to our three emotions
      final prompt = """
      Based on the following text, classify the emotion strictly as one of: Happy, Sad, or Excited.
      Choose the single most appropriate emotion from these three options only.
      Just respond with a single word (Happy, Sad, or Excited). No explanation or additional text.
      
      Text: "$text"
      """;
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "text": prompt
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.0,
            "maxOutputTokens": 5,
            "topP": 1,
            "topK": 1
          }
        }),
      );
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        
        // Extract just the text response from Gemini
        String geminiResponse = jsonResponse['candidates'][0]['content']['parts'][0]['text'];
        
        // Clean and validate the response
        geminiResponse = geminiResponse.trim();
        
        // Validate that we only get one of our acceptable emotions
        final validEmotions = ['Happy', 'Sad', 'Excited'];
        
        for (var emotion in validEmotions) {
          if (geminiResponse.contains(emotion)) {
            return emotion;
          }
        }
        
        // Default to 'Happy' if the response doesn't match our expected values
        return 'Happy';
      } else {
        print('API Error: ${response.statusCode}, ${response.body}');
        throw Exception('Failed to analyze emotion: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception during API call: $e');
      // Fallback to mock analysis if API fails
      return "fail";
    }
  }

  Future<void> _submitThoughts() async {
    if (_thoughtsController.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final emotion = await _analyzeEmotionWithGemini(_thoughtsController.text);
      
      final entry = {
        'date': DateTime.now().toIso8601String(),
        'text': _thoughtsController.text,
        'emotion': emotion,
      };
      
      setState(() {
        _currentEmotion = emotion;
        _emotionHistory.insert(0, entry);
        _isLoading = false;
      });
      
      await _saveEmotionHistory();
      _thoughtsController.clear();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error analyzing emotions: $e'))
      );
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'Happy':
        return Colors.yellow;
      case 'Sad':
        return Colors.blue;
      case 'Excited':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEmotionIcon(String emotion) {
    switch (emotion) {
      case 'Happy':
        return Icons.sentiment_satisfied_alt;
      case 'Sad':
        return Icons.sentiment_dissatisfied;
      case 'Excited':
        return Icons.celebration;
      default:
        return Icons.sentiment_neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emotion Tracker'),
        backgroundColor: _currentEmotion.isNotEmpty 
            ? _getEmotionColor(_currentEmotion) 
            : Colors.purple,
        actions: [
          // Settings button to toggle between real and mock API
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('API Settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: Text('Use Mock API'),
                        subtitle: Text('Use simulated responses instead of real Gemini API'),
                        value: _useMockApi,
                        onChanged: (value) {
                          setState(() {
                            _useMockApi = value;
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Emotion Input Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'How are you feeling today?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _thoughtsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts or emotions...',
                    border: OutlineInputBorder(),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitThoughts,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Analyze My Emotion', style: TextStyle(fontSize: 16)),
                ),
                if (_useMockApi)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Using simulated emotion analysis',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Current Emotion Display
          if (_currentEmotion.isNotEmpty)
            Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getEmotionColor(_currentEmotion).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getEmotionColor(_currentEmotion)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getEmotionIcon(_currentEmotion),
                    color: _getEmotionColor(_currentEmotion),
                    size: 48,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Mood',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          _currentEmotion,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Divider
          Divider(thickness: 1),
          
          // History Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.history, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Emotion History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // History List
          Expanded(
            child: _emotionHistory.isEmpty
                ? Center(child: Text('No emotion history yet'))
                : ListView.builder(
                    itemCount: _emotionHistory.length,
                    itemBuilder: (context, index) {
                      final entry = _emotionHistory[index];
                      final date = DateTime.parse(entry['date']);
                      final formattedDate = '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
                      
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getEmotionColor(entry['emotion']),
                            child: Icon(
                              _getEmotionIcon(entry['emotion']),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            entry['emotion'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry['text'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Row(
                                  children: [
                                    Icon(
                                      _getEmotionIcon(entry['emotion']),
                                      color: _getEmotionColor(entry['emotion']),
                                    ),
                                    SizedBox(width: 8),
                                    Text(entry['emotion']),
                                  ],
                                ),
                                content: Text(entry['text']),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}