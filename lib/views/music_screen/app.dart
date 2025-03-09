import 'package:audioplayers/audioplayers.dart';
import 'package:aura_techwizard/models/music.dart';
import 'package:aura_techwizard/views/music_screen/home.dart';
import 'package:flutter/material.dart';

class MusicAppScreen extends StatefulWidget {
  const MusicAppScreen({Key? key}) : super(key: key);

  @override
  _MusicAppScreenState createState() => _MusicAppScreenState();
}

class _MusicAppScreenState extends State<MusicAppScreen> {
  AudioPlayer _audioPlayer = new AudioPlayer();
  var Tabs = [];
  int currentTabIndex = 0;
  bool isPlaying = false;
  Music? music;

  Widget miniPlayer(Music? music, {bool stop = false}) {
    this.music = music;

    if (music == null) {
      return SizedBox();
    }
    if (stop) {
      isPlaying = false;
      _audioPlayer.stop();
    }
    setState(() {});
    Size deviceSize = MediaQuery.of(context).size;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      color: const Color.fromARGB(255, 196, 218, 242),
      width: deviceSize.width,
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.network(music.image, fit: BoxFit.cover),
          Text(
            music.name,
            style: TextStyle(color: const Color(0xFF2E4052), fontSize: 20),
          ),
          IconButton(
              onPressed: () async {
                isPlaying = !isPlaying;
                if (isPlaying) {
                  await _audioPlayer.play(AssetSource(music.audioURL));
                } else {
                  await _audioPlayer.pause();
                }
                setState(() {});
              },
              icon: isPlaying
                  ? Icon(Icons.pause, color: const Color(0xFF2E4052))
                  : Icon(Icons.play_arrow, color: const Color(0xFF2E4052)))
        ],
      ),
    );
  }

  @override
  initState() {
    super.initState();
    Tabs = [Home(miniPlayer)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Music '),
        actions: [
          const SizedBox(width: 10),
        ],
      ),
      body: Tabs[currentTabIndex],
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          miniPlayer(music),
        ],
      ),
    );
  }
}
