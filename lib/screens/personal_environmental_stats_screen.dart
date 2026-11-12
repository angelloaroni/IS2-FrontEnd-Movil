import 'package:flutter/material.dart';
import '../models/dashboard_data.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';

class PersonalEnvironmentalStatsScreen extends StatelessWidget {
  final DashboardData data;

  const PersonalEnvironmentalStatsScreen({
    super.key,
    required this.data,
  });

  String _getFavoriteMaterial() {
    if (data.deliveries.isEmpty) return 'Aún sin registros';

    final Map<String, double> materialWeights = {};
    for (var delivery in data.deliveries) {
      materialWeights.update(
        delivery.material,
        (value) => value + delivery.kg,
        ifAbsent: () => delivery.kg,
      );
    }

    String favorite = 'Ninguno';
    double maxWeight = -1.0;
    materialWeights.forEach((material, weight) {
      if (weight > maxWeight) {
        maxWeight = weight;
        favorite = material;
      }
    });

    return '$favorite (${maxWeight.toStringAsFixed(1)} kg)';
  }

  @override
  Widget build(BuildContext context) {
    final favoriteMaterial = _getFavoriteMaterial();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandHeader(),
              const SizedBox(height: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Volver',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Estadísticas Ambientales',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.only(left: 32),
                child: Text(
                  'Conoce el impacto generado por tus actividades de reciclaje',
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 20),
              
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.greenSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.green.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'RESUMEN DE IMPACTO PERSONAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatRow(
                      icon: Icons.star_rounded,
                      label: 'Puntaje total acumulado',
                      value: '${data.user.points} pts',
                    ),
                    const Divider(height: 20, color: Color(0x331E8449)),
                    _buildStatRow(
                      icon: Icons.repeat_rounded,
                      label: 'Actividades de reciclaje',
                      value: '${data.metrics.totalDeliveries} entregas',
                    ),
                    const Divider(height: 20, color: Color(0x331E8449)),
                    _buildStatRow(
                      icon: Icons.recycling_rounded,
                      label: 'Material más reciclado',
                      value: favoriteMaterial,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.green),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}