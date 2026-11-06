class MonthlyRecycler {
  final String id;
  final String name;
  final String avatarUrl;
  final int totalPoints;
  final double totalKgRecycled;
  final String monthYear;

  MonthlyRecycler({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.totalPoints,
    required this.totalKgRecycled,
    required this.monthYear,
  });

  factory MonthlyRecycler.fromJson(Map<String, dynamic> json) {
    return MonthlyRecycler(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Usuario Destacado',
      avatarUrl: json['avatarUrl'] ?? '',
      totalPoints: json['totalPoints'] ?? 0,
      totalKgRecycled: (json['totalKgRecycled'] as num?)?.toDouble() ?? 0.0,
      monthYear: json['monthYear'] ?? '',
    );
  }
}