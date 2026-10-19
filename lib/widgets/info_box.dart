import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class InfoBox extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String message;
  final Color background;
  final Color iconColor;

  const InfoBox({
    super.key,
    required this.icon,
    required this.message,
    this.title,
    this.background = AppColors.greenSoft,
    this.iconColor = AppColors.green,
  });

  const InfoBox.warning({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.info_outline,
  }) : background = AppColors.orangeSoft,
       iconColor = AppColors.orange;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                if (title != null) const SizedBox(height: 2),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textGrey,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
