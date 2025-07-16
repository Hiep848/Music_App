import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter/common/theme/app_colors.dart';
import 'package:test_flutter/data/models/song/song.dart';
import 'package:test_flutter/domain/services/api_service.dart';
import 'package:test_flutter/domain/services/database_service.dart';
import 'package:test_flutter/domain/services/player_service.dart';
import 'package:test_flutter/presentation/screens/artist_page/artist_page.dart';
import 'package:test_flutter/presentation/screens/music_player_page/music_player_screen.dart';
import 'package:test_flutter/presentation/screens/playlist_page/playlist_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  Timer? _debouncer;
  
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debouncer?.isActive ?? false) _debouncer!.cancel();
    _debouncer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch();
      } else {
        setState(() {
          _searchResults = [];
        });
      }
    });
  }

  Future<void> _performSearch() async {
    setState(() => _isSearching = true);
    try {
      final results = await _apiService.search(_searchController.text.trim());
      setState(() => _searchResults = results);
    } catch (e) {
      // Xử lý lỗi nếu cần
      print(e);
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildSearchBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildSearchBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'What do you want to listen to?',
          hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 15),
          prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(icon: const Icon(Icons.clear, color: AppColors.secondaryText), onPressed: () => _searchController.clear())
            : null,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text(
          'Search for songs, artists, or playlists',
          style: TextStyle(color: AppColors.secondaryText, fontSize: 16),
        ),
      );
    }
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchResults.isEmpty) {
      return const Center(child: Text('No results found.'));
    }
    return _buildSearchResultList();
  }

  Widget _buildSearchResultList() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final type = item['type'];

        IconData leadingIcon = Icons.music_note;
        String title = "N/A";
        String subtitle = "N/A";
        String imageUrl = item['thumbnailUrl'] ?? item['thumbnail_url'] ?? '';
        VoidCallback? onTap;

        if (type == 'song') {
          leadingIcon = Icons.music_note;
          title = item['title'] ?? 'Unknown Song';
          subtitle = item['artist'] ?? 'Unknown Artist';
          onTap = () {
              final playerService = Provider.of<PlayerService>(context, listen: false);
              final db = Provider.of<DatabaseService>(context, listen: false);
              final songToPlay = Song.fromJson(item as Map<String, dynamic>);
              final songsQueue = _searchResults
                .where((result) => result['type'] == 'song')
                .map((songMap) => Song.fromJson(songMap as Map<String, dynamic>))
                .toList();
              playerService.play(songToPlay, queue: songsQueue);
              Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true, // Thêm cái này để có hiệu ứng trượt từ dưới lên đẹp hơn
                builder: (context) => Provider<DatabaseService>.value(
                  value: db,
                  child: const MusicPlayerScreen(),
                ),
              ),
            );
          };
        } else if (type == 'artist') {
          leadingIcon = Icons.person;
          title = item['artistName'] ?? 'Unknown Artist';
          subtitle = 'Artist';
          onTap = () {
            final db = Provider.of<DatabaseService>(context, listen: false);
             Navigator.push(context, MaterialPageRoute(
                builder: (context) => ArtistDetailPage(channelId: item['channelId'], databaseService: db,),
              ));
          };
        } else if (type == 'playlist') {
          leadingIcon = Icons.playlist_play;
          title = item['playlistName'] ?? 'Unknown Playlist';
          subtitle = 'Playlist • ${item['author']}';
          onTap = () {
            final playlistId = item['playlistId'];
            final db = Provider.of<DatabaseService>(context, listen: false);
            if (playlistId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistPage(playlistId: playlistId, databaseService: db),
                ),
              );
            }
          };
        }  
        

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.subtleBorder,
            backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty ? Icon(leadingIcon, color: AppColors.secondaryText) : null,
          ),
          title: Text(title, style: const TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(color: AppColors.secondaryText)),
          onTap: onTap,
        );
      },
    );
  }

  
}