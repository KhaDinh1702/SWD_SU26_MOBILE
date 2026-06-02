class TierConfigModel {
  final String id;
  final String tierName;
  final num minLoyaltyPoints;
  final num bookingWindowDays;
  final num priorityLevel;
  final num pointsPer1000Vnd;
  final num discountPercent;
  final bool isActive;

  TierConfigModel({
    required this.id,
    required this.tierName,
    required this.minLoyaltyPoints,
    required this.bookingWindowDays,
    required this.priorityLevel,
    required this.pointsPer1000Vnd,
    required this.discountPercent,
    required this.isActive,
  });

  factory TierConfigModel.fromJson(Map<String, dynamic> json) {
    return TierConfigModel(
      id: json['id'] ?? '',
      tierName: json['tierName'] ?? 'None',
      minLoyaltyPoints: json['minLoyaltyPoints'] ?? 0,
      bookingWindowDays: json['bookingWindowDays'] ?? 0,
      priorityLevel: json['priorityLevel'] ?? 0,
      pointsPer1000Vnd: json['pointsPer1000Vnd'] ?? 0,
      discountPercent: json['discountPercent'] ?? 0,
      isActive: json['isActive'] ?? true,
    );
  }
}
