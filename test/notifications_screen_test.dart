import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/models/app_notification.dart';
import 'package:frontendmovil/screens/notifications_screen.dart';
import 'package:frontendmovil/widgets/brand_header.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('NotificationsScreen displays empty state when list is empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NotificationsScreen(notifications: []),
      ),
    );

    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('No tienes notificaciones'), findsOneWidget);
  });

  testWidgets('NotificationsScreen displays recycling notifications correctly', (tester) async {
    final notifications = [
      AppNotification(
        id: 1,
        userId: 1,
        type: 'reciclaje',
        title: 'Reciclaje registrado',
        message: 'Registraste 1.5 kg de plastico y ganaste 15 puntos.',
        date: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      AppNotification(
        id: 2,
        userId: 1,
        type: 'ranking',
        title: 'Ingresaste al top 10',
        message: 'Ingresaste al top 10 del período 2026-11.',
        date: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationsScreen(notifications: notifications),
      ),
    );

    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Reciclaje registrado'), findsOneWidget);
    expect(find.text('Registraste 1.5 kg de plastico y ganaste 15 puntos.'), findsOneWidget);
    expect(find.text('Ingresaste al top 10'), findsOneWidget);
  });

  testWidgets('BrandHeader switches icon when there are pending alerts', (tester) async {
    // Caso 1: con alertas pendientes (> 0)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrandHeader(
            unreadNotificationsCount: 3,
            onNotificationTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsNothing);
    expect(find.text('3'), findsOneWidget);

    // Caso 2: sin alertas pendientes (0)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrandHeader(
            unreadNotificationsCount: 0,
            onNotificationTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(find.byIcon(Icons.notifications_active_rounded), findsNothing);
    expect(find.text('3'), findsNothing);
  });
}
