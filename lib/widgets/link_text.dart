import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class LinkText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double size;

  const LinkText(this.text, {super.key, required this.onTap, this.size = 11});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        text,
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: AppColors.orange,
        ),
      ),
    );
  }
}
