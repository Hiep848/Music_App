// lib/pages/library_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/common/theme/app_colors.dart';
import 'package:test_flutter/data/models/artist/artist.dart';
import 'package:test_flutter/data/models/playlist/playlist.dart';
import 'package:test_flutter/data/models/song/song.dart';
import 'package:test_flutter/domain/services/api_service.dart';
import 'package:test_flutter/domain/services/database_service.dart';
import 'package:test_flutter/presentation/screens/artist_page/artist_page.dart';
import 'package:test_flutter/presentation/screens/library_page/liked_songs_page.dart';
import 'package:test_flutter/presentation/screens/playlist_page/playlist_page.dart'; // Sửa đường dẫn nếu cần

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // Biến để theo dõi bộ lọc nào đang được chọn
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All', 'Playlists', 'Artists'];

  @override
  Widget build(BuildContext context) {
    final databaseService  = Provider.of<DatabaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      // Dùng ListView để toàn bộ nội dung (bộ lọc + danh sách) có thể cuộn cùng nhau
      body: ListView(
          children: [
            _buildFilterChips(),
            const SizedBox(height: 8),
            _buildFilteredContent(databaseService),
        ],
      ),
    );
  }

  Widget _buildFilteredContent(DatabaseService db) {
    bool showPlaylists = _selectedFilterIndex == 0 || _selectedFilterIndex == 1;
    bool showArtists = _selectedFilterIndex == 0 || _selectedFilterIndex == 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chỉ hiển thị phần playlist nếu bộ lọc là "All" hoặc "Playlists"
        if (showPlaylists) _buildLikedSongsPlaylist(db),
        if (showPlaylists) _buildFavoritePlaylistList(db),

        // Chỉ hiển thị phần artists nếu bộ lọc là "All" hoặc "Artists"
        if (showArtists) _buildFavoriteArtistsList(db),
      ],
    );
  }

  Widget _buildLikedSongsPlaylist(DatabaseService db) {
    return StreamBuilder<List<Song>>(
      stream: db.getFavoriteSongsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Không có bài hát yêu thích thì không hiện
        }
        final songs = snapshot.data!;
        return ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LikedSongsPage(
                  databaseService: db,
                  likedSongs: songs, // Truyền danh sách bài hát yêu thích
                ),
              ),
            );
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: 
              const Icon(Icons.favorite, color: Color.fromARGB(255, 145, 61, 61), size: 56), // Icon trái tim cho Liked Songs
          ),
          title: const Text('Liked Songs', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
          subtitle: Text('Playlist • ${songs.length} songs', style: const TextStyle(color: AppColors.secondaryText)),
        );
      },
    );
  }

  Widget _buildFavoritePlaylistList(DatabaseService db) {
    return StreamBuilder<List<Playlist>>(
      stream: db.getFavoritePlaylistsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); 
        }
        final playlists = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            final proxiedUrl = '${ApiService.baseUrl}/image-proxy?url=${Uri.encodeComponent(playlist.thumbnailUrl)}';
            return ListTile(
              onTap: () { 
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistPage(playlistId: playlist.id, databaseService: db,),
                    ),
                  );
                  print("Tapped on playlist: ${playlist.title}");
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                child: Image.network(
                  proxiedUrl,
                  width: 56, height: 56, fit: BoxFit.cover,
                ),
              ),
              title: Text(playlist.title, maxLines: 1, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
              subtitle: Text('Playlist • ${playlist.trackCount} songs', style: TextStyle(color: AppColors.secondaryText)),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoriteArtistsList(DatabaseService db) {
    return StreamBuilder<List<Artist>>(
      stream: db.getFavoriteArtistsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Không có nghệ sĩ yêu thích thì không hiện
        }
        final artists = snapshot.data!;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            final proxiedUrl = '${ApiService.baseUrl}/image-proxy?url=${Uri.encodeComponent(artist.thumbnailUrl)}';
            return ListTile(
              onTap: () { 
                Navigator.push(context, MaterialPageRoute(
                builder: (context) => ArtistDetailPage(channelId: artist.channelId, databaseService: db),
                ));
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(proxiedUrl),
              ),
              title: Text(artist.name, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
              subtitle: const Text('Artist', style: TextStyle(color: AppColors.secondaryText)),
            );
          },
        );
      },
    );
  }
  
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      title: const Text(
        'Your Library',
        style: TextStyle(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: List<Widget>.generate(_filters.length, (index) {
          bool isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(_filters[index]),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilterIndex = index;
                  });
                }
              },
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
                side: const BorderSide(color: AppColors.border),
              ),
              showCheckmark: false,
            ),
          );
        }),
      ),
    );
  }


}