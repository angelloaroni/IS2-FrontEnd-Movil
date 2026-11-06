import 'app_user.dart';
import 'delivery.dart';
import 'monthly_recycler.dart';

class UserMetrics {
  final int totalDeliveries;
  final double totalWeightKg;

  const UserMetrics({
    required this.totalDeliveries,
    required this.totalWeightKg,
  });

  factory UserMetrics.fromJson(Map<String, dynamic> json) {
    final count = json['totalResiduos'];
    final weight = json['pesoTotalKg'];
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
  final List<Delivery> deliveries;
  final int historyTotal;
  final MonthlyRecycler? monthlyRecycler;

  const DashboardData({
    required this.user,
    required this.metrics,
    required this.rankingPosition,
    required this.deliveries,
    required this.historyTotal,
    this.monthlyRecycler,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      // ... mapeo de otros campos ...
      monthlyRecycler: json['monthlyRecycler'] != null 
          ? MonthlyRecycler.fromJson(json['monthlyRecycler']) 
          : null,
    );
  }
}

class HistoryPage {
  final List<Delivery> deliveries;
  final int total;

  const HistoryPage({required this.deliveries, required this.total});
}
