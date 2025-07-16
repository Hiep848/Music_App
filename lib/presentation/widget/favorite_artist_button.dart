import 'package:flutter/material.dart';
import 'package:test_flutter/data/models/artist/artist.dart';
import 'package:test_flutter/domain/services/database_service.dart';

class FavoriteArtistButton extends StatelessWidget {
  final Artist artist;
  final DatabaseService databaseService;

  const FavoriteArtistButton({
    super.key,
    required this.artist,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: databaseService.isFavoriteArtistStream(artist.channelId),
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
              databaseService.removeFavoriteArtist(artist.channelId);
            } else {
              databaseService.addFavoriteArtist(artist);
            }
          },
        );
      },
    );
  }
}