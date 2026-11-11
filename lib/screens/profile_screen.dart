import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';
import 'personal_environmental_stats_screen.dart';
import 'achievements_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final DashboardData data;
  final Future<void> Function() onLogout;

  const ProfileScreen({super.key, required this.data, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandHeader(),
            const SizedBox(height: 22),
            Text(
              'Mi perfil',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Tu información y tu impacto en la comunidad.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      data.user.initials,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: AppColors.orange,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.user.name,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Comunidad · Universidad de Lima',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Mi impacto',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ImpactCard(
                    icon: Icons.eco_outlined,
                    value: '${data.metrics.totalWeightKg.toStringAsFixed(1)} kg',
                    label: 'Material recuperado',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ImpactCard(
                    icon: Icons.emoji_events_outlined,
                    value: _formatPoints(data.user.points),
                    label: 'Puntos acumulados',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _MenuActionCard(
              icon: Icons.analytics_outlined,
              label: 'Ver estadísticas ambientales detalladas',
              color: AppColors.green,
              backgroundColor: AppColors.greenSoft,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalEnvironmentalStatsScreen(data: data),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _MenuActionCard(
              icon: Icons.military_tech_rounded,
              label: 'Ver mis logros y medallas',
              color: AppColors.orange,
              backgroundColor: AppColors.orangeSoft,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AchievementsScreen(data: data),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _MenuActionCard(
              icon: Icons.edit_outlined,
              label: 'Editar información de perfil',
              color: AppColors.orange,
              backgroundColor: AppColors.orangeSoft,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                      currentName: data.user.name,
                      onSave: (updatedName) {
                        // Actualización de estado local
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            const Text(
              'Información personal',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _ProfileDetail(
                    icon: Icons.badge_outlined,
                    label: 'Código de usuario',
                    value: data.user.code,
                  ),
                  if (data.user.institutionalEmail != null) ...[
                    const Divider(height: 1, color: AppColors.border),
                    _ProfileDetail(
                      icon: Icons.email_outlined,
                      label: 'Correo institucional',
                      value: data.user.institutionalEmail!,
                    ),
                  ],
                  const Divider(height: 1, color: AppColors.border),
                  _ProfileDetail(
                    icon: Icons.verified_user_outlined,
                    label: 'Tipo de cuenta',
                    value: data.user.type,
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _ProfileDetail(
                    icon: Icons.recycling_outlined,
                    label: 'Entregas registradas',
                    value: '${data.metrics.totalDeliveries}',
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  _ProfileDetail(
                    icon: data.user.active
                        ? Icons.check_circle_outline
                        : Icons.block_outlined,
                    label: 'Estado de la cuenta',
                    value: data.user.active ? 'Activa' : 'Inactiva',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.orange,
                  side: const BorderSide(color: AppColors.orange),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPoints(double points) => points == points.roundToDouble()
      ? points.toStringAsFixed(0)
      : points.toStringAsFixed(1);

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Salir',
              style: TextStyle(color: AppColors.orange),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await onLogout();
    }
  }
}

class _MenuActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _MenuActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ImpactCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.green),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
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