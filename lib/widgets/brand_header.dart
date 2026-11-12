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
  final int unreadNotificationsCount;
  final VoidCallback? onNotificationTap;

  const BrandHeader({
    super.key,
    this.trailing,
    this.showLogout = false,
    this.unreadNotificationsCount = 0,
    this.onNotificationTap,
  });

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
        if (onNotificationTap != null) ...[
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  unreadNotificationsCount > 0
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_none_rounded,
                  color: unreadNotificationsCount > 0
                      ? AppColors.orange
                      : AppColors.textDark,
                  size: 22,
                ),
                if (unreadNotificationsCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.orange,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        unreadNotificationsCount > 9 ? '9+' : '$unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: onNotificationTap,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
        ],
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
