class Playlist {
  final String id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final String? trackCount;

  Playlist({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    this.trackCount,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      description: json['description'],
      thumbnailUrl: json['thumbnail_url'] ?? '',
      trackCount: json['trackCount']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'trackCount': trackCount,
    };
  }
}