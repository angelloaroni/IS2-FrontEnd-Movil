import 'ranking_user.dart';

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
    final rawGanador = json['ganador'] ?? json['data'] ?? json;
    final Map<String, dynamic> ganador = rawGanador is Map<String, dynamic>
        ? rawGanador
        : json;

    final idVal = ganador['id_user'] ?? ganador['id'] ?? '';
    final nameVal = (ganador['nombre'] ?? ganador['name'] ?? 'Usuario Destacado').toString();
    final pointsVal = ganador['puntos'] ?? ganador['puntosGanados'] ?? ganador['totalPoints'] ?? 0;
    final kgVal = ganador['pesoTotalKg'] ?? ganador['totalKgRecycled'] ?? 0.0;
    final mesVal = (json['mes'] ?? json['monthYear'] ?? ganador['monthYear'] ?? '').toString();

    return MonthlyRecycler(
      id: idVal.toString(),
      name: nameVal,
      avatarUrl: (ganador['avatarUrl'] ?? '').toString(),
      totalPoints: pointsVal is num ? pointsVal.toInt() : int.tryParse('$pointsVal') ?? 0,
      totalKgRecycled: kgVal is num ? kgVal.toDouble() : double.tryParse('$kgVal') ?? 0.0,
      monthYear: mesVal.isNotEmpty ? mesVal : 'Mes actual',
    );
  }

  factory MonthlyRecycler.fromRankingUser(RankingUser user, {String monthYear = ''}) {
    return MonthlyRecycler(
      id: user.idUser.toString(),
      name: user.name,
      avatarUrl: '',
      totalPoints: user.points.toInt(),
      totalKgRecycled: user.totalWeightKg,
      monthYear: monthYear.isNotEmpty ? monthYear : 'Top 1',
    );
  }
}
