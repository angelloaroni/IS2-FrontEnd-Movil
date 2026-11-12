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
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
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
            color: Colors.black.withValues(alpha: 0.05),
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
                size: 26,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  recycler.monthYear.isNotEmpty
                      ? 'Reciclador del Mes (${recycler.monthYear})'
                      : 'Reciclador del Mes (Top 1)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Stack(
            alignment: Alignment.center,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.orange,
                child: CircleAvatar(
                  radius: 31,
                  backgroundColor: AppColors.background,
                  child: Text(
                    recycler.name.isNotEmpty ? recycler.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 26,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
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
                value: '${recycler.totalKgRecycled.toStringAsFixed(1)} kg',
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
                fontSize: 14,
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
            fontSize: 11,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}
