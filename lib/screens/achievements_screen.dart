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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandHeader(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Logros y Medallas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(left: 28),
                    child: Text(
                      'Recompensas obtenidas por tu impacto ambiental.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListenableBuilder(
                listenable: _achievements,
                builder: (context, _) {
                  if (_achievements.data == null &&
                      _achievements.error == null) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.orange),
                    );
                  }
                  // Estado de error
                  else if (_achievements.data == null &&
                      _achievements.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 40,
                              color: AppColors.orange,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Error al cargar logros:\n${_achievements.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textGrey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () => _achievements.refresh(),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  // Estado sin datos
                  else if (_achievements.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: const BoxDecoration(
                                color: AppColors.orangeSoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.military_tech_outlined,
                                size: 36,
                                color: AppColors.orange,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aún no tienes logros registrados',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sigue reciclando en los tachos inteligentes para desbloquear medallas y reconocimientos.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // Renderizado de la lista de logros obtenidos
                  final achievements = _achievements.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: achievements.length,
                    separatorBuilder: (_, ___) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final achievement = achievements[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: achievement.isUnlocked
                                ? AppColors.orange.withValues(alpha: 0.35)
                                : AppColors.border,
                            width: achievement.isUnlocked ? 1.5 : 1,
                          ),
                          boxShadow: achievement.isUnlocked
                              ? [
                                  BoxShadow(
                                    color: AppColors.orange.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: achievement.isUnlocked
                                    ? AppColors.orangeSoft
                                    : AppColors.border.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                achievement.isUnlocked
                                    ? Icons.emoji_events
                                    : Icons.lock,
                                color: achievement.isUnlocked
                                    ? AppColors.orange
                                    : AppColors.textGrey,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          achievement.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ),
                                      if (achievement.isUnlocked)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.greenSoft,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: AppColors.green.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: const Text(
                                            'Obtenido',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.green,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    achievement.description,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AppColors.textGrey,
                                      height: 1.3,
                                    ),
                                  ),
                                  if (achievement.earnedDate != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Fecha: ${achievement.earnedDate!}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textGrey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
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
