import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../models/music.dart';
import '../../services/category_operations.dart';
import '../../services/music_operations.dart';

class Home extends StatelessWidget {
  Function _miniPlayer;
  Home(this._miniPlayer); // Dart Constructor ShortHand
  // const Home({Key? key}) : super(key: key);
  Widget createCategory(Category category) {
    return Container(
        color: const Color.fromARGB(255, 211, 212, 241),
        child: Row(
          children: [
            SizedBox(width: 4),
            Image.network(
              category.imageURL,
              fit: BoxFit.cover,
              width: 65,
              height: 65,
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                category.name,
                style: TextStyle(color: const Color(0xFF2E4052)),
              ),
            )
          ],
        ));
  }

  List<Widget> createListOfCategories() {
    List<Category> categoryList =
        CategoryOperations.getCategories(); // Rec Data
    // Convert Data to Widget Using map function
    List<Widget> categories = categoryList
        .map((Category category) => createCategory(category))
        .toList();
    return categories;
  }

  Widget createMusic(Music music) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: 200,
            child: InkWell(
              onTap: () {
                _miniPlayer(music, stop: true);
              },
              child: Image.network(
                music.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            music.name,
            style: TextStyle(color: const Color(0xFF2E4052)),
          ),
          Text(music.desc, style: TextStyle(color: const Color(0xFF2E4052)))
        ],
      ),
    );
  }

  Widget createMusicList(String label) {
    List<Music> musicList = MusicOperations.getMusic();
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 300,
            child: ListView.builder(
              //padding: EdgeInsets.all(5),
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return createMusic(musicList[index]);
              },
              itemCount: musicList.length,
            ),
          )
        ],
      ),
    );
  }

  Widget createSolfeggioMusicList(String label) {
    List<Music> musicList = MusicOperations.getSolfeggioMusic();
    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 300,
            child: ListView.builder(
              //padding: EdgeInsets.all(5),
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, index) {
                return createMusic(musicList[index]);
              },
              itemCount: musicList.length,
            ),
          )
        ],
      ),
    );
  }

  Widget createGrid() {
    return Container(
      padding: EdgeInsets.all(10),
      height: 280,
      child: GridView.count(
        childAspectRatio: 5 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        children: createListOfCategories(),
        crossAxisCount: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
          child: Container(
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            createGrid(),
            createSolfeggioMusicList('Solfeggio Frequencies (Sonic Therapy)'),
            createMusicList('Made for you'),
            createMusicList('Popular PlayList')
          ],
        ),
      )),
    );
  }
}