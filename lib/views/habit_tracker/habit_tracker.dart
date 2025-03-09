import 'package:aura_techwizard/views/habit_tracker/weather_background.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

// class HabitTrackerScreen extends StatefulWidget {
//   @override
//   _HabitTrackerScreenState createState() => _HabitTrackerScreenState();
// }

// class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
//   rive.Artboard? _riveArtboard;
//   rive.StateMachineController? _riveController;

//   /// Maps to store inputs for each layer
//   final List<Map<int, rive.SMIInput<bool>?>> _displayHouseLayers = [];
//   final List<Map<int, rive.SMIInput<double>?>> _houseValueLayers = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadRiveAnimation();
//   }

//   Future<void> _loadRiveAnimation() async {
//     final data = await rootBundle.load('assets/riv_assets/growing_houses.riv');
//     await rive.RiveFile.initialize();
//     final file = rive.RiveFile.import(data);

//     final artboard = file.mainArtboard;
//     _riveController = rive.StateMachineController.fromArtboard(
//       artboard,
//       'State Machine 1', // Ensure the name matches your Rive State Machine
//     );

//     if (_riveController != null) {
//       artboard.addController(_riveController!);

//       // ✅ Initialize empty maps for each of the 7 layers
//       for (int layer = 0; layer < 7; layer++) {
//         _displayHouseLayers.add({});
//         _houseValueLayers.add({});
//       }

//       // ✅ Find inputs for each house in each layer
//       for (int layer = 0; layer < 7; layer++) {
//         for (int house = 1; house <= 6; house++) {
//           String displayHouseKey = 'Layer ${layer + 1} - Display House $house';
//           String houseValueKey = 'Layer ${layer + 1} - House $house';

//           _displayHouseLayers[layer][house] =
//               _riveController!.findInput<bool>(displayHouseKey);
//           _houseValueLayers[layer][house] =
//               _riveController!.findInput<double>(houseValueKey);

//           // ✅ Ensure all houses start hidden
//           _displayHouseLayers[layer][house]?.change(false);
//           _houseValueLayers[layer][house]?.change(0);
//         }
//       }

//       setState(() {
//         _riveArtboard = artboard;
//       });

//       print("✅ Rive state machine with 7 layers loaded successfully!");
//     }
//   }

//   /// Function to add a habit and trigger a house in a specific layer
//   void addHabit(int layerNumber, int houseNumber) {
//     if (layerNumber < 1 || layerNumber > 7) {
//       print("❌ Invalid layer number: $layerNumber");
//       return;
//     }
//     if (houseNumber < 1 || houseNumber > 6) {
//       print("❌ Invalid house number: $houseNumber");
//       return;
//     }

//     int layerIndex = layerNumber - 1;

//     if (_displayHouseLayers[layerIndex][houseNumber] != null &&
//         _houseValueLayers[layerIndex][houseNumber] != null) {
//       print(
//           "🔹 Adding habit, revealing House $houseNumber in Layer $layerNumber");

//       // ✅ Make the house appear
//       _displayHouseLayers[layerIndex][houseNumber]!.change(true);

//       // ✅ Increase house growth (example: 30% for testing)
//       _houseValueLayers[layerIndex][houseNumber]!.change(30);

//       setState(() {});
//     } else {
//       print(
//           "❌ Error: House $houseNumber in Layer $layerNumber not found in Rive!");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Habit Tracker')),
//       body: Column(
//         children: [
//           Expanded(
//             child: _riveArtboard == null
//                 ? Center(child: CircularProgressIndicator())
//                 : rive.Rive(artboard: _riveArtboard!),
//           ),
//           ElevatedButton(
//             onPressed: () => addHabit(2, 2), // Testing Layer 3, House 2
//             child: Text("Add Habit (Layer 3, House 2)"),
//           ),
//         ],
//       ),
//     );
//   }
// }

class Habit {
  String name;
  int streak;

  Habit({required this.name, this.streak = 0});
}

class RiveHouseTest extends StatefulWidget {
  const RiveHouseTest({super.key});

  @override
  State<RiveHouseTest> createState() => _RiveHouseTestState();
}

class _RiveHouseTestState extends State<RiveHouseTest> {
  late rive.RiveAnimationController _controller;
  late rive.SMIBool displayHouse2,
      displayHouse3,
      displayHouse4,
      displayHouse5,
      displayHouse6;
  late rive.SMINumber house2Value,
      house3Value,
      house4Value,
      house5Value,
      house6Value;

  List<Habit> habits = []; // List of habits

  void _onRiveInit(rive.Artboard artboard) {
    final controller =
        rive.StateMachineController.fromArtboard(artboard, "State Machine 1");
    if (controller == null) return;

    artboard.addController(controller);

    // Debugging: Print all available inputs in the Rive state machine
    for (var input in controller.inputs) {
      print("Input found: ${input.name} - Type: ${input.runtimeType}");
    }

    // Assign house display inputs
    displayHouse2 =
        controller.findInput<bool>("Display House 2") as rive.SMIBool;
    displayHouse3 =
        controller.findInput<bool>("Display House 3") as rive.SMIBool;
    displayHouse4 =
        controller.findInput<bool>("Display House 4") as rive.SMIBool;
    displayHouse5 =
        controller.findInput<bool>("Display House 5") as rive.SMIBool;
    displayHouse6 =
        controller.findInput<bool>("Display House 6") as rive.SMIBool;

    // Assign house integer values (fixing the error)
    house2Value = controller.findInput<double>("House 2") as rive.SMINumber;
    house3Value = controller.findInput<double>("House 3") as rive.SMINumber;
    house4Value = controller.findInput<double>("House 4") as rive.SMINumber;
    house5Value = controller.findInput<double>("House 5") as rive.SMINumber;
    house6Value = controller.findInput<double>("House 6") as rive.SMINumber;

    // Initialize all houses as hidden
    displayHouse2.value = false;
    displayHouse3.value = false;
    displayHouse4.value = false;
    displayHouse5.value = false;
    displayHouse6.value = false;
  }

  void _addHabit(String habitName) {
    if (habits.length >= 5) return; // Max 5 habits

    setState(() {
      habits.add(Habit(name: habitName));

      // Enable the corresponding house
      switch (habits.length) {
        case 1:
          displayHouse2.value = true;
          break;
        case 2:
          displayHouse3.value = true;
          break;
        case 3:
          displayHouse4.value = true;
          break;
        case 4:
          displayHouse5.value = true;
          break;
        case 5:
          displayHouse6.value = true;
          break;
      }
    });
  }

  void _incrementHabit(int index) {
    setState(() {
      habits[index].streak++; // Increase streak count

      // Increase respective House value by 17
      switch (index) {
        case 0:
          house2Value.value += 17;
          break;
        case 1:
          house3Value.value += 17;
          break;
        case 2:
          house4Value.value += 17;
          break;
        case 3:
          house5Value.value += 17;
          break;
        case 4:
          house6Value.value += 17;
          break;
      }
    });
  }

  void _decrementHabit(int index) {
    setState(() {
      habits[index].streak--; // Increase streak count

      // Increase respective House value by 17
      switch (index) {
        case 0:
          house2Value.value -= 17;
          break;
        case 1:
          house3Value.value -= 17;
          break;
        case 2:
          house4Value.value -= 17;
          break;
        case 3:
          house5Value.value -= 17;
          break;
        case 4:
          house6Value.value -= 17;
          break;
      }
    });
  }

  void _showAddHabitDialog() {
    TextEditingController habitController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Habit"),
          content: TextField(
            controller: habitController,
            decoration: const InputDecoration(hintText: "Enter habit name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (habitController.text.isNotEmpty) {
                  _addHabit(habitController.text);
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  String _selectedWeather = "spring";

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          height: 1000,
          child: WeatherBackground(weatherCondition: _selectedWeather),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 255, 231, 237),
            title: const Text("Habit Tracker"),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButton<String>(
                  value: _selectedWeather,
                  dropdownColor: Colors.white,
                  icon: const Icon(Icons.cloud, color: Colors.white),
                  underline: Container(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedWeather = newValue;
                      });
                    }
                  },
                  items: ["summer", "spring", "autumn", "winter"]
                      .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                          value: value,
                          child:
                              Text(value[0].toUpperCase() + value.substring(1)),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: rive.RiveAnimation.asset(
                  "assets/RiveAssets/growing_houses.riv",
                  fit: BoxFit.contain,
                  onInit: _onRiveInit,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: ListTile(
                        title: Text(habits[index].name),
                        subtitle: Text("Streak: ${habits[index].streak} days"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Ensures the row takes minimal space
                          children: [
                            IconButton(
                              icon: const Icon(Icons
                                  .remove), // Changed to a more appropriate icon
                              onPressed: () => _decrementHabit(index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _incrementHabit(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showAddHabitDialog,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
