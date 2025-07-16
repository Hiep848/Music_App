import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/common/theme/app_colors.dart';
import 'package:test_flutter/data/models/artist/artist.dart';
import 'package:test_flutter/data/models/playlist/playlist.dart';
import 'package:test_flutter/data/models/song/song.dart';
import 'package:test_flutter/domain/services/api_service.dart';
import 'package:test_flutter/domain/services/database_service.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:test_flutter/presentation/screens/artist_page/artist_page.dart';
import 'package:test_flutter/presentation/screens/music_player_page/music_player_screen.dart';
import 'package:test_flutter/presentation/screens/playlist_page/playlist_page.dart';
import 'package:test_flutter/presentation/screens/home_page/trending_songs_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  late Future<List<Song>> _trendingSongsFuture;
  late Future<List<Artist>> _popularArtistsFuture;
  late Future<List<Playlist>> _madeForYouPlaylistsFuture; 
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _trendingSongsFuture = _apiService.fetchTrendingSongs();
      _popularArtistsFuture = _apiService.fetchPopularArtists();
      _madeForYouPlaylistsFuture = _apiService.fetchMadeForYouPlaylists();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          children: [
            Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildSectionTitle1('Made for you'),
                    const SizedBox(height: 16),
                    _buildMadeForYouList(),
                    const SizedBox(height: 16),
                    _buildSectionTitle1('Popular singer'),
                    const SizedBox(height: 16),
                    _buildPopularSingerList(),
                    _buildSectionTitle('Trending song'),
                    const SizedBox(height: 16),
                    _buildTrendingSongList(),
                    const SizedBox(height: 40), 
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final hour = now.hour;
    final user = context.watch<User?>();
    final greeting = hour < 12 && hour >= 5
        ? 'Good Morning'
        : hour >= 12 && hour < 18
            ? 'Good Afternoon'
            : 'Good Evening';
    final displayName = user?.displayName?.split(' ').last ?? 'Guest';
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 20, 7),
      child: Row(
        children: [
          Text(
            '$greeting $displayName',
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20,
              color: AppColors.primaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications today. Stay tuned!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMadeForYouList() {
    return FutureBuilder<List<Playlist>>(
      future: _madeForYouPlaylistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return SizedBox(height: 160, child: Center(child: Text('Lỗi: ${snapshot.error}')));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(height: 160, child: Center(child: Text('Không có playlist nào.')));
        }

        final playlists = snapshot.data!;
        return SizedBox(
          height: 170.0,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              final hasThumbnail = playlist.thumbnailUrl.isNotEmpty;
              final proxiedUrl = hasThumbnail
                  ? '${ApiService.baseUrl}/image-proxy?url=${Uri.encodeComponent(playlist.thumbnailUrl)}'
                  : '';
              return GestureDetector(
                onTap: () {
                  final db = Provider.of<DatabaseService>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistPage(playlistId: playlist.id, databaseService: db,),
                    ),
                  );
                  print("Tapped on playlist: ${playlist.title}");
                },
                child: Container(
                  width: 120.0,
                  margin: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: hasThumbnail
                          ? Image.network(
                              proxiedUrl,
                              height: 120.0,
                              width: 120.0,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 120.0,
                                  width: 120.0,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.playlist_play, color: Colors.grey),
                                );
                              },
                            )
                          : Container( // Widget thay thế nếu không có ảnh
                              height: 120.0,
                              width: 120.0,
                              color: Colors.grey[300],
                              child: const Icon(Icons.playlist_play, color: Colors.grey),
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Expanded(
                        child: Text(
                          playlist.title,
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: AppColors.primaryText
            ),
          ),

        TextButton(
          onPressed: () {
            final db = Provider.of<DatabaseService>(context, listen: false);
            Navigator.push(context, MaterialPageRoute(
                builder: (context) => TrendingSongsScreen(databaseService: db), 
              ));
          },
          child: const Text(
            'See all',
            style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle1(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: AppColors.primaryText
            ),
          ),
      ],
    );
  }

  Widget _buildPopularSingerList() {
    return FutureBuilder<List<Artist>>(
      future: _popularArtistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return SizedBox(height: 120, child: Center(child: Text('Lỗi: ${snapshot.error}')));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(height: 120, child: Center(child: Text('Không có nghệ sĩ nào.')));
        } else {
          final artists = snapshot.data!;
          return SizedBox(
            height: 120.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: artists.length > 10 ? 10 : artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                final hasThumbnail = artist.thumbnailUrl.isNotEmpty;
                final proxiedUrl = hasThumbnail
                  ? '${ApiService.baseUrl}/image-proxy?url=${Uri.encodeComponent(artist.thumbnailUrl)}'
                  : '';
                return GestureDetector(
                  onTap: () {
                    final db = Provider.of<DatabaseService>(context, listen: false);
                    Navigator.push(context, MaterialPageRoute(
                    builder: (context) => ArtistDetailPage(channelId: artist.channelId, databaseService: db),
                    ));
                  },
                  child: Container(
                    width: 90.0,
                    margin: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40.0,
                          onBackgroundImageError: (e, s) {}, // Bỏ qua lỗi ảnh nếu có
                          backgroundColor: Colors.grey[300],
                          backgroundImage: hasThumbnail ? NetworkImage(proxiedUrl) : null,
                          child: !hasThumbnail
                            ? const Icon(Icons.person, color: Colors.white, size: 40)
                            : null,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          artist.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
  Widget _buildTrendingSongList() {
    return FutureBuilder<List<Song>>(
      future: _trendingSongsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        else if (snapshot.hasError) {
          return SizedBox(
            height: 220,
            child: Center(child: Text('Lỗi: ${snapshot.error}')),
          );
        }
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 220,
            child: Center(child: Text('Không có bài hát nào.')),
          );
        }
        else {
          final songs = snapshot.data!;
          return SizedBox(
            height: 200.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Đặt cuộn ngang
              itemCount: songs.length > 10 ? 10 : songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                return GestureDetector(
                  onTap: () {
                    final playerService = Provider.of<PlayerService>(context, listen: false);
                    final db = Provider.of<DatabaseService>(context, listen: false);
                    playerService.play(song, queue: songs);
                    Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(
                            fullscreenDialog: true, 
                            builder: (context) => Provider<DatabaseService>.value(
                              value: db,
                              child: Provider<DatabaseService>.value(
                                value: db,
                                child: const MusicPlayerScreen(),
                              ),
                            ),
                          ),
                        );
                  },
                  child: Container(
                    width: 100.0, // Đặt chiều rộng cố định cho mỗi card
                    margin: const EdgeInsets.only(right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            song.thumbnailUrl,
                            height: 100.0,
                            width: 100.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100.0,
                                width: 100.0,
                                color: Colors.grey[300],
                                child: const Icon(Icons.music_note, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // Tên bài hát
                        Text(
                          song.title,
                          style: const TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        // Tên nghệ sĩ
                        Text(
                          song.artist,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
