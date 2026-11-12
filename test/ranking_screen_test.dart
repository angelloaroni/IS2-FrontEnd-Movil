import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/models/dashboard_data.dart';
import 'package:frontendmovil/models/app_user.dart';
import 'package:frontendmovil/models/ranking_user.dart';
import 'package:frontendmovil/screens/ranking_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('RankingScreen displays top 3 podium and rest of users', (tester) async {
    final testUsers = List.generate(
      5,
      (i) => RankingUser(
        idUser: i + 1,
        name: 'Usuario ${i + 1}',
        points: (100 - i * 10).toDouble(),
        deliveryCount: 5 - i,
        totalWeightKg: (20 - i * 2).toDouble(),
        position: i + 1,
      ),
    );

    final dashboardData = DashboardData(
      user: const AppUser(
        id: 1,
        code: '00001001',
        name: 'Usuario 1',
        points: 100,
        type: 'usuario',
        active: true,
      ),
      metrics: const UserMetrics(totalDeliveries: 5, totalWeightKg: 20),
      rankingPosition: 1,
      topRanked: testUsers,
      deliveries: const [],
      historyTotal: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RankingScreen(data: dashboardData),
      ),
    );

    expect(find.text('Ranking de la Comunidad'), findsOneWidget);
    expect(find.text('PODIO DE HONOR'), findsOneWidget);
    expect(find.text('🥇'), findsOneWidget);
    expect(find.text('🥈'), findsOneWidget);
    expect(find.text('🥉'), findsOneWidget);

    // Checks top 1, 2, 3 in podium
    expect(find.text('Usuario 1'), findsWidgets);
    expect(find.text('Usuario 2'), findsOneWidget);
    expect(find.text('Usuario 3'), findsOneWidget);

    // Checks rest of the top list (positions 4 and 5)
    expect(find.text('Usuario 4'), findsOneWidget);
    expect(find.text('Usuario 5'), findsOneWidget);
    expect(find.text('#4'), findsOneWidget);
    expect(find.text('#5'), findsOneWidget);
  });
}
