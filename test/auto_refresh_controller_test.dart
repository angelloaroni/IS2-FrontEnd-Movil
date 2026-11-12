import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/services/auto_refresh_controller.dart';

void main() {
  testWidgets('refreshes every five seconds and retains data after a failure', (
    tester,
  ) async {
    var calls = 0;
    var offline = false;
    final controller = AutoRefreshController<int>(
      load: () async {
        calls++;
        if (offline) throw StateError('offline');
        return calls;
      },
    )..start();
    await tester.pump();
    expect(controller.data, 1);

    await tester.pump(const Duration(seconds: 4));
    expect(calls, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(controller.data, 2);

    offline = true;
    await tester.pump(const Duration(seconds: 5));
    expect(controller.data, 2);
    expect(controller.error, isA<StateError>());

    offline = false;
    await tester.pump(const Duration(seconds: 5));
    expect(controller.data, 4);
    expect(controller.error, isNull);
    controller.dispose();
  });

  testWidgets(
    'pauses in background, resumes immediately, and stops on dispose',
    (tester) async {
      var calls = 0;
      final controller = AutoRefreshController<int>(load: () async => ++calls)
        ..start();
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 20));
      expect(calls, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(calls, 2);

      controller.enabled = false;
      await tester.pump(const Duration(seconds: 10));
      expect(calls, 2);
      controller.enabled = true;
      await tester.pump();
      expect(calls, 3);

      controller.dispose();
      await tester.pump(const Duration(seconds: 10));
      expect(calls, 3);
    },
  );

  testWidgets('does not overlap slow requests or notify after disposal', (
    tester,
  ) async {
    var calls = 0;
    var notifications = 0;
    var response = Completer<int>();
    final controller = AutoRefreshController<int>(
      load: () {
        calls++;
        return response.future;
      },
    )..addListener(() => notifications++);
    controller.start();
    await tester.pump(const Duration(seconds: 15));
    expect(calls, 1);
    response.complete(1);
    await tester.pump();
    expect(controller.data, 1);
    expect(notifications, 1);

    response = Completer<int>();
    await tester.pump(const Duration(seconds: 5));
    expect(calls, 2);
    controller.dispose();
    response.complete(2);
    await tester.pump();
    expect(notifications, 1);
  });
}
