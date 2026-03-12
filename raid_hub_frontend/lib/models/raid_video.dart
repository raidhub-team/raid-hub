class RaidVideo {
  final int? id;
  final String title;
  final String youtubeUrl;
  final String uploaderName;
  final String raidName;
  final String difficulty;
  final String gate;
  final DateTime? createdAt;

  RaidVideo({
    this.id,
    required this.title,
    required this.youtubeUrl,
    required this.uploaderName,
    required this.raidName,
    required this.difficulty,
    required this.gate,
    this.createdAt,
  });

  factory RaidVideo.fromJson(Map<String, dynamic> json) {
    return RaidVideo(
      id: json['id'],
      title: json['title'],
      youtubeUrl: json['youtubeUrl'],
      uploaderName: json['uploaderName'],
      raidName: json['raidName'],
      difficulty: json['difficulty'],
      gate: json['gate'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'youtubeUrl': youtubeUrl,
      'uploaderName': uploaderName,
      'raidName': raidName,
      'difficulty': difficulty,
      'gate': gate,
    };
  }
}
