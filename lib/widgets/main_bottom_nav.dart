import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _item(0, Icons.emoji_events_outlined, 'Puntos'),
            _item(1, Icons.leaderboard_outlined, 'Ranking'),
            _item(2, Icons.card_giftcard_outlined, 'Premios'),
            _item(3, Icons.map_outlined, 'Mapa'),
            _item(4, Icons.history, 'Historial'),
            _item(5, Icons.person_outline, 'Mi perfil'),
          ],
        ),
      ),
    );
  }

  Widget _item(int index, IconData icon, String label) {
    final selected = index == currentIndex;
    final color = selected ? AppColors.orange : AppColors.textGrey;
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Container(
          height: 54,
          color: selected ? AppColors.orangeSoft : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
