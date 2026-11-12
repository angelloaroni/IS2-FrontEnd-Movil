import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../services/api_service.dart';
import '../services/auto_refresh_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late final AutoRefreshController<List<Achievement>> _achievements;

  @override
  void initState() {
    super.initState();
    _achievements = AutoRefreshController(
      load: ApiService.instance.getUserAchievements,
    )..start();
  }

  @override
  void dispose() {
    _achievements.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.all(20), child: BrandHeader()),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Logros y Medallas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListenableBuilder(
                listenable: _achievements,
                builder: (context, _) {
                  if (_achievements.data == null &&
                      _achievements.error == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Estado de error
                  else if (_achievements.data == null &&
                      _achievements.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Error al cargar logros: ${_achievements.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  // Estado sin datos
                  else if (_achievements.data!.isEmpty) {
                    return const Center(
                      child: Text('Aún no tienes logros registrados.'),
                    );
                  }

                  // Renderizado de la lista de logros obtenidos
                  final achievements = _achievements.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      final achievement = achievements[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              achievement.isUnlocked
                                  ? Icons.emoji_events
                                  : Icons.lock,
                              color: achievement.isUnlocked
                                  ? AppColors.orange
                                  : Colors.grey,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    achievement.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    achievement.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
