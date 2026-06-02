class VoucherModel {
  final String id;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String code;
  final String type;
  final String status;
  final num discountCapVnd;
  final String expiresAt;
  final String grantedReason;
  final String usedAt;
  final String usedOrderId;

  VoucherModel({
    required this.id,
    required this.customerId,
    this.customerName = '',
    this.customerEmail = '',
    required this.code,
    required this.type,
    required this.status,
    required this.discountCapVnd,
    required this.expiresAt,
    this.grantedReason = '',
    this.usedAt = '',
    this.usedOrderId = '',
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? 'unused',
      discountCapVnd: json['discountCapVnd'] ?? 0,
      expiresAt: json['expiresAt'] ?? '',
      grantedReason: json['grantedReason'] ?? '',
      usedAt: json['usedAt'] ?? '',
      usedOrderId: json['usedOrderId'] ?? '',
    );
  }
}
