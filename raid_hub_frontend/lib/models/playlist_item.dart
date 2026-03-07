class PlaylistItem {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final int position;
  final String publishedAt;
  final String? playlistId;

  PlaylistItem({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.position,
    required this.publishedAt,
    this.playlistId,
  });

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? '',
      channelTitle: json['channelTitle'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      position: json['position'] ?? 0,
      publishedAt: json['publishedAt'] ?? '',
    );
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$videoId';

  PlaylistItem copyWith({
    String? videoId,
    String? title,
    String? channelTitle,
    String? thumbnailUrl,
    int? position,
    String? publishedAt,
    String? playlistId,
  }) {
    return PlaylistItem(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      channelTitle: channelTitle ?? this.channelTitle,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      position: position ?? this.position,
      publishedAt: publishedAt ?? this.publishedAt,
      playlistId: playlistId ?? this.playlistId,
    );
  }
}
