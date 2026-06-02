class LoyaltyModel {
  final String id;
  final String customerId;
  final String tierConfigId;
  final String tierName;
  final num pointsBalance;
  final int successfulWashesTowardVoucher;
  final int totalSuccessfulWashes;

  LoyaltyModel({
    required this.id,
    required this.customerId,
    required this.tierConfigId,
    required this.tierName,
    required this.pointsBalance,
    required this.successfulWashesTowardVoucher,
    required this.totalSuccessfulWashes,
  });

  factory LoyaltyModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      tierConfigId: json['tierConfigId'] ?? '',
      tierName: json['tierName'] ?? 'None',
      pointsBalance: json['pointsBalance'] ?? 0,
      successfulWashesTowardVoucher: json['successfulWashesTowardVoucher'] ?? 0,
      totalSuccessfulWashes: json['totalSuccessfulWashes'] ?? 0,
    );
  }
}
