class RankingUser {
  final int idUser;
  final String name;
  final double points;
  final int deliveryCount;
  final double totalWeightKg;
  final int position;

  const RankingUser({
    required this.idUser,
    required this.name,
    required this.points,
    required this.deliveryCount,
    required this.totalWeightKg,
    required this.position,
  });

  factory RankingUser.fromJson(Map<String, dynamic> json) {
    final pVal = json['puntos'];
    final pgVal = json['puntosGanados'];
    final pNum = pVal is num ? pVal.toDouble() : double.tryParse('$pVal') ?? 0.0;
    final pgNum = pgVal is num ? pgVal.toDouble() : double.tryParse('$pgVal') ?? 0.0;
    final pointsVal = pNum > pgNum ? pNum : pgNum;

    final weightVal = json['pesoTotalKg'] ?? 0;
    final deliveriesVal = json['cantidadResiduos'] ?? 0;
    final posVal = json['posicion'] ?? 0;
    final idVal = json['id_user'] ?? 0;

    return RankingUser(
      idUser: idVal is int ? idVal : int.tryParse('$idVal') ?? 0,
      name: (json['nombre'] as String?)?.trim() ?? 'Usuario',
      points: pointsVal,
      deliveryCount: deliveriesVal is int ? deliveriesVal : int.tryParse('$deliveriesVal') ?? 0,
      totalWeightKg: weightVal is num ? weightVal.toDouble() : double.tryParse('$weightVal') ?? 0.0,
      position: posVal is int ? posVal : int.tryParse('$posVal') ?? 0,
    );
  }

  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'U';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return trimmed.length >= 2
          ? trimmed.substring(0, 2).toUpperCase()
          : trimmed.toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
