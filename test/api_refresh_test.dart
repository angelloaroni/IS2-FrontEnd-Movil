import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/screens/achievements_screen.dart';
import 'package:frontendmovil/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Future<http.Response> Function(http.Request) respond;
  late ApiService service;

  setUpAll(() {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-token'});
    service = http.runWithClient(
      () => ApiService.instance,
      () => MockClient((request) => respond(request)),
    );
  });

  test(
    'reloads all displayed pages and deduplicates records by server ID',
    () async {
      var revision = 1;
      final requestedPages = <int>[];
      respond = (request) async {
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(request.url.origin, 'http://localhost:3000');
        final page = int.parse(request.url.queryParameters['pagina']!);
        requestedPages.add(page);
        final ids = revision == 1
            ? (page == 1 ? [4, 3] : [3, 2])
            : (page == 1 ? [5, 4] : [3, 2]);
        return http.Response(
          jsonEncode({
            'ok': true,
            'data': {
              'registros': [
                for (final id in ids)
                  {
                    'idHistorial': id,
                    'fecha': '2026-11-11',
                    'idTacho': 1,
                    'residuo': {'tipo': 'plastico', 'peso': 1},
                  },
              ],
              'paginacion': {'total': revision == 1 ? 4 : 5},
            },
          }),
          200,
        );
      };

      final initial = await service.loadHistoryPages(2);
      expect(initial.deliveries.map((row) => row.id), ['4', '3', '2']);
      revision = 2;
      final refreshed = await service.loadHistoryPages(2);
      expect(refreshed.total, 5);
      expect(refreshed.deliveries.map((row) => row.id), ['5', '4', '3', '2']);
      expect(requestedPages, [1, 2, 1, 2]);
    },
  );

  test(
    'dashboard failures preserve the original API connection error',
    () async {
      respond = (request) async => throw http.ClientException('offline');
      await expectLater(
        service.loadDashboard(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'server address',
            contains('http://localhost:3000/api/'),
          ),
        ),
      );
    },
  );

  testWidgets('an open achievements screen refreshes and survives an outage', (
    tester,
  ) async {
    var revision = 1;
    var offline = false;
    respond = (request) async {
      expect(request.url.path, '/api/logros');
      if (offline) throw http.ClientException('offline');
      return http.Response(
        jsonEncode({
          'ok': true,
          'data': [
            {
              'id': 1,
              'titulo': 'Medalla $revision',
              'descripcion': 'Reciclaje',
              'desbloqueado': revision > 1,
            },
          ],
        }),
        200,
      );
    };
    await tester.pumpWidget(const MaterialApp(home: AchievementsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Medalla 1'), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);

    revision = 2;
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Medalla 2'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);

    offline = true;
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.text('Medalla 2'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
