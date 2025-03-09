// import 'package:aura_techwizard/services/mental_health_service.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:rive/rive.dart';

// class ChatBotScreen extends StatefulWidget {
//   @override
//   _ChatBotScreenState createState() => _ChatBotScreenState();
// }

// class _ChatBotScreenState extends State<ChatBotScreen> {
//   final TextEditingController _thoughtsController = TextEditingController();
//   bool _isLoading = false;
//   String _currentEmotion = "";
//   List<Map<String, dynamic>> _emotionHistory = [];
//   bool _useMockApi = false;

//   final String _geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBMc0wdwqUWEcdipHkbRQPW9d7Q1Enu7Tg";

//   SMIInput<double>? waveInput;
//   SMIInput<double>? happyInput;
//   SMIInput<double>? sadInput;
//   SMIInput<double>? excitedInput;
//   Artboard? riveArtboard;
//   double opacity = 1.0;

//   @override
//   void initState() {
//     super.initState();
//     loadRive();
//     _loadEmotionHistory();
//   }

//   void loadRive() async {
//     final data = await RiveFile.asset('assets/RiveAssets/penguin.riv');
//     final artboard = data.mainArtboard;
//     final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
//     if (controller != null) {
//       artboard.addController(controller);
//       waveInput = controller.findInput('wave');
//       happyInput = controller.findInput('warm');
//       sadInput = controller.findInput('sad');
//       excitedInput = controller.findInput('cool');
//     }
//     setState(() => riveArtboard = artboard);
//   }

//   Future<void> _loadEmotionHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? historyJson = prefs.getString('emotion_history');
//     if (historyJson != null) {
//       setState(() {
//         _emotionHistory = List<Map<String, dynamic>>.from(
//           jsonDecode(historyJson).map((item) => Map<String, dynamic>.from(item))
//         );
//       });
//     }
//   }

//   Future<void> _saveEmotionHistory() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('emotion_history', jsonEncode(_emotionHistory));
//   }

