import 'package:test_flutter/data/models/song/song.dart';

class ArtistDetail {
  final String name;
  final String thumbnailUrl;
  final String? description;
  final List<Song> songs;

  ArtistDetail({
    required this.name,
    required this.thumbnailUrl,
    this.description,
    required this.songs,
  });

  factory ArtistDetail.fromJson(Map<String, dynamic> json) {
    var songListFromJson = json['songs'] as List<dynamic>? ?? [];
    List<Song> songList = songListFromJson.map((i) => Song.fromJson(i)).toList();
  
    return ArtistDetail(
      name: json['artistName'] ?? 'Unknown Artist',
      thumbnailUrl: json['artistThumbnail'] ?? '',
      description: json['description'], // có thể là null
      songs: songList,
    );
  }
}