import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/common/theme/app_colors.dart';
import 'package:test_flutter/data/models/artist/artist.dart';
import 'package:test_flutter/data/models/artist/artist_detail.dart';
import 'package:test_flutter/domain/services/api_service.dart';
import 'package:test_flutter/domain/services/database_service.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:test_flutter/presentation/screens/music_player_page/music_player_screen.dart';
import 'package:test_flutter/presentation/widget/favorite_artist_button.dart';

class ArtistDetailPage extends StatefulWidget {
  
  final String channelId;
  final DatabaseService databaseService;
  const ArtistDetailPage({super.key, required this.channelId, required this.databaseService});

  @override
  State<ArtistDetailPage> createState() => _ArtistDetailPageState();
}

class _ArtistDetailPageState extends State<ArtistDetailPage> {
  bool _isExpanded = false;
  late Future<ArtistDetail> _artistDetailFuture;
  final ApiService _apiService = ApiService();
 

  @override
  void initState() {
    super.initState();
    _artistDetailFuture = _apiService.fetchArtistDetails(widget.channelId);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder<ArtistDetail>(
        future: _artistDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không tìm thấy thông tin nghệ sĩ.'));
          }

          final artistDetail = snapshot.data!;
          final hasThumbnail = artistDetail.thumbnailUrl.isNotEmpty;
          final proxiedUrl = hasThumbnail
              ? '${ApiService.baseUrl}/image-proxy?url=${Uri.encodeComponent(artistDetail.thumbnailUrl)}'
              : '';
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                pinned: true,
                actions: [
                  // Tạo một đối tượng Artist từ dữ liệu có sẵn
                  FavoriteArtistButton(
                    artist: Artist(
                      name: artistDetail.name,
                      channelId: widget.channelId, // Lấy từ widget
                      thumbnailUrl: artistDetail.thumbnailUrl,
                    ),
                    databaseService: widget.databaseService, // Truyền service vào
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: hasThumbnail
                    ? Image.network(
                        proxiedUrl, // Dùng URL proxy
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(color: Colors.grey[800]),
                      )
                    : Container(color: Colors.grey[800]),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 4),
                  child: Text(
                    artistDetail.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                    maxLines: 2, // Hiển thị tối đa 2 dòng
                    overflow: TextOverflow.ellipsis, // Hiển thị dấu "..."
                  ),
                ),
              ),
              // Phần mô tả nghệ sĩ
              if (artistDetail.description != null && artistDetail.description!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artistDetail.description!,
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

              // Tiêu đề cho danh sách bài hát
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Popular songs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

              // Danh sách các bài hát
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = artistDetail.songs[index];
                    
                    final hasSongThumbnail = song.thumbnailUrl.isNotEmpty;
                    return ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: hasSongThumbnail
                            ? Image.network(
                                song.thumbnailUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: AppColors.subtleBorder,
                                child: const Icon(Icons.music_note, color: AppColors.secondaryText),
                              ),
                      ),
                      title: Text(song.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(song.artist),
                      onTap: () {
                        final playerService = Provider.of<PlayerService>(context, listen: false);
                        final db = widget.databaseService;
                        playerService.play(song, queue: artistDetail.songs);
                          Navigator.of(context).push(
                          MaterialPageRoute(
                            fullscreenDialog: true, 
                            builder: (context) => Provider<DatabaseService>.value(
                              value: db,
                              child: const MusicPlayerScreen(),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: artistDetail.songs.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}