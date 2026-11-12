import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/models/app_user.dart';
import 'package:frontendmovil/models/dashboard_data.dart';
import 'package:frontendmovil/models/reward.dart';
import 'package:frontendmovil/screens/rewards_screen.dart';
import 'package:flutter/material.dart';

void main() {
  test('Reward.fromJson parses backend payload correctly', () {
    final payload = {
      'id_premio': 1,
      'nombre': 'Notebook Ecológica',
      'descripcion': 'Cuaderno hecho con material 100% reciclado',
      'costo': 50.0,
      'stock': 20,
    };

    final reward = Reward.fromJson(payload);
    expect(reward.id, 1);
    expect(reward.name, 'Notebook Ecológica');
    expect(reward.cost, 50.0);
    expect(reward.stock, 20);
    expect(reward.isAvailable, isTrue);
  });

  test('ClaimedReward serialization round-trip', () {
    const claim = ClaimedReward(
      id: 101,
      rewardId: 1,
      rewardName: 'Notebook Ecológica',
      cost: 50.0,
      claimedDate: '2026-11-12',
      status: 'Pendiente de recojo',
    );

    final json = claim.toJson();
    final parsed = ClaimedReward.fromJson(json);

    expect(parsed.id, 101);
    expect(parsed.rewardName, 'Notebook Ecológica');
    expect(parsed.cost, 50.0);
    expect(parsed.status, 'Pendiente de recojo');
  });

  testWidgets('RewardsScreen renders tabs and title correctly', (tester) async {
    final dashboardData = DashboardData(
      user: const AppUser(
        id: 1,
        code: '00001001',
        name: 'Carlos Pérez',
        points: 150.0,
        type: 'Estudiante',
        active: true,
      ),
      metrics: const UserMetrics(totalDeliveries: 3, totalWeightKg: 10.0),
      rankingPosition: 1,
      deliveries: const [],
      historyTotal: 0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RewardsScreen(data: dashboardData),
      ),
    );

    expect(find.text('Canje de Premios'), findsOneWidget);
    expect(find.text('150 pts'), findsOneWidget);
    expect(find.text('Premios disponibles'), findsOneWidget);
    expect(find.text('Pendientes de recojo'), findsOneWidget);
  });
}
