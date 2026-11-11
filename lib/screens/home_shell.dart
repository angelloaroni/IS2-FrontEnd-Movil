import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/main_bottom_nav.dart';
import 'history_screen.dart';
import 'map_screen.dart';
import 'points_screen.dart';
import 'profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  late Future<DashboardData> _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = ApiService.instance.loadDashboard();
  }

  void _retry() {
    setState(() => _dashboard = ApiService.instance.loadDashboard());
  }

  Future<void> _logout() async {
    await ApiService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardData>(
      future: _dashboard,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
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
                        '${snapshot.error}',
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
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            ),
          );
        }

        final data = snapshot.requireData;
        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              PointsScreen(data: data),
              MapScreen(active: _index == 1),
              HistoryScreen(data: data),
              ProfileScreen(data: data, onLogout: _logout),
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
