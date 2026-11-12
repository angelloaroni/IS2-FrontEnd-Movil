import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/models/monthly_recycler.dart';
import 'package:frontendmovil/models/ranking_user.dart';
import 'package:frontendmovil/screens/edit_profile_screen.dart';
import 'package:frontendmovil/widgets/main_bottom_nav.dart';
import 'package:frontendmovil/widgets/monthly_recycler_card.dart';

void main() {
  test('MonthlyRecycler falls back to RankingUser top 1 properly', () {
    const topUser = RankingUser(
      idUser: 2,
      name: 'María Gómez',
      points: 570,
      deliveryCount: 1,
      totalWeightKg: 0.5,
      position: 1,
    );

    final recycler = MonthlyRecycler.fromRankingUser(topUser, monthYear: '2026-11');

    expect(recycler.name, 'María Gómez');
    expect(recycler.totalPoints, 570);
    expect(recycler.totalKgRecycled, 0.5);
    expect(recycler.monthYear, '2026-11');
  });

  testWidgets('MonthlyRecyclerCard renders top 1 data', (tester) async {
    final recycler = MonthlyRecycler(
      id: '2',
      name: 'María Gómez',
      avatarUrl: '',
      totalPoints: 570,
      totalKgRecycled: 0.5,
      monthYear: '2026-11',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MonthlyRecyclerCard(recycler: recycler),
        ),
      ),
    );

    expect(find.text('María Gómez'), findsOneWidget);
    expect(find.text('570 pts'), findsOneWidget);
    expect(find.text('0.5 kg'), findsOneWidget);
    expect(find.text('Reciclador del Mes (2026-11)'), findsOneWidget);
  });

  testWidgets('EditProfileScreen has back button that pops', (tester) async {
    var popped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Builder(
                builder: (innerContext) => ElevatedButton(
                  onPressed: () async {
                    await Navigator.of(innerContext).push(
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          currentName: 'Carlos Pérez',
                          onSave: (_) {},
                        ),
                      ),
                    );
                    popped = true;
                  },
                  child: const Text('Editar'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar Perfil'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(popped, isTrue);
  });

  testWidgets('MainBottomNav contains all 6 navigation sections', (tester) async {
    int tappedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: MainBottomNav(
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    expect(find.text('Puntos'), findsOneWidget);
    expect(find.text('Ranking'), findsOneWidget);
    expect(find.text('Premios'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('Mi perfil'), findsOneWidget);

    await tester.tap(find.text('Ranking'));
    expect(tappedIndex, 1);

    await tester.tap(find.text('Premios'));
    expect(tappedIndex, 2);
  });
}
