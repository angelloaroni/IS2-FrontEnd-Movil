import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';

class PointsScreen extends StatelessWidget {
  final DashboardData data;

  const PointsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final last = data.deliveries.isEmpty ? null : data.deliveries.first;
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: BrandHeader(
                trailing: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    data.user.initials,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ),
            ),
            _PointsCard(data: data),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu impacto se nota',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Desde que te uniste a ULima Recicla',
                    style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.eco_outlined,
                          value:
                              '${data.metrics.totalWeightKg.toStringAsFixed(1)} kg',
                          label: 'Material recuperado',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.inventory_2_outlined,
                          value: '${data.metrics.totalDeliveries}',
                          label: 'Entregas registradas',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const _HowPointsCard(),
                  const SizedBox(height: 14),
                  if (last != null)
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.greenSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            last.icon,
                            size: 18,
                            color: AppColors.green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Última entrega · ${last.material}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                '${last.date} · ${last.kg} kg',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${_formatPoints(last.points)} pts',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Aún no tienes entregas registradas.',
                      style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                    ),
                  const SizedBox(height: 10),
                  const Text(
                    'Consulta el detalle de tus entregas en Historial.',
                    style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                  ),
                ],
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
}

class _PointsCard extends StatelessWidget {
  final DashboardData data;

  const _PointsCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.orangeSoft,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  color: AppColors.orange,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TUS PUNTOS ACUMULADOS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      _formatPoints(data.user.points),
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '¡Cada entrega cuenta, ${data.user.name}!',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0x33F15A24)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tu posición en la comunidad',
                style: TextStyle(fontSize: 10, color: AppColors.textGrey),
              ),
              Text(
                data.rankingPosition == null
                    ? 'Sin posición'
                    : 'Puesto ${data.rankingPosition}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatPoints(double points) => points == points.roundToDouble()
      ? points.toStringAsFixed(0)
      : points.toStringAsFixed(1);
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greenSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.green),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.green,
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

class _HowPointsCard extends StatelessWidget {
  const _HowPointsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo sumas puntos?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 kg de material',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '10 puntos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            'La tarifa del servidor aplica a plástico, papel/cartón y orgánicos. Los puntos se asignan al registrar cada entrega.',
            style: TextStyle(fontSize: 10, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}
