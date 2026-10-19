import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.recycling, color: Colors.white, size: size * 0.6),
    );
  }
}

class BrandHeader extends StatelessWidget {
  final Widget? trailing;
  final bool showLogout;

  const BrandHeader({super.key, this.trailing, this.showLogout = false});

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandLogo(),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ULima Recicla',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Universidad de Lima',
              style: TextStyle(fontSize: 10, color: AppColors.textGrey),
            ),
          ],
        ),
        const Spacer(),
        if (trailing != null) trailing!,
        if (showLogout)
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textGrey, size: 20),
            onPressed: () => _logout(context),
          ),
      ],
    );
  }
}
