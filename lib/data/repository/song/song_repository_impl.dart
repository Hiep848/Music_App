import 'package:dartz/dartz.dart';
import 'package:music_app/data/sources/songs/song_firebase_service.dart';
import 'package:music_app/domain/repository/song/song.dart';
import 'package:music_app/service_locator.dart';

class SongRepositoryImpl extends SongsRepository{

  @override
  Future<Either> getNewSongs() async {
    return await sl<SongFirebaseService>().getNewSongs();
  }
  
  @override
  Future<Either> getPlaylist() {
    // TODO: implement getPlaylist
    throw UnimplementedError();
  }

  
}