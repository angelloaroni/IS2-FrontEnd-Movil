import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/models/app_user.dart';
import 'package:frontendmovil/models/dashboard_data.dart';
import 'package:frontendmovil/screens/personal_environmental_stats_screen.dart';

void main() {
  testWidgets('PersonalEnvironmentalStatsScreen displays title and back button pops screen', (tester) async {
    const user = AppUser(
      id: 1,
      code: '00001001',
      name: 'Carlos Pérez',
      points: 150.0,
      type: 'usuario',
      active: true,
    );

    const metrics = UserMetrics(
      totalDeliveries: 10,
      totalWeightKg: 5.5,
    );

    const dashboardData = DashboardData(
      user: user,
      metrics: metrics,
      rankingPosition: 1,
      topRanked: [],
      deliveries: [],
      historyTotal: 0,
      monthlyRecycler: null,
      notifications: [],
    );

    var popped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Builder(
                  builder: (innerContext) => ElevatedButton(
                    onPressed: () async {
                      await Navigator.of(innerContext).push(
                        MaterialPageRoute(
                          builder: (_) => const PersonalEnvironmentalStatsScreen(data: dashboardData),
                        ),
                      );
                      popped = true;
                    },
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Estadísticas Ambientales'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(popped, isTrue);
  });
}
