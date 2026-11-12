import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../models/reward.dart';
import '../services/api_service.dart';
import '../services/auto_refresh_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';

class RewardsScreen extends StatefulWidget {
  final DashboardData data;
  final VoidCallback? onPointsChanged;

  const RewardsScreen({
    super.key,
    required this.data,
    this.onPointsChanged,
  });

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AutoRefreshController<List<Reward>> _rewardsController;
  List<ClaimedReward> _pendingClaims = [];
  bool _loadingClaims = true;
  double _currentPoints = 0;

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.data.user.points;
    _tabController = TabController(length: 2, vsync: this);
    _rewardsController = AutoRefreshController(
      load: ApiService.instance.getRewards,
    )..start();
    _loadPendingClaims();
  }

  Future<void> _loadPendingClaims() async {
    final claims = await ApiService.instance.getPendingClaimedRewards();
    if (mounted) {
      setState(() {
        _pendingClaims = claims;
        _loadingClaims = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rewardsController.dispose();
    super.dispose();
  }

  Future<void> _claim(Reward reward) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar canje'),
        content: Text(
          '¿Deseas canjear "${reward.name}" por ${reward.cost.toStringAsFixed(0)} puntos?\n\n'
          'Tus puntos actuales: ${_currentPoints.toStringAsFixed(0)} pts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reclamar premio'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    // Ejecutar canje
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
      );

      final claimed = await ApiService.instance.claimReward(reward);
      if (!mounted) return;
      Navigator.pop(context); // cerrar diálogo de carga

      setState(() {
        _currentPoints -= reward.cost;
        _pendingClaims = [claimed, ..._pendingClaims];
      });

      widget.onPointsChanged?.call();
      _rewardsController.refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '¡Premio "${reward.name}" canjeado! Guárdalo en pendientes para recoger.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Cambiar a la pestaña de pendientes
      _tabController.animateTo(1);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // cerrar diálogo de carga
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandHeader(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (Navigator.of(context).canPop()) ...[
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Volver',
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Text(
                            'Canje de Premios',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.orangeSoft,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: AppColors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${_currentPoints.toStringAsFixed(0)} pts',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(left: 28),
                    child: Text(
                      'Reclama productos sostenibles con tus puntos acumulados.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      labelColor: AppColors.textDark,
                      unselectedLabelColor: AppColors.textGrey,
                      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                      tabs: [
                        const Tab(text: 'Premios disponibles'),
                        Tab(
                          text: _pendingClaims.isEmpty
                              ? 'Pendientes de recojo'
                              : 'Pendientes (${_pendingClaims.length})',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pestaña 1: Premios disponibles
                  _buildAvailableRewardsTab(),

                  // Pestaña 2: Pendientes de recoger
                  _buildPendingClaimsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableRewardsTab() {
    return ListenableBuilder(
      listenable: _rewardsController,
      builder: (context, _) {
        if (_rewardsController.data == null && _rewardsController.error == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.orange),
          );
        }

        if (_rewardsController.data == null && _rewardsController.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.orange),
                  const SizedBox(height: 10),
                  Text(
                    'Error al cargar catálogo:\n${_rewardsController.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => _rewardsController.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final rewards = _rewardsController.data!;
        if (rewards.isEmpty) {
          return const Center(
            child: Text(
              'No hay premios disponibles en este momento.',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: rewards.length,
          separatorBuilder: (_, ___) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final reward = rewards[index];
            final canAfford = _currentPoints >= reward.cost;
            final hasStock = reward.isAvailable;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: hasStock ? AppColors.greenSoft : AppColors.border.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.card_giftcard_rounded,
                          color: hasStock ? AppColors.green : AppColors.textGrey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reward.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              reward.description,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textGrey,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${reward.cost.toStringAsFixed(0)} pts',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.orange,
                            ),
                          ),
                          Text(
                            hasStock ? 'Stock: ${reward.stock}' : 'Agotado',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: hasStock ? AppColors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        canAfford
                            ? '¡Tienes puntos suficientes!'
                            : 'Te faltan ${(reward.cost - _currentPoints).toStringAsFixed(0)} pts',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: canAfford ? AppColors.green : AppColors.textGrey,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: (hasStock && canAfford) ? () => _claim(reward) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: AppColors.border,
                          disabledForegroundColor: AppColors.textGrey,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: Text(
                          !hasStock
                              ? 'Sin stock'
                              : (!canAfford ? 'Puntos insuficientes' : 'Canjear premio'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPendingClaimsTab() {
    if (_loadingClaims) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      );
    }

    if (_pendingClaims.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.orangeSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  size: 32,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No tienes reclamos pendientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Cuando canjees un premio con tus puntos de reciclaje, verás tu orden aquí para recogerlo en el campus.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _pendingClaims.length,
      separatorBuilder: (_, ___) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final claim = _pendingClaims[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.orange.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.orangeSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.qr_code_rounded,
                          size: 18,
                          color: AppColors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reclamo #${claim.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      claim.status,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                claim.rewardName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Canjeado por ${claim.cost.toStringAsFixed(0)} puntos el ${claim.claimedDate}',
                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 16, color: AppColors.green),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Presenta tu código de estudiante en el Centro de Sostenibilidad (Edificio V) para retirar tu premio.',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
