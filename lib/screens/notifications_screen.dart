import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/brand_header.dart';

class NotificationsScreen extends StatefulWidget {
  final List<AppNotification> notifications;
  final VoidCallback? onReviewed;

  const NotificationsScreen({
    super.key,
    required this.notifications,
    this.onReviewed,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _markRead();
  }

  Future<void> _markRead() async {
    await ApiService.instance.markNotificationsAsRead(widget.notifications);
    widget.onReviewed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                        'Notificaciones',
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
                      'Historial de avisos de reciclaje, logros y sistema.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: widget.notifications.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: AppColors.greenSoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none_rounded,
                                size: 32,
                                color: AppColors.green,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No tienes notificaciones',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Cuando recicles en un tacho inteligente o ganes logros, tus avisos aparecerán aquí.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      itemCount: widget.notifications.length,
                      separatorBuilder: (_, ___) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = widget.notifications[index];
                        return _NotificationCard(notification: item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRecycle = notification.type.toLowerCase() == 'reciclaje';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRecycle ? AppColors.greenSoft.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecycle
              ? AppColors.green.withValues(alpha: 0.4)
              : AppColors.border,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: notification.iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              notification.icon,
              color: notification.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Text(
                      notification.formattedDate,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textDark,
                    height: 1.3,
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
