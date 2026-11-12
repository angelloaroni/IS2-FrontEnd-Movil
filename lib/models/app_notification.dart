import 'package:flutter/material.dart';

class AppNotification {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String message;
  final DateTime date;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.date,
    required this.isRead,
  });

  AppNotification copyWith({
    int? id,
    int? userId,
    String? type,
    String? title,
    String? message,
    DateTime? date,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final idVal = json['id_notificacion'] ?? json['id'] ?? 0;
    final userVal = json['id_user'] ?? 0;
    final dateStr = json['fecha'] as String?;

    return AppNotification(
      id: idVal is int ? idVal : int.tryParse('$idVal') ?? 0,
      userId: userVal is int ? userVal : int.tryParse('$userVal') ?? 0,
      type: (json['tipo'] as String?)?.trim() ?? 'sistema',
      title: (json['titulo'] as String?)?.trim() ?? 'Notificación',
      message: (json['mensaje'] as String?)?.trim() ?? '',
      date: dateStr != null ? (DateTime.tryParse(dateStr) ?? DateTime.now()) : DateTime.now(),
      isRead: json['leida'] == true,
    );
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'reciclaje':
        return Icons.recycling_rounded;
      case 'logro':
        return Icons.military_tech_rounded;
      case 'ranking':
        return Icons.emoji_events_rounded;
      case 'premio':
        return Icons.card_giftcard_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color get iconColor {
    switch (type.toLowerCase()) {
      case 'reciclaje':
        return const Color(0xFF1E8449);
      case 'logro':
      case 'ranking':
      case 'premio':
        return const Color(0xFFF15A24);
      default:
        return const Color(0xFF2C3E50);
    }
  }

  String get formattedDate {
    final local = date.toLocal();
    final now = DateTime.now();
    final difference = now.difference(local);

    if (difference.inMinutes < 1) {
      return 'Hace un momento';
    } else if (difference.inHours < 1) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else {
      return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    }
  }
}
