import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class IconBadge extends StatelessWidget {
  final IconData icon;
  const IconBadge({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.orange, size: 22),
    );
  }
}
