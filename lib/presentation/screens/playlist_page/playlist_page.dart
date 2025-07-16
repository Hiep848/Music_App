// lib/presentation/screens/playlist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/common/theme/app_colors.dart';
import 'package:test_flutter/data/models/playlist/playlist.dart';
import 'package:test_flutter/data/models/playlist/playlist_detail.dart';
import 'package:test_flutter/domain/services/api_service.dart';
import 'package:test_flutter/domain/services/database_service.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:test_flutter/presentation/screens/music_player_page/music_player_screen.dart';
import 'package:test_flutter/presentation/widget/favorite_playlist_button.dart';

class PlaylistPage extends StatefulWidget {
  final String playlistId;
  final DatabaseService databaseService;
  const PlaylistPage({super.key, required this.playlistId, required this.databaseService});

  @override
  State<PlaylistPage> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistPage> {
  bool _isExpanded = false;
  late Future<PlaylistDetail> _playlistDetailFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _playlistDetailFuture = _apiService.fetchPlaylistDetail(widget.playlistId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<PlaylistDetail>(
        future: _playlistDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy thông tin playlist.'));
          }

          final playlist = snapshot.data!;
          final proxiedUrl = playlist.thumbnailUrl.isNotEmpty
              ? '${ApiService.baseUrl}/image-proxy?url=${Uri.encodeComponent(playlist.thumbnailUrl)}'
              : '';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                actions: [
                  FavoritePlaylistButton(
                    playlist: Playlist(
                      id: playlist.id, 
                      title: playlist.title, 
                      thumbnailUrl: playlist.thumbnailUrl,
                      description: playlist.description,
                      trackCount: playlist.songs.length.toString(), 
                      ),
                    databaseService: widget.databaseService,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                  fit: StackFit.expand, 
                  children: [
                    proxiedUrl.isNotEmpty
                        ? Image.network(proxiedUrl, fit: BoxFit.cover)
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
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                            child: Text(
                            _isExpanded ? 'See less' : 'Read more',
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = playlist.songs[index];
                    final songProxiedUrl = song.thumbnailUrl.isNotEmpty
                      ? '${ApiService.baseUrl}/image-proxy?url=${Uri.encodeComponent(song.thumbnailUrl)}'
                      : '';

                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: songProxiedUrl.isNotEmpty
                            ? Image.network(songProxiedUrl, width: 50, height: 50, fit: BoxFit.cover)
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
          );
        },
      ),
    );
  }
}