import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../models/achievement.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';

class AchievementsScreen extends StatelessWidget {
  final DashboardData data;

  const AchievementsScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = Achievement.getMockAchievements(
      totalKg: data.metrics.totalWeightKg,
      totalDeliveries: data.metrics.totalDeliveries,
    );

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandHeader(),
              const SizedBox(height: 16),
              const Text(
                'Logros y Medallas',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Has desbloqueado $unlockedCount de ${achievements.length} medallas',
                style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
              const SizedBox(height: 20),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: achievement.isUnlocked ? AppColors.greenSoft : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: achievement.isUnlocked
                            ? AppColors.green.withValues(alpha: 0.3)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: achievement.isUnlocked ? AppColors.green : AppColors.border,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            achievement.isUnlocked ? Icons.military_tech_rounded : Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: achievement.isUnlocked ? AppColors.textDark : AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                achievement.description,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (achievement.isUnlocked)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.green,
                            size: 20,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}