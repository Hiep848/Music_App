class AppURLs {

  static const coverFirestorage = 'https://firebasestorage.googleapis.com/v0/b/spotify0101.appspot.com/o/covers%2F';
  static const songFirestorage = 'https://firebasestorage.googleapis.com/v0/b/spotify0101.appspot.com/o/songs%2F';
  static const mediaAlt = 'alt=media';
  static const defaultImage = 'https://cdn-icons-png.flaticon.com/512/10542/10542486.png';

}

String getRandomMusicCoverUrl({int width = 300, int height = 300}) {
  return 'https://source.unsplash.com/random/${width}x$height/?music,singer,album';
}