import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/models/app_user.dart';
import 'package:frontendmovil/models/dashboard_data.dart';
import 'package:frontendmovil/models/delivery.dart';
import 'package:frontendmovil/models/monthly_recycler.dart';
import 'package:frontendmovil/screens/home_shell.dart';
import 'package:frontendmovil/screens/history_screen.dart';

DashboardData dashboard(int revision, int pages) => DashboardData(
  user: AppUser(
    id: 1,
    code: '00000001',
    name: 'Ana Perez',
    points: revision * 10,
    type: 'usuario',
    active: true,
  ),
  metrics: UserMetrics(
    totalDeliveries: 30 + revision,
    totalWeightKg: revision.toDouble(),
  ),
  rankingPosition: revision,
  deliveries: [
    for (var i = 0; i < pages * 10 && i < 30 + revision; i++)
      Delivery(
        id: '${1000 + revision - i}',
        material: 'Entrega ${1000 + revision - i}',
        date: '11 nov 2026',
        kg: 1,
        tachoId: 1,
      ),
  ],
  historyTotal: 30 + revision,
  monthlyRecycler: MonthlyRecycler(
    id: '1',
    name: 'Reciclador $revision',
    avatarUrl: '',
    totalPoints: revision * 10,
    totalKgRecycled: revision.toDouble(),
    monthYear: '2026-11',
  ),
);

void main() {
  testWidgets(
    'refreshes points, ranking, profile and an open statistics route',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var revision = 1;
      await tester.pumpWidget(
        MaterialApp(
          home: HomeShell(
            dashboardLoader: (pages) async => dashboard(revision, pages),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Puesto 1'), findsOneWidget);
      expect(find.text('Reciclador 1'), findsOneWidget);

      revision = 2;
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(find.text('Puesto 2'), findsOneWidget);
      expect(find.text('Reciclador 2'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);

      await tester.tap(find.text('Mi perfil'));
      await tester.pump();
      expect(find.text('20'), findsOneWidget);
      await tester.tap(find.text('Ver estadísticas ambientales detalladas'));
      await tester.pumpAndSettle();
      expect(find.text('20.0 pts'), findsOneWidget);

      revision = 3;
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(find.text('30.0 pts'), findsOneWidget);
      expect(find.text('33 entregas'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'keeps loaded history when new records arrive without duplicates',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 2200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var revision = 1;
      var offline = false;
      await tester.pumpWidget(
        MaterialApp(
          home: HomeShell(
            dashboardLoader: (pages) async {
              if (offline) throw StateError('offline');
              return dashboard(revision, pages);
            },
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Historial'));
      await tester.pump();
      expect(find.text('31 registros'), findsOneWidget);

      await tester.ensureVisible(find.text('Cargar más entregas'));
      await tester.tap(find.text('Cargar más entregas'));
      await tester.pump();
      await tester.pump();
      expect(
        tester
            .widget<HistoryScreen>(find.byType(HistoryScreen))
            .data
            .deliveries,
        hasLength(20),
      );

      revision = 2;
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      final history = tester
          .widget<HistoryScreen>(find.byType(HistoryScreen))
          .data;
      expect(history.historyTotal, 32);
      expect(history.deliveries.first.id, '1002');
      expect(history.deliveries.map((row) => row.id), contains('982'));
      expect(
        history.deliveries.map((row) => row.id).toSet(),
        hasLength(history.deliveries.length),
      );
      expect(find.text('32 registros'), findsOneWidget);

      offline = true;
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(find.text('32 registros'), findsOneWidget);
      expect(find.text('No se pudo cargar tu información'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
