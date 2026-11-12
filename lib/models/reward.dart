class Reward {
  final int id;
  final String name;
  final String description;
  final double cost;
  final int stock;

  const Reward({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.stock,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_premio'] ?? json['id'] ?? 0;
    final rawCost = json['costo'] ?? 0;
    final rawStock = json['stock'] ?? 0;

    return Reward(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      name: (json['nombre'] as String?)?.trim() ?? 'Premio',
      description: (json['descripcion'] as String?)?.trim() ?? '',
      cost: rawCost is num ? rawCost.toDouble() : double.tryParse('$rawCost') ?? 0.0,
      stock: rawStock is int ? rawStock : int.tryParse('$rawStock') ?? 0,
    );
  }

  bool get isAvailable => stock > 0;
}

class ClaimedReward {
  final int id;
  final int rewardId;
  final String rewardName;
  final double cost;
  final String claimedDate;
  final String status; // 'Pendiente de recojo', 'Entregado'

  const ClaimedReward({
    required this.id,
    required this.rewardId,
    required this.rewardName,
    required this.cost,
    required this.claimedDate,
    this.status = 'Pendiente de recojo',
  });

  factory ClaimedReward.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_usuario_premio'] ?? json['id'] ?? 0;
    final rawRewardId = json['id_premio'] ?? 0;
    final rawCost = json['costo'] ?? 0.0;

    return ClaimedReward(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      rewardId: rawRewardId is int ? rawRewardId : int.tryParse('$rawRewardId') ?? 0,
      rewardName: (json['nombre'] ?? json['nombrePremio'] ?? 'Premio').toString(),
      cost: rawCost is num ? rawCost.toDouble() : double.tryParse('$rawCost') ?? 0.0,
      claimedDate: (json['fecha_obtencion'] ?? json['fecha'] ?? '').toString(),
      status: (json['estado'] ?? 'Pendiente de recojo').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id_usuario_premio': id,
    'id_premio': rewardId,
    'nombre': rewardName,
    'costo': cost,
    'fecha_obtencion': claimedDate,
    'estado': status,
  };
}
