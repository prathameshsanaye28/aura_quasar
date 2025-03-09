import '../models/music.dart';

class MusicOperations {
  MusicOperations._() {}
  static List<Music> getMusic() {
    return <Music>[
      Music(
          'Emotional Piano Music',
          'https://cdn.pixabay.com/audio/2024/10/29/08-32-50-109_200x200.jpg',
          'SigmaMusicArt',
          'songs/song1.mp3'),
      Music(
          'Inspirational Uplifting Calm Piano',
          'https://cdn.pixabay.com/audio/2024/10/24/22-55-08-52_200x200.jpg',
          'leberchmus',
          'songs/song2.mp3'),
      Music(
          'relaxing piano music',
          'https://cdn.pixabay.com/audio/2024/10/09/10-56-43-251_200x200.jpg',
          'Clavier-Music ',
          'songs/song3.mp3'),
      Music(
          'Tibet',
          'https://cdn.pixabay.com/audio/2024/12/05/13-47-53-576_200x200.jpg',
          'Top-Flow',
          'songs/song4.mp3'),
    ];
  }

  static List<Music> getSolfeggioMusic() {
    return <Music>[
      Music('741Hz', 'https://www.chiangmaiholistic.com/images/741hz.jpg',
          'Sound Therapy', 'songs/741Hz.mp3'),
      Music('852Hz', 'https://www.chiangmaiholistic.com/images/852hz.jpg',
          'leberchmus', 'songs/852hz.mp3'),
      Music('639Hz', 'https://www.chiangmaiholistic.com/images/639hz.jpg',
          'Clavier-Music ', 'songs/639hz.mp3'),
      Music('528Hz', 'https://www.chiangmaiholistic.com/images/528hz.jpg',
          'Top-Flow', 'songs/528hz.mp3'),
      Music('174Hz', 'https://www.chiangmaiholistic.com/images/174hz.jpg',
          'Top-Flow', 'songs/174hz.mp3'),
      Music('285Hz', 'https://www.chiangmaiholistic.com/images/285hz.jpg',
          'Top-Flow', 'songs/285hz.mp3'),
      Music('417Hz', 'https://www.chiangmaiholistic.com/images/417hz.jpg',
          'Top-Flow', 'songs/417hz.mp3'),
      Music(
          '963Hz',
          'https://cdn.prod.website-files.com/6420a365ce09cdc0a758acfc/64b43db2917f2bbe277af32f_963%20300x300%20(1).png',
          'Top-Flow',
          'songs/963hz.mp3'),
      Music('396Hz', 'https://www.chiangmaiholistic.com/images/396hz.jpg',
          'Top-Flow', 'songs/396hz.mp3'),
    ];
  }
}