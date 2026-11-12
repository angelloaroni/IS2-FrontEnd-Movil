import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/models/achievement.dart';
import 'package:frontendmovil/screens/achievements_screen.dart';
import 'package:flutter/material.dart';

void main() {
  test('Achievement.fromJson parses backend payload correctly with description fallback', () {
    final backendPayload = {
      'id_logro': 1,
      'nombre': 'Reciclador Novato',
      'tipo_condicion': 'cantidad_residuos',
      'valor_objetivo': 5.0,
      'fecha_obtencion': '2026-06-01',
    };

    final achievement = Achievement.fromJson(backendPayload);

    expect(achievement.id, '1');
    expect(achievement.title, 'Reciclador Novato');
    expect(achievement.conditionType, 'cantidad_residuos');
    expect(achievement.targetValue, 5.0);
    expect(achievement.earnedDate, '2026-06-01');
    expect(achievement.isUnlocked, isTrue);
    expect(achievement.description, contains('Recicla 5 residuos'));
  });

  test('Achievement.fromJson handles peso_total_kg and puntos_acumulados', () {
    final pesoPayload = {
      'id_logro': 3,
      'nombre': 'Guardián del Planeta',
      'tipo_condicion': 'peso_total_kg',
      'valor_objetivo': 10.0,
    };
    final achievementPeso = Achievement.fromJson(pesoPayload);
    expect(achievementPeso.description, contains('10.0 kg'));

    final puntosPayload = {
      'id_logro': 2,
      'nombre': 'Eco Amigo',
      'tipo_condicion': 'puntos_acumulados',
      'valor_objetivo': 100.0,
    };
    final achievementPuntos = Achievement.fromJson(puntosPayload);
    expect(achievementPuntos.description, contains('100 puntos'));
  });
}
