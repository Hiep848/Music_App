import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/data/models/song/song.dart';
import 'package:test_flutter/domain/services/database_service.dart';

class FavoriteButton extends StatelessWidget {
  final Song song;

  const FavoriteButton({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    final databaseService = Provider.of<DatabaseService>(context, listen: false);
    return StreamBuilder<bool>(
      stream: databaseService.isFavoriteSongStream(song.videoId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white54, size: 28),
            onPressed: null,
          );
        }

        final bool isFavorite = snapshot.data ?? false;

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : Colors.white,
            size: 28,
          ),
          onPressed: () {
            if (isFavorite) {
              databaseService.removeFavoriteSong(song.videoId);
            } else {
              databaseService.addFavoriteSong(song);
            }
          },
        );
      },
    );
  }
}