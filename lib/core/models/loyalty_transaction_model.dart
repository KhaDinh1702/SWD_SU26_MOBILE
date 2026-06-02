class LoyaltyTransactionModel {
  final String id;
  final String type; // e.g. "earn", "redeem", "tier_upgrade"
  final num points;
  final String description;
  final String createdAt;

  LoyaltyTransactionModel({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.createdAt,
  });

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class LoyaltyTransactionListResponse {
  final List<LoyaltyTransactionModel> items;
  final int total;

  LoyaltyTransactionListResponse({
    required this.items,
    required this.total,
  });

  factory LoyaltyTransactionListResponse.fromJson(Map<String, dynamic> json) {
    final list = json['items'] as List? ?? json['data'] as List? ?? [];
    return LoyaltyTransactionListResponse(
      items: list.map((e) => LoyaltyTransactionModel.fromJson(e)).toList(),
      total: json['total'] ?? list.length,
    );
  }
}
