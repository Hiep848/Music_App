import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:music_app/data/models/song/song.dart';
import 'package:music_app/domain/entities/song/song.dart';

abstract class SongFirebaseService{

  Future<Either> getNewSongs();
}

class SongFirebaseServiceImpl extends SongFirebaseService{

  @override
  Future<Either> getNewSongs() async {
    try {
      List<SongEntity> songs = [];

      var data = await FirebaseFirestore.instance.collection('Songs')
      .orderBy('releaseDate', descending: true)
      .limit(3)
      .get();

      for (var element in data.docs) {
        var songModel = SongModel.fromJson(element.data());
        songs.add(
          songModel.toEntity(),
        );
      }
      return Right(songs);
    } catch (e) {
      return Left('An error occurred, please try again');
    }
  }
}