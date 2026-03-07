class CheatSheet {
  final int? id;
  final String title;
  final String raidName;
  final String gate;
  final String uploaderName;
  final String imageUrl;
  final DateTime? createdAt; // 추가

  CheatSheet({
    this.id,
    required this.title,
    required this.raidName,
    required this.gate,
    required this.uploaderName,
    required this.imageUrl,
    this.createdAt,
  });

  factory CheatSheet.fromJson(Map<String, dynamic> json) {
    return CheatSheet(
      id: json['id'],
      title: json['title'] ?? '',
      raidName: json['raidName'] ?? '',
      gate: json['gate'] ?? '',
      uploaderName: json['uploaderName'] ?? '알 수 없음',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  // Full URL helper (Base URL should be appended)
  String get fullImageUrl => 'http://localhost:8080$imageUrl';
}