//   Future<String> _analyzeEmotionWithGemini(String text) async {
//     // if (_useMockApi) {
//     //   await Future.delayed(Duration(milliseconds: 800));
//     //   return 'Happy';
//     // }
//     try {
//       final url = Uri.parse(_geminiUrl);
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "contents": [{
//             "parts": [{"text": "Classify this text as Happy, Wave, Sad, or Excited, the result should only be one of these 4 words, give nothing else in the response, what you need to do is analyse the sentiment of the given text and then tell wether the given piece of text indicates happy, excited, wave or sad mood, nothing else, just when it is some form of salutation (some greeting, anything like that, if it is hi, hello, some form of greeting) give wave, just what mood the text indicates towards, anything negative should be sad: \"$text\""}]
//           }],
//           "generationConfig": {
//             "temperature": 0.0,
//             "maxOutputTokens": 5,
//             "topP": 1,
//             "topK": 1
//           }
//         }),
//       );
//       if (response.statusCode == 200) {
//         final jsonResponse = jsonDecode(response.body);
//         String geminiResponse = jsonResponse['candidates'][0]['content']['parts'][0]['text'].trim();
//         return ['Happy', 'Sad', 'Excited', 'Wave'].contains(geminiResponse) ? geminiResponse : 'Happy';
//       } else {
//         throw Exception('Failed to analyze emotion');
//       }
//     } catch (e) {
//       return 'Happy';
//     }
//   }

//   Future<void> _submitThoughts() async {
//     if (_thoughtsController.text.isEmpty) return;
//     setState(() => _isLoading = true);

//     try {
//       final emotion = await _analyzeEmotionWithGemini(_thoughtsController.text);
//       final entry = {'date': DateTime.now().toIso8601String(), 'text': _thoughtsController.text, 'emotion': emotion};
//       setState(() {
//         _currentEmotion = emotion;
//         _emotionHistory.insert(0, entry);
//         _isLoading = false;
//         _triggerEmotionAnimation(emotion);
//       });
//       await _saveEmotionHistory();
//       _thoughtsController.clear();
//     } catch (e) {
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error analyzing emotions: $e')));
//     }
//   }

//   void _triggerEmotionAnimation(String emotion) {
//     switch (emotion) {
//       case 'Happy':
//         happyInput?.value = 1;
//         break;
//       case 'Sad':
//         sadInput?.value = 1;
//         break;
//       case 'Excited':
//         excitedInput?.value = 1;
//         break;
//       case 'Wave':
//         waveInput?.value = 1;
//         break;
//     }
//     Future.delayed(Duration(seconds: 5), () {
//       setState(() {
//         happyInput?.value = 0;
//         sadInput?.value = 0;
//         excitedInput?.value = 0;
//         waveInput?.value = 0;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Emotion Tracker')),
//       body: SingleChildScrollView(
//         child: 
// //             SizedBox(
// //   height: 300, // Fixed height for the animation space
// //   child: Stack(
// //     alignment: Alignment.center,
// //     children: [
// //       SizedBox(
// //         width: 250, // Fixed width to prevent movement
// //         height: 290, // Fixed height to prevent shifting
// //         child: riveArtboard != null 
// //           ? Transform.scale(scale: 1.5, child: Rive(artboard: riveArtboard!))
// //           : CircularProgressIndicator(),
// //       ),
// //     ],
// //   ),
// // ),
// Column(
//   children: [
//     SizedBox(height: 220), // Keeps spacing before Rive fixed
//     Container( // This is now a locked area for Rive
//       height: 300,
//       width: double.infinity,
//       alignment: Alignment.center,
//       child: riveArtboard != null
//           ? SizedBox(
//               height: 290,
//               width: 250,
//               child: OverflowBox(
//                 maxHeight: 290,
//                 child: Transform.scale(scale: 1.5, child: Rive(artboard: riveArtboard!)),
//               ),
//             )
//           : CircularProgressIndicator(),
//     ),
//     SizedBox(height: 10),
//     Padding(
//       padding: EdgeInsets.symmetric(horizontal: 50),
//       child: TextField(
//         controller: _thoughtsController,
//         decoration: InputDecoration(
//           hintText: 'Type your thoughts...',
//           border: OutlineInputBorder(),
//           suffixIcon: IconButton(
//             icon: Icon(Icons.send),
//             onPressed: _isLoading ? null : _submitThoughts,
//           ),
//         ),
//       ),
//     ),
//     SizedBox(height: 10),
//   ],
// ),
//       ),
//     );
//   }
// }
import 'package:aura_techwizard/services/mental_health_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive/rive.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _thoughtsController = TextEditingController();
  bool _isLoading = false;
  String _currentEmotion = "";
  String _flaskResponse = "";
  List<Map<String, dynamic>> _emotionHistory = [];
  bool _useMockApi = false;

  final String _geminiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyBMc0wdwqUWEcdipHkbRQPW9d7Q1Enu7Tg";
  final String _flaskUrl = "http://192.168.80.162:8000/chat";

  SMIInput<double>? waveInput;
  SMIInput<double>? happyInput;
  SMIInput<double>? sadInput;
  SMIInput<double>? excitedInput;
  Artboard? riveArtboard;

  @override
  void initState() {
    super.initState();
    loadRive();
    _loadEmotionHistory();
  }

  void loadRive() async {
    final data = await RiveFile.asset('assets/RiveAssets/penguin.riv');
    final artboard = data.mainArtboard;
    final controller = StateMachineController.fromArtboard(artboard, 'State Machine 1');
    if (controller != null) {
      artboard.addController(controller);
      waveInput = controller.findInput('wave');
      happyInput = controller.findInput('warm');
      sadInput = controller.findInput('sad');
      excitedInput = controller.findInput('cool');
    }
    setState(() => riveArtboard = artboard);
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

  Future<String> _analyzeEmotionWithGemini(String text) async {
    try {
      final url = Uri.parse(_geminiUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{
            "parts": [{"text": "Classify this text as Happy, Wave, Sad, or Excited, the result should only be one of these 4 words, give nothing else in the response, what you need to do is analyse the sentiment of the given text and then tell wether the given piece of text indicates happy, excited, wave or sad mood, nothing else, just when it is some form of salutation (some greeting, anything like that, if it is hi, hello, some form of greeting) give wave, just what mood the text indicates towards, anything negative should be sad: \"$text\""}]
          }],
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
        String geminiResponse = jsonResponse['candidates'][0]['content']['parts'][0]['text'].trim();
        return ['Happy', 'Sad', 'Excited', 'Wave'].contains(geminiResponse) ? geminiResponse : 'Happy';
      } else {
        throw Exception('Failed to analyze emotion');
      }
    } catch (e) {
      return 'Happy';
    }
  }

  Future<void> _sendToFlask(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_flaskUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"message": text}),
        
      );
      print("sent");
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          _flaskResponse = jsonResponse['response'][1]['content'];
        });
      } else {
        setState(() => _flaskResponse = 'Error from server');
      }
    } catch (e) {
      setState(() => _flaskResponse = 'Failed to connect to server');
    }
  }

  Future<void> _submitThoughts() async {
    if (_thoughtsController.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final emotion = await _analyzeEmotionWithGemini(_thoughtsController.text);
      await _sendToFlask(_thoughtsController.text);
      final entry = {'date': DateTime.now().toIso8601String(), 'text': _thoughtsController.text, 'emotion': emotion};
      setState(() {
        _currentEmotion = emotion;
        _emotionHistory.insert(0, entry);
        _isLoading = false;
        _triggerEmotionAnimation(emotion);
      });
      await _saveEmotionHistory();
      _thoughtsController.clear();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error analyzing emotions: $e')));
    }
  }

  void _triggerEmotionAnimation(String emotion) {
    switch (emotion) {
      case 'Happy':
        happyInput?.value = 1;
        break;
      case 'Sad':
        sadInput?.value = 1;
        break;
      case 'Excited':
        excitedInput?.value = 1;
        break;
      case 'Wave':
        waveInput?.value = 1;
        break;
    }
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        happyInput?.value = 0;
        sadInput?.value = 0;
        excitedInput?.value = 0;
        waveInput?.value = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Emotion Tracker')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 250),
                Container(
                  height: 300,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: riveArtboard != null
                      ? SizedBox(height: 290, width: 250, child: 
                        Transform.scale(
            scale: 1.5, // Scale up by 66%
            child: Stack(
              children: [
               
                Rive(artboard: riveArtboard!),
                 Positioned(
                  top: 25,
                  left: 30,
                   child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 247, 219, 219),
                      borderRadius: BorderRadius.circular(50),
                    ),
                                   ),
                 ),
                Positioned(
                  top: 55,
                  left: 60,
                  child: Container(
                     width: 15,
                      height: 15,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 247, 219, 219),
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
          )

                      )
                      : CircularProgressIndicator(),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: TextField(
                    controller: _thoughtsController,
                    decoration: InputDecoration(
                      hintText: 'Type your thoughts...',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(icon: Icon(Icons.send), onPressed: _isLoading ? null : _submitThoughts),
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          Positioned(top: 20, right: 20, child: Container(
            padding: EdgeInsets.all(10),
              // color: const Color.fromARGB(255, 247, 219, 219),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 247, 219, 219),
              ),
            child: Container(
  width: MediaQuery.of(context).size.width * 0.8, 
  height: MediaQuery.of(context).size.height * 0.20,// 80% of screen width
  constraints: BoxConstraints(
    maxWidth: MediaQuery.of(context).size.width * 0.8,
    maxHeight: MediaQuery.of(context).size.height * 0.20,  // Ensure it doesn't exceed 80%
  ),
  child: SingleChildScrollView(
    child: Text(
      _flaskResponse,
      style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 1, 16, 28)),
      softWrap: true, // Ensures text wraps naturally
    ),
  ),
),),),
        ],
      ),
    );
  }
}
