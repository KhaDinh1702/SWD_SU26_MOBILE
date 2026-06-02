class ServiceTypeModel {
  final String id;
  final String name;
  final String description;
  final String basePrice;
  final int estimatedMinutes;
  final num pointsMultiplier;
  final List<String> checklistTemplate;
  final bool isVoucherEligible;
  final bool isActive;

  ServiceTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.estimatedMinutes,
    required this.pointsMultiplier,
    required this.checklistTemplate,
    required this.isVoucherEligible,
    required this.isActive,
  });

  factory ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return ServiceTypeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      basePrice: json['basePrice'] ?? '0',
      estimatedMinutes: json['estimatedMinutes'] ?? 0,
      pointsMultiplier: json['pointsMultiplier'] ?? 1.0,
      checklistTemplate: List<String>.from(json['checklistTemplate'] ?? []),
      isVoucherEligible: json['isVoucherEligible'] ?? true,
      isActive: json['isActive'] ?? true,
    );
  }
}
