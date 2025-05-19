import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/domain/entities/song/song.dart';
import 'package:music_app/presentation/home/bloc/news_songs_cubit.dart';
import 'package:music_app/presentation/home/bloc/news_songs_state.dart';
import 'package:music_app/core/configs/constants/app_url.dart';

class NewsSongs extends StatelessWidget {
  const NewsSongs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsSongsCubit()..getNewsSongs(),
      child: SizedBox(
        height: 200,
        child: BlocBuilder<NewsSongsCubit, NewsSongsState>(
          builder: (context, state){
            if (state is NewsSongsLoading) {
              return Container(
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            } else if (state is NewsSongsLoaded) {
              return _songs(
                state.songs,
              );
            }
            return Container();
          },  
        ), 
      )
    );
  }

  Widget _songs(List<SongEntity> songs) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => SizedBox(
          width: 160,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      AppUrls.firestorage + songs[index].artist + ' - ' + songs[index].title + '.jpg?' + AppUrls.mediaAlt,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemCount: songs.length,
    );
  }
}
