import 'package:flutter/material.dart';
import '../models/monthly_recycler.dart';
import '../theme/app_colors.dart';

class MonthlyRecyclerCard extends StatelessWidget {
  final MonthlyRecycler recycler;

  const MonthlyRecyclerCard({
    super.key,
    required this.recycler,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.green,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'Reciclador del Mes (${recycler.monthYear})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.orange,
                child: CircleAvatar(
                  radius: 33,
                  backgroundColor: AppColors.background,
                  child: Text(
                    recycler.name.isNotEmpty ? recycler.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            recycler.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.stars_rounded,
                value: '${recycler.totalPoints} pts',
                label: 'Puntos ganados',
              ),
              Container(
                height: 30,
                width: 1,
                color: AppColors.border,
              ),
              _buildStatItem(
                icon: Icons.recycling_rounded,
                value: '${recycler.totalKgRecycled} kg',
                label: 'Reciclados',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.green),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}