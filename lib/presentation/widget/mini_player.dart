// lib/presentation/widgets/mini_player.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/domain/services/database_service.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:test_flutter/presentation/screens/music_player_page/music_player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    // Dùng Consumer để lắng nghe PlayerService
    return Consumer<PlayerService>(
      builder: (context, playerService, child) {
        final song = playerService.currentSong;
        final isPlaying = playerService.isPlaying;

        if (song == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            final db = Provider.of<DatabaseService>(context, listen: false);
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true, // Hiển thị như một dialog toàn màn hình
                builder: (context) => Provider<DatabaseService>.value(
                  value: db,
                  child: const MusicPlayerScreen(),
                ),
              ),
            );
          },
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              border: Border(top: BorderSide(color: Colors.grey.shade700, width: 1)),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        song.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey.shade600,
                          child: const Icon(Icons.music_note, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                // Song Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Nút Play/Pause
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () {
                    if (isPlaying) {
                      playerService.pause();
                    } else {
                      playerService.resume();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 38,
                  ),
                  onPressed: playerService.canGoNext ? playerService.next : null,
                  disabledColor: Colors.white38,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}