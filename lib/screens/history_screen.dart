import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../models/delivery.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';

class HistoryScreen extends StatefulWidget {
  final DashboardData data;
  final Future<void> Function() onLoadMore;

  const HistoryScreen({
    super.key,
    required this.data,
    required this.onLoadMore,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Delivery> get _deliveries => widget.data.deliveries;
  int get _total => widget.data.historyTotal;
  bool _loading = false;
  String? _loadError;

  Future<void> _loadMore() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      await widget.onLoadMore();
    } catch (error) {
      if (mounted) setState(() => _loadError = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPoints = _deliveries.fold<double>(
      0,
      (sum, delivery) => sum + delivery.points,
    );

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BrandHeader(),
            const SizedBox(height: 20),
            Text(
              'Historial de reciclaje',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Cada entrega suma para un campus más sostenible.',
              style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TU IMPACTO TOTAL',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.data.metrics.totalDeliveries} entregas · ${widget.data.metrics.totalWeightKg.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.recycling,
                      size: 18,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  'Tus entregas registradas',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$_total registros',
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_deliveries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Aún no tienes entregas registradas.',
                    style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                  ),
                ),
              )
            else
              for (final delivery in _deliveries) _DeliveryTile(delivery),
            if (_deliveries.isNotEmpty) const Divider(color: AppColors.border),
            if (_deliveries.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Puntos de las entregas cargadas',
                    style: TextStyle(fontSize: 10, color: AppColors.textGrey),
                  ),
                  Text(
                    '${_formatPoints(totalPoints)} pts',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.orange,
                    ),
                  ),
                ],
              ),
            if (_loadError != null) ...[
              const SizedBox(height: 10),
              Text(
                'No se pudo cargar más historial: $_loadError',
                style: const TextStyle(fontSize: 11, color: Colors.red),
              ),
            ],
            if (_deliveries.length < _total) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _loading ? null : _loadMore,
                  child: Text(_loading ? 'Cargando…' : 'Cargar más entregas'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatPoints(double points) => points == points.roundToDouble()
      ? points.toStringAsFixed(0)
      : points.toStringAsFixed(1);
}

class _DeliveryTile extends StatelessWidget {
  final Delivery delivery;

  const _DeliveryTile(this.delivery);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.greenSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(delivery.icon, size: 18, color: AppColors.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.material,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${delivery.date} · Tacho ${delivery.tachoId}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${_formatPoints(delivery.points)} pts',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
              Text(
                '${delivery.kg} kg',
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppColors.textGrey,
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
