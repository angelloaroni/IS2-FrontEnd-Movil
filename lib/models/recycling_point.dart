class RecyclingPoint {
  final int id;
  final String? type;
  final double latitude;
  final double longitude;
  final bool isFull;
  final double? fillPercent;
  final double? distanceM;

  const RecyclingPoint({
    required this.id,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.isFull,
    this.fillPercent,
    this.distanceM,
  });

  /// Devuelve null si el JSON no trae un id o unas coordenadas válidas.
  static RecyclingPoint? tryParse(Map<String, dynamic> json) {
    final id = _toNum(json['idTacho'])?.toInt();
    final lat = _toNum(json['latitud'])?.toDouble();
    final lng = _toNum(json['longitud'])?.toDouble();
    if (id == null || lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;

    final type = json['tipo'];
    return RecyclingPoint(
      id: id,
      type: type is String && type.trim().isNotEmpty ? type.trim() : null,
      latitude: lat,
      longitude: lng,
      isFull: json['capacidad'] == true,
      fillPercent: _toNum(json['porcentaje'])?.toDouble(),
      distanceM: _toNum(json['distanciaM'])?.toDouble(),
    );
  }

  RecyclingPoint withDistance(double meters) => RecyclingPoint(
    id: id,
    type: type,
    latitude: latitude,
    longitude: longitude,
    isFull: isFull,
    fillPercent: fillPercent,
    distanceM: meters,
  );

  String get typeLabel => switch (type) {
    null => 'Tacho inteligente',
    'plastico' => 'Plástico',
    'pet' => 'PET',
    'papel' => 'Papel',
    'carton' => 'Cartón',
    'papel/carton' => 'Papel y cartón',
    'vidrio' => 'Vidrio',
    'organicos' => 'Orgánicos',
    final other => other,
  };

  String get statusLabel => isFull ? 'Lleno' : 'Disponible';

  String get distanceLabel {
    final d = distanceM;
    if (d == null) return '';
    return d < 1000
        ? '${d.round()} m'
        : '${(d / 1000).toStringAsFixed(1)} km';
  }

  // PostgreSQL puede devolver DECIMAL como texto, por eso se acepta String.
  static num? _toNum(dynamic value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}
