import 'dart:convert'; 
import 'package:http/http.dart' as http;
import 'package:test_flutter/data/models/artist/artist.dart';
import 'package:test_flutter/data/models/artist/artist_detail.dart';
import 'package:test_flutter/data/models/playlist/playlist.dart';
import 'package:test_flutter/data/models/playlist/playlist_detail.dart';
import '../../data/models/song/song.dart';

class ApiService {

  static const String baseUrl = 'https://large-giving-oryx.ngrok-free.app'; 
//  static const String baseUrl = 'http://10.0.2.2:8000';
//  static const String baseUrl = 'http://localhost:5000';
  static final Map<String, ArtistDetail> _artistCache = {};

  Future<List<Song>> fetchTrendingSongs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/trending'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final List<dynamic> songsJson = data['songs'] as List<dynamic>;
        return songsJson.map((json) => Song.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Failed to load trending songs (Status: ${response.statusCode}) - Body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching trending songs: $e');
      throw Exception('Failed to load trending songs. Check network connection and server status. Error: $e');
    }
  }

  Future<List<Artist>> fetchPopularArtists() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/popular_artists'));

    if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> artistsJson = data['artists'];
        return artistsJson.map((json) => Artist.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular artists (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error fetching popular artists: $e');
      throw Exception('Failed to load popular artists. Error: $e');
    }
  }

  Future<ArtistDetail> fetchArtistDetails(String channelId) async {
    // 1. Kiểm tra trong cache trước
    if (_artistCache.containsKey(channelId)) {
      print("Fetching artist $channelId from CLIENT CACHE");
      return _artistCache[channelId]!;
    }

    // 2. Nếu không có trong cache, gọi API
    print("Fetching artist $channelId from SERVER");
    final response = await http.get(Uri.parse('$baseUrl/api/artist/$channelId'));

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final artistDetail = ArtistDetail.fromJson(data);
      // 3. Lưu vào cache để dùng cho lần sau
      _artistCache[channelId] = artistDetail;

      return artistDetail;
    } else {
      throw Exception('Failed to load artist details');
    }
  }

  Future<List<Playlist>> fetchMadeForYouPlaylists() async {
    final response = await http.get(Uri.parse('$baseUrl/api/made_for_you'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> playlistJson = data['playlists'];
      return playlistJson.map((json) => Playlist.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Made for You playlists');
    }
  }

  Future<PlaylistDetail> fetchPlaylistDetail(String playlistId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/playlist/$playlistId'));
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      return PlaylistDetail.fromJson(data);
    } else {
      throw Exception('Failed to load playlist details');
    }
  }

  Future<List<dynamic>> search(String query) async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/search?q=${Uri.encodeComponent(query)}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data['results'] as List<dynamic>;
      } else {
        throw Exception('Failed to perform search (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Error performing search: $e');
      throw Exception('Failed to perform search. Error: $e');
    }
  }

  Future<Song> fetchSongDetails(String videoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/song/$videoId'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return Song.fromJson(data);
      } else {
        throw Exception('Failed to load song details');
      }
    } catch (e) {
      throw Exception('Failed to load song details. Error: $e');
    }
  }
}