class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final bool isUnlocked;
  final double progress;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.isUnlocked,
    required this.progress,
  });

  /// Placeholders
  static List<Achievement> getMockAchievements({required double totalKg, required int totalDeliveries}) {
    return [
      Achievement(
        id: '1',
        title: 'Primeros Pasos Verdes',
        description: 'Registra tu primera entrega de reciclaje en el sistema.',
        iconName: 'eco',
        isUnlocked: totalDeliveries > 0,
        progress: totalDeliveries > 0 ? 1.0 : 0.0,
      ),
      Achievement(
        id: '2',
        title: 'Reciclador Constante',
        description: 'Completa al menos 5 entregas de residuos.',
        iconName: 'repeat',
        isUnlocked: totalDeliveries >= 5,
        progress: (totalDeliveries / 5).clamp(0.0, 1.0),
      ),
      Achievement(
        id: '3',
        title: 'Guardián del Planeta',
        description: 'Acumula más de 10 kg de material recuperado.',
        iconName: 'shield',
        isUnlocked: totalKg >= 10.0,
        progress: (totalKg / 10.0).clamp(0.0, 1.0),
      ),
      Achievement(
        id: '4',
        title: 'Leyenda del Reciclaje',
        description: 'Alcanza los 50 kg de material reciclado en la universidad.',
        iconName: 'emoji_events',
        isUnlocked: totalKg >= 50.0,
        progress: (totalKg / 50.0).clamp(0.0, 1.0),
      ),
    ];
  }
}