class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final bool isUnlocked;
  final String? conditionType;
  final double? targetValue;
  final String? earnedDate;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.isUnlocked,
    this.conditionType,
    this.targetValue,
    this.earnedDate,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_logro'] ?? json['id'];
    final name = (json['nombre'] ?? json['titulo'] ?? json['title'] ?? 'Logro').toString();
    final condition = json['tipo_condicion']?.toString();
    final targetNum = json['valor_objetivo'];
    final target = targetNum is num ? targetNum.toDouble() : double.tryParse('$targetNum');
    final earned = json['fecha_obtencion']?.toString();

    // Generar descripción amigable si el backend no envía 'descripcion'
    String desc = (json['descripcion'] ?? json['description'] ?? '').toString();
    if (desc.isEmpty && condition != null && target != null) {
      switch (condition) {
        case 'cantidad_residuos':
          desc = 'Recicla ${target.toInt()} residuos en los tachos inteligentes.';
          break;
        case 'puntos_acumulados':
          desc = 'Acumula ${target.toInt()} puntos en tu cuenta de reciclaje.';
          break;
        case 'peso_total_kg':
          desc = 'Recupera ${target.toStringAsFixed(1)} kg de material reciclable.';
          break;
        default:
          desc = 'Meta: $target en $condition';
      }
    } else if (desc.isEmpty) {
      desc = '¡Logro obtenido por tu compromiso con el reciclaje!';
    }

    // Los logros devueltos por GET /logros corresponden a los ya obtenidos por el usuario
    final unlocked = json['desbloqueado'] ?? json['isUnlocked'] ?? (earned != null || json.containsKey('id_logro'));

    return Achievement(
      id: rawId?.toString() ?? '',
      title: name,
      description: desc,
      iconUrl: json['icono'] ?? json['iconUrl'] ?? '',
      isUnlocked: unlocked == true,
      conditionType: condition,
      targetValue: target,
      earnedDate: earned,
    );
  }
}
