class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.isUnlocked,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id']?.toString() ?? '',
      title: json['titulo'] ?? json['title'] ?? '',
      description: json['descripcion'] ?? json['description'] ?? '',
      iconUrl: json['icono'] ?? json['iconUrl'] ?? '',
      isUnlocked: json['desbloqueado'] ?? json['isUnlocked'] ?? false,
    );
  }
}