// lib/data/models/playlist_detail.dart

import 'package:test_flutter/data/models/song/song.dart';

class PlaylistDetail {
  final String id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final List<Song> songs;

  PlaylistDetail({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    required this.songs,
  });

  factory PlaylistDetail.fromJson(Map<String, dynamic> json) {
    var songList = json['songs'] as List;
    List<Song> songs = songList.map((i) => Song.fromJson(i)).toList();
    
    return PlaylistDetail(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'] ?? '',
      songs: songs,
    );
  }
}