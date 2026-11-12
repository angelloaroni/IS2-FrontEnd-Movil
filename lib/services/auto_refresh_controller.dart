import 'dart:async';

import 'package:flutter/widgets.dart';

/// Refreshes server data while the app is in the foreground. Failed requests
/// leave the last successful value visible, and slow requests never overlap.
class AutoRefreshController<T> extends ChangeNotifier
    with WidgetsBindingObserver {
  AutoRefreshController({required this.load});

  static const interval = Duration(seconds: 5);

  final Future<T> Function() load;
  T? data;
  Object? error;
  Future<void>? _inFlight;
  Timer? _timer;
  bool _enabled = true;
  bool _started = false;
  bool _disposed = false;

  bool get isLoading => _inFlight != null;
  bool get _foreground =>
      WidgetsBinding.instance.lifecycleState == null ||
      WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;

  void start() {
    if (_started || _disposed) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = null;
    if (!_started || _disposed || !_enabled || !_foreground) return;
    unawaited(refresh());
    _timer = Timer.periodic(interval, (_) => unawaited(refresh()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) => _schedule();

  Future<void> refresh() {
    if (_disposed || !_enabled || !_foreground) return Future.value();
    return _inFlight ??= _load();
  }

  Future<void> _load() async {
    try {
      final result = await Future<T>.sync(load);
      if (_disposed) return;
      data = result;
      error = null;
    } catch (failure) {
      if (_disposed) return;
      error = failure;
    } finally {
      _inFlight = null;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    if (_started) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
