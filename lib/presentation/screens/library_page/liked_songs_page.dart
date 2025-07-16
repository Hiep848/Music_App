
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/common/theme/app_colors.dart';
import 'package:test_flutter/data/models/playlist/playlist_detail.dart';
import 'package:test_flutter/data/models/song/song.dart';
import 'package:test_flutter/domain/services/api_service.dart';
import 'package:test_flutter/domain/services/database_service.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:test_flutter/presentation/screens/music_player_page/music_player_screen.dart';

class LikedSongsPage extends StatefulWidget {
  final List<Song> likedSongs;
  final DatabaseService databaseService;
  const LikedSongsPage({super.key, required this.databaseService, required this.likedSongs});

  @override
  State<LikedSongsPage> createState() => _LikedSongsState();
}

class _LikedSongsState extends State<LikedSongsPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final playlist = PlaylistDetail(
      id: 'liked_songs',
      title: 'Liked Songs',
      thumbnailUrl: widget.likedSongs.first.thumbnailUrl,
      description: 'Your favorite songs',
      songs: widget.likedSongs,
    );

    final proxiedUrl = playlist.thumbnailUrl.isNotEmpty
        ? '${ApiService.baseUrl}/image-proxy?url=${Uri.encodeComponent(playlist.thumbnailUrl)}'
        : '';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                  fit: StackFit.expand, 
                  children: [
                    proxiedUrl.isNotEmpty
                        ? Image.network(playlist.thumbnailUrl, fit: BoxFit.cover)
                        : Container(color: Colors.grey[800]),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    playlist.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ),

              if (playlist.description != null && playlist.description!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playlist.description!,
                          maxLines: _isExpanded ? 100 : 4, // Hiển thị tối đa 4 dòng
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.secondaryText, height: 1.5),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = playlist.songs[index];
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: song.thumbnailUrl.isNotEmpty
                            ? Image.network(song.thumbnailUrl, width: 50, height: 50, fit: BoxFit.cover)
                            : Container(
                                width: 50, height: 50, color: AppColors.subtleBorder,
                                child: const Icon(Icons.music_note, color: AppColors.secondaryText),
                              ),
                      ),
                      title: Text(song.title, style: const TextStyle(fontSize:14, fontWeight: FontWeight.w600)),
                      subtitle: Text(song.artist),
                      onTap: () {
                        final playerService = Provider.of<PlayerService>(context, listen: false);
                        final db = widget.databaseService;
                        playerService.play(song, queue: playlist.songs);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true, // Thêm cái này để có hiệu ứng trượt từ dưới lên đẹp hơn
                            builder: (context) => Provider<DatabaseService>.value(
                              value: db,
                              child: const MusicPlayerScreen(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: playlist.songs.length,
               ),
          ),
        ],
      ),
    );
  }
}