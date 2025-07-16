import 'package:flutter/material.dart';
import 'package:test_flutter/data/models/playlist/playlist.dart';
import 'package:test_flutter/domain/services/database_service.dart';

class FavoritePlaylistButton extends StatelessWidget {
  final Playlist playlist;
  final DatabaseService databaseService;

  const FavoritePlaylistButton({
    super.key,
    required this.playlist,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: databaseService.isFavoritePlaylistStream(playlist.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.white54),
            onPressed: null,
          );
        }

        final bool isFavorite = snapshot.data ?? false;

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : Colors.white,
          ),
          onPressed: () {
            if (isFavorite) {
              databaseService.removeFavoritePlaylist(playlist.id);
            } else {
              databaseService.addFavoritePlaylist(playlist.id, playlist.toJson());
            } 
          },
        );
      },
    );
  }
}