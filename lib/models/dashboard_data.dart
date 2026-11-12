import 'app_notification.dart';
import 'app_user.dart';
import 'delivery.dart';
import 'monthly_recycler.dart';
import 'ranking_user.dart';

class UserMetrics {
  final int totalDeliveries;
  final double totalWeightKg;

  const UserMetrics({
    required this.totalDeliveries,
    required this.totalWeightKg,
  });

  factory UserMetrics.fromJson(Map<String, dynamic> json) {
    final count = json['totalResiduos'] ?? json['totalDeliveries'] ?? 0;
    final weight = json['pesoTotalKg'] ?? json['totalWeightKg'] ?? 0.0;
    
    if (count is! num || weight is! num) {
      throw const FormatException('El servidor devolvió métricas inválidas.');
    }
    return UserMetrics(
      totalDeliveries: count.toInt(),
      totalWeightKg: weight.toDouble(),
    );
  }
}

class DashboardData {
  final AppUser user;
  final UserMetrics metrics;
  final int? rankingPosition;
  final List<RankingUser> topRanked;
  final List<Delivery> deliveries;
  final int historyTotal;
  final MonthlyRecycler? monthlyRecycler;
  final List<AppNotification> notifications;

  const DashboardData({
    required this.user,
    required this.metrics,
    required this.rankingPosition,
    this.topRanked = const [],
    required this.deliveries,
    required this.historyTotal,
    this.monthlyRecycler,
    this.notifications = const [],
  });

  DashboardData copyWith({
    AppUser? user,
    UserMetrics? metrics,
    int? rankingPosition,
    List<RankingUser>? topRanked,
    List<Delivery>? deliveries,
    int? historyTotal,
    MonthlyRecycler? monthlyRecycler,
    List<AppNotification>? notifications,
  }) {
    return DashboardData(
      user: user ?? this.user,
      metrics: metrics ?? this.metrics,
      rankingPosition: rankingPosition ?? this.rankingPosition,
      topRanked: topRanked ?? this.topRanked,
      deliveries: deliveries ?? this.deliveries,
      historyTotal: historyTotal ?? this.historyTotal,
      monthlyRecycler: monthlyRecycler ?? this.monthlyRecycler,
      notifications: notifications ?? this.notifications,
    );
  }

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final topList = (json['topRanked'] as List?)
            ?.map((e) => RankingUser.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    MonthlyRecycler? recycler;
    if (json['monthlyRecycler'] != null || json['recicladorMes'] != null) {
      final raw = json['monthlyRecycler'] ?? json['recicladorMes'];
      if (raw is Map<String, dynamic>) {
        if (raw['ganador'] is Map<String, dynamic> ||
            raw['name'] != null ||
            raw['nombre'] != null) {
          recycler = MonthlyRecycler.fromJson(raw);
        }
      }
    }
    if (recycler == null && topList.isNotEmpty) {
      recycler = MonthlyRecycler.fromRankingUser(topList.first);
    }

    return DashboardData(
      user: AppUser.fromJson(json['user'] ?? json['usuario'] ?? {}),
      metrics: UserMetrics.fromJson(json['metrics'] ?? json),
      rankingPosition: json['rankingPosition'] ?? json['puestoRanking'],
      topRanked: topList,
      deliveries: (json['deliveries'] as List?)
              ?.map((e) => Delivery.fromJson(e))
              .toList() ?? 
          [],
      historyTotal: json['historyTotal'] ?? json['total'] ?? 0,
      monthlyRecycler: recycler,
      notifications: (json['notifications'] as List?)
              ?.map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class HistoryPage {
  final List<Delivery> deliveries;
  final int total;

  const HistoryPage({required this.deliveries, required this.total});
}