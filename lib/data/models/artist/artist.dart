class Artist {
  final String name;
  final String channelId;
  final String thumbnailUrl;

  Artist({
    required this.name,
    required this.channelId,
    required this.thumbnailUrl,
  });

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      name: json['artistName'] ?? 'Unknown Artist',
      channelId: json['channelId'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'artistName': name,
      'channelId': channelId,
      'thumbnailUrl': thumbnailUrl,
    };
  }
}