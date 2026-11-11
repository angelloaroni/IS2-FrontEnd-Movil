import 'package:flutter_test/flutter_test.dart';
import 'package:frontendmovil/models/recycling_point.dart';

void main() {
  test('interpreta un tacho del backend, incluso con números como texto', () {
    final point = RecyclingPoint.tryParse({
      'idTacho': 1,
      'tipo': 'papel/carton',
      'latitud': '-12.0464',
      'longitud': -77.0428,
      'capacidad': true,
      'porcentaje': '80.5',
      'distanciaM': 1250,
    });

    expect(point, isNotNull);
    expect(point!.latitude, -12.0464);
    expect(point.isFull, isTrue);
    expect(point.typeLabel, 'Papel y cartón');
    expect(point.distanceLabel, '1.3 km');
  });

  test('descarta tachos sin coordenadas válidas', () {
    expect(
      RecyclingPoint.tryParse({'idTacho': 2, 'latitud': null, 'longitud': 1}),
      isNull,
    );
    expect(
      RecyclingPoint.tryParse({'idTacho': 2, 'latitud': 99, 'longitud': 1}),
      isNull,
    );
  });
}
