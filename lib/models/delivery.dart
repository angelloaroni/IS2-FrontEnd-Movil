import 'package:flutter/material.dart';

class Delivery {
  final String material;
  final String date;
  final double kg;
  final int tachoId;
  final IconData icon;

  const Delivery({
    required this.material,
    required this.date,
    required this.kg,
    required this.tachoId,
    this.icon = Icons.recycling,
  });

  factory Delivery.fromJson(Map<String, dynamic> json) {
    final waste = json['residuo'];
    if (waste is! Map<String, dynamic> ||
        waste['tipo'] is! String ||
        waste['peso'] is! num ||
        json['fecha'] is! String ||
        json['idTacho'] is! num) {
      throw const FormatException('El servidor devolvió un registro inválido.');
    }

    final type = waste['tipo'] as String;
    final normalizedType = type.toLowerCase();
    return Delivery(
      material: _displayType(type),
      date: _displayDate(json['fecha'] as String),
      kg: (waste['peso'] as num).toDouble(),
      tachoId: (json['idTacho'] as num).toInt(),
      icon: normalizedType.contains('plast')
          ? Icons.local_drink_outlined
          : normalizedType.contains('papel') ||
                normalizedType.contains('carton')
          ? Icons.description_outlined
          : normalizedType.contains('organ')
          ? Icons.compost_outlined
          : Icons.recycling,
    );
  }

  double get points => kg * 10;

  static String _displayType(String type) {
    switch (type.toLowerCase()) {
      case 'plastico':
        return 'Plástico';
      case 'papel/carton':
        return 'Papel y cartón';
      case 'organicos':
        return 'Orgánicos';
      default:
        return type;
    }
  }

  static String _displayDate(String rawDate) {
    final date = DateTime.tryParse(rawDate);
    if (date == null) return rawDate;
    final localDate = date.toLocal();
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}';
  }
}
