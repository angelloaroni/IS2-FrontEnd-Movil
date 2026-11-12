import 'package:flutter/material.dart';

import '../models/dashboard_data.dart';
import '../models/ranking_user.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';

class RankingScreen extends StatelessWidget {
  final DashboardData data;

  const RankingScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final topList = data.topRanked;
    final top3 = topList.take(3).toList();
    final rest = topList.length > 3 ? topList.sublist(3) : <RankingUser>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandHeader(),
              const SizedBox(height: 16),
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
                    'Ranking de la Comunidad',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: EdgeInsets.only(left: Navigator.of(context).canPop() ? 28 : 0),
                child: const Text(
                  'Top 10 recicladores con mayor impacto y puntos ganados.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 20),

              if (topList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      'No hay usuarios registrados en el ranking aún.',
                      style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                    ),
                  ),
                )
              else ...[
                // Podio de los 3 primeros lugares
                _PodiumSection(
                  top3: top3,
                  currentUserId: data.user.id,
                ),
                const SizedBox(height: 24),

                // Lista de puestos del 4 al 10
                if (rest.isNotEmpty) ...[
                  const Text(
                    'Posiciones siguientes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rest.length,
                    separatorBuilder: (_, ___) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final user = rest[index];
                      final isCurrentUser = user.idUser == data.user.id;
                      return _RankUserTile(
                        user: user,
                        isCurrentUser: isCurrentUser,
                      );
                    },
                  ),
                ],
              ],

              const SizedBox(height: 20),
              // Tarjeta fija con la posición del usuario actual
              _MyPositionBanner(
                position: data.rankingPosition,
                userName: data.user.name,
                points: data.user.points,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumSection extends StatelessWidget {
  final List<RankingUser> top3;
  final int currentUserId;

  const _PodiumSection({
    required this.top3,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    RankingUser? first = top3.isNotEmpty ? top3[0] : null;
    RankingUser? second = top3.length > 1 ? top3[1] : null;
    RankingUser? third = top3.length > 2 ? top3[2] : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_rounded, color: AppColors.orange, size: 22),
              SizedBox(width: 6),
              Text(
                'PODIO DE HONOR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.orange,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2do Lugar (Plata)
              Expanded(
                child: second != null
                    ? _PodiumColumn(
                        user: second,
                        position: 2,
                        podiumHeight: 90,
                        medalColor: const Color(0xFFC0C0C0), // Plata
                        medalIcon: '🥈',
                        isCurrentUser: second.idUser == currentUserId,
                      )
                    : const SizedBox.shrink(),
              ),

              // 1er Lugar (Oro)
              Expanded(
                child: first != null
                    ? _PodiumColumn(
                        user: first,
                        position: 1,
                        podiumHeight: 120,
                        medalColor: const Color(0xFFFFD700), // Oro
                        medalIcon: '🥇',
                        isCurrentUser: first.idUser == currentUserId,
                      )
                    : const SizedBox.shrink(),
              ),

              // 3er Lugar (Bronce)
              Expanded(
                child: third != null
                    ? _PodiumColumn(
                        user: third,
                        position: 3,
                        podiumHeight: 75,
                        medalColor: const Color(0xFFCD7F32), // Bronce
                        medalIcon: '🥉',
                        isCurrentUser: third.idUser == currentUserId,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  final RankingUser user;
  final int position;
  final double podiumHeight;
  final Color medalColor;
  final String medalIcon;
  final bool isCurrentUser;

  const _PodiumColumn({
    required this.user,
    required this.position,
    required this.podiumHeight,
    required this.medalColor,
    required this.medalIcon,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = position == 1 ? 58.0 : 48.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          medalIcon,
          style: TextStyle(fontSize: position == 1 ? 26 : 22),
        ),
        const SizedBox(height: 4),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: medalColor,
                  width: position == 1 ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: medalColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                user.initials,
                style: TextStyle(
                  fontSize: position == 1 ? 18 : 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (isCurrentUser)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'TÚ',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          user.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: position == 1 ? 12 : 11,
            fontWeight: FontWeight.w700,
            color: isCurrentUser ? AppColors.orange : AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${user.points.toStringAsFixed(0)} pts',
          style: TextStyle(
            fontSize: position == 1 ? 12 : 10.5,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
          ),
        ),
        const SizedBox(height: 8),

        // Base del podio
        Container(
          height: podiumHeight,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: medalColor.withValues(alpha: 0.25),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: medalColor.withValues(alpha: 0.5)),
          ),
          alignment: Alignment.center,
          child: Text(
            '#$position',
            style: TextStyle(
              fontSize: position == 1 ? 22 : 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

class _RankUserTile extends StatelessWidget {
  final RankingUser user;
  final bool isCurrentUser;

  const _RankUserTile({
    required this.user,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentUser ? AppColors.greenSoft : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrentUser ? AppColors.green : AppColors.border,
          width: isCurrentUser ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '#${user.position}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isCurrentUser ? AppColors.green : AppColors.textGrey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrentUser ? Colors.white : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Text(
              user.initials,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Tú',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${user.totalWeightKg.toStringAsFixed(1)} kg reciclados',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${user.points.toStringAsFixed(0)} pts',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class _MyPositionBanner extends StatelessWidget {
  final int? position;
  final String userName;
  final double points;

  const _MyPositionBanner({
    required this.position,
    required this.userName,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.orangeSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_circle_outlined,
                color: AppColors.orange,
                size: 24,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu estado actual',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.orange,
                    ),
                  ),
                  Text(
                    position == null ? 'Sin clasificar aún' : 'Puesto #$position en el campus',
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
          Text(
            '${points.toStringAsFixed(0)} pts',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
