import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/domain/usecases/song/get_new_songs.dart';
import 'package:music_app/presentation/home/bloc/news_songs_state.dart';
import 'package:music_app/service_locator.dart';

class NewsSongsCubit extends Cubit<NewsSongsState>{
  NewsSongsCubit() : super(NewsSongsLoading());

  Future<void> getNewsSongs() async {
    print('Start getNewsSongs');
    var returnedSongs = await sl<GetNewSongsUseCase>().call();
  print('Got result: $returnedSongs');
    returnedSongs.fold(
      (l) {
        emit(NewsSongsLoadFailure());
      },
      (data) {
        emit(NewsSongsLoaded(songs: data));
      },
    );
  }
}