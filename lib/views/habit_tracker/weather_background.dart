import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class WeatherBackground extends StatefulWidget {
  final String weatherCondition;

  const WeatherBackground({Key? key, required this.weatherCondition})
      : super(key: key);

  @override
  _WeatherBackgroundState createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground> {
  late RiveAnimationController _controller;
  Artboard? _artboard; // Make it nullable
  SMIBool? summer, autumn, spring, winter;

  @override
  void initState() {
    super.initState();
    _loadRiveAnimation();
  }

  /// Load Rive Animation
  Future<void> _loadRiveAnimation() async {
    try {
      final bytes = await DefaultAssetBundle.of(context)
          .load('assets/RiveAssets/4_seasons-3.riv');
      final riveFile = RiveFile.import(bytes);

      if (riveFile == null) {
        debugPrint("Error: Failed to load Rive file.");
        return;
      }

      final artboard = riveFile.mainArtboard;
      final controller =
          StateMachineController.fromArtboard(artboard, "State Machine 1");

      if (controller == null) {
        debugPrint("Error: Could not find state machine.");
        return;
      }

      artboard.addController(controller);
      _controller = controller;
      _artboard = artboard;

      // Assign weather state variables
      summer = controller.findInput<bool>("summertab") as SMIBool?;
      autumn = controller.findInput<bool>("autumntab") as SMIBool?;
      spring = controller.findInput<bool>("springtab") as SMIBool?;
      winter = controller.findInput<bool>("wintertab") as SMIBool?;

      if (summer == null ||
          autumn == null ||
          spring == null ||
          winter == null) {
        debugPrint("Error: Some inputs are missing in the Rive file.");
        return;
      }

      _setWeather(widget.weatherCondition);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error loading Rive animation: $e");
    }
  }

  /// Override `didUpdateWidget` to detect changes in weather condition
  @override
  void didUpdateWidget(covariant WeatherBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.weatherCondition != oldWidget.weatherCondition) {
      _setWeather(widget.weatherCondition);
    }
  }

  /// Function to update the Rive state machine when weather changes
  void _setWeather(String condition) {
    if (summer == null || autumn == null || spring == null || winter == null)
      return;

    summer!.value = condition == "summer";
    autumn!.value = condition == "autumn";
    spring!.value = condition == "spring";
    winter!.value = condition == "winter";

    debugPrint("Weather changed to: $condition");
  }

  @override
  Widget build(BuildContext context) {
    return _artboard == null
        ? const Center(child: CircularProgressIndicator())
        : Transform.scale(
            scale: 1.66, // Scale up by 66%
            child: Rive(artboard: _artboard!),
          );
  }
}
