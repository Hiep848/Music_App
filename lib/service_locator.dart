import 'package:get_it/get_it.dart';
import 'package:music_app/data/repository/auth/auth_repository_impl.dart';
import 'package:music_app/data/repository/song/song_repository_impl.dart';
import 'package:music_app/data/sources/auth/auth_firebase_service.dart';
import 'package:music_app/data/sources/songs/song_firebase_service.dart';
import 'package:music_app/domain/repository/auth/auth.dart';
import 'package:music_app/domain/repository/song/song.dart';
import 'package:music_app/domain/usecases/auth/signin.dart';
import 'package:music_app/domain/usecases/auth/signup.dart';
import 'package:music_app/domain/usecases/song/get_new_songs.dart';

final sl = GetIt.instance;

Future<void> initializeDependecies() async {

  sl.registerSingleton<AuthFirebaseService>(
    AuthFirebaseServiceImpl(),
  );

  sl.registerSingleton<SongFirebaseService>(
    SongFirebaseServiceImpl(),
  );

  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(),
  );

  sl.registerSingleton<SongsRepository>(
    SongRepositoryImpl(),
  );

  sl.registerSingleton<SignupUseCase>(
    SignupUseCase(),
  );

  sl.registerSingleton<SigninUseCase>(
    SigninUseCase(),
  );

  sl.registerSingleton<GetNewSongsUseCase>(
    GetNewSongsUseCase(),
  );
}