class Song {
  final String videoId;
  final String title;
  final String artist;
  final String thumbnailUrl;
  final String? duration;

  Song({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    this.duration,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] as String? ?? 'Unknown Title',
      artist: json['artist'] as String? ?? 'Unknown Artist',
      duration: json['duration'] as String?,
      videoId: json['video_id'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': videoId,
      'title': title,
      'artist': artist,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
    };
  }
}

