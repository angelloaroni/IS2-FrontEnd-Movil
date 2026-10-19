class AppUser {
  final int id;
  final String code;
  final String name;
  final double points;
  final String type;
  final bool active;

  const AppUser({
    required this.id,
    required this.code,
    required this.name,
    required this.points,
    required this.type,
    required this.active,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final id = json['id_user'];
    final code = json['cod_user'];
    final name = json['nombre'];
    final points = json['puntos'];
    final type = json['tipo'];
    final active = json['estado'];
    if (id is! num ||
        code is! String ||
        name is! String ||
        points is! num ||
        type is! String ||
        active is! bool) {
      throw const FormatException('El servidor devolvió un usuario inválido.');
    }
    return AppUser(
      id: id.toInt(),
      code: code,
      name: name,
      points: points.toDouble(),
      type: type,
      active: active,
    );
  }

  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    return words.length == 1
        ? words.first.substring(0, 1).toUpperCase()
        : '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}
