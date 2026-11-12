import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../services/api_service.dart';
import '../services/auto_refresh_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/main_bottom_nav.dart';
import 'history_screen.dart';
import 'map_screen.dart';
import 'points_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.dashboardLoader});

  final Future<DashboardData> Function(int historyPages)? dashboardLoader;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late final AutoRefreshController<DashboardData> _dashboard;
  int _historyPages = 1;

  @override
  void initState() {
    super.initState();
    _dashboard = AutoRefreshController(load: _loadDashboard);
    _dashboard.start();
  }

  Future<DashboardData> _fetchDashboard() =>
      widget.dashboardLoader?.call(_historyPages) ??
      ApiService.instance.loadDashboard(historyPages: _historyPages);

  Future<DashboardData> _loadDashboard() async {
    final previous = _dashboard.data;
    var result = await _fetchDashboard();
    if (previous != null && result.historyTotal > previous.historyTotal) {
      // Make room for new rows without dropping deliveries already displayed.
      final needed =
          previous.deliveries.length +
          result.historyTotal -
          previous.historyTotal;
      final neededPages = (needed + 9) ~/ 10;
      if (neededPages > _historyPages) {
        _historyPages = neededPages;
        result = await _fetchDashboard();
      }
    }
    return result;
  }

  void _retry() {
    _dashboard.refresh();
  }

  Future<void> _loadMoreHistory() async {
    if (_dashboard.isLoading) await _dashboard.refresh();
    if (!mounted) return;
    final previousPages = _historyPages;
    _historyPages++;
    await _dashboard.refresh();
    if (_dashboard.error != null) {
      _historyPages = previousPages;
      throw _dashboard.error!;
    }
  }

  @override
  void dispose() {
    _dashboard.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    _dashboard.enabled = false;
    await ApiService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _dashboard,
      builder: (context, _) {
        if (_dashboard.data == null && _dashboard.error != null) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 42,
                        color: AppColors.orange,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No se pudo cargar tu información',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_dashboard.error}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _retry,
                        child: const Text('Reintentar'),
                      ),
                      TextButton(
                        onPressed: _logout,
                        child: const Text('Volver al inicio de sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        if (_dashboard.data == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            ),
          );
        }

        final data = _dashboard.data!;
        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              PointsScreen(data: data),
              MapScreen(active: _index == 1),
              HistoryScreen(data: data, onLoadMore: _loadMoreHistory),
              ProfileScreen(
                data: data,
                onLogout: _logout,
                dashboard: _dashboard,
              ),
            ],
          ),
          bottomNavigationBar: MainBottomNav(
            currentIndex: _index,
            onTap: (index) => setState(() => _index = index),
          ),
        );
      },
    );
  }
}
