import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/models/app_user.dart';
import 'package:frontendmovil/models/dashboard_data.dart';
import 'package:frontendmovil/models/delivery.dart';

void main() {
  test('parses the authenticated user returned by the API', () {
    final user = AppUser.fromJson({
      'id_user': 4,
      'cod_user': '00001004',
      'nombre': 'Ana Pérez',
      'puntos': 15.5,
      'tipo': 'usuario',
      'estado': true,
    });

    expect(user.code, '00001004');
    expect(user.initials, 'AP');
    expect(user.points, 15.5);
  });

  test('parses history entries and derives points from the API tariff', () {
    final delivery = Delivery.fromJson({
      'idHistorial': 10,
      'fecha': '2026-10-17',
      'idTacho': 1,
      'residuo': {'tipo': 'plastico', 'peso': 0.25},
    });

    expect(delivery.material, 'Plástico');
    expect(delivery.kg, 0.25);
    expect(delivery.points, 2.5);
    expect(delivery.tachoId, 1);
  });

  test('parses metrics from the documented API response', () {
    final metrics = UserMetrics.fromJson({
      'totalResiduos': 14,
      'pesoTotalKg': 6.3,
      'porTipo': [],
      'porPeriodo': [],
      'porTipoYPeriodo': [],
    });

    expect(metrics.totalDeliveries, 14);
    expect(metrics.totalWeightKg, 6.3);
  });
}
