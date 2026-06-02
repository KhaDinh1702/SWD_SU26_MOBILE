class OrderModel {
  final String id;
  final String customerId;
  final String vehicleId;
  final String serviceTypeId;
  final String customerName;
  final String licensePlate;
  final String serviceName;
  final String staffShiftId;
  final String scheduledAt;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final num amount;
  final num originalAmount;
  final num discountAmount;
  final num discountPercent;
  final String discountReason;
  final String voucherId;
  final String cancelReason;
  final String note;
  final String payosCheckoutUrl;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.vehicleId,
    required this.serviceTypeId,
    this.customerName = '',
    this.licensePlate = '',
    this.serviceName = '',
    this.staffShiftId = '',
    required this.scheduledAt,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    required this.originalAmount,
    this.discountAmount = 0,
    this.discountPercent = 0,
    this.discountReason = '',
    this.voucherId = '',
    this.cancelReason = '',
    this.note = '',
    this.payosCheckoutUrl = '',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      serviceTypeId: json['serviceTypeId'] ?? '',
      customerName: json['customerName'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      serviceName: json['serviceName'] ?? '',
      staffShiftId: json['staffShiftId'] ?? '',
      scheduledAt: json['scheduledAt'] ?? '',
      status: json['status'] ?? 'pending_payment',
      paymentMethod: json['paymentMethod'] ?? 'online',
      paymentStatus: json['paymentStatus'] ?? 'unpaid',
      amount: json['amount'] ?? 0,
      originalAmount: json['originalAmount'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      discountPercent: json['discountPercent'] ?? 0,
      discountReason: json['discountReason'] ?? '',
      voucherId: json['voucherId'] ?? '',
      cancelReason: json['cancelReason'] ?? '',
      note: json['note'] ?? '',
      payosCheckoutUrl: json['payosCheckoutUrl'] ?? '',
    );
  }
}

class AvailableSlotModel {
  final String scheduledAt;
  final num remainingCapacity;
  final bool isGoldenHour;
  final num discountPercent;

  AvailableSlotModel({
    required this.scheduledAt,
    required this.remainingCapacity,
    required this.isGoldenHour,
    required this.discountPercent,
  });

  factory AvailableSlotModel.fromJson(Map<String, dynamic> json) {
    return AvailableSlotModel(
      scheduledAt: json['scheduledAt'] ?? '',
      remainingCapacity: json['remainingCapacity'] ?? 0,
      isGoldenHour: json['isGoldenHour'] ?? false,
      discountPercent: json['discountPercent'] ?? 0,
    );
  }
}

class PreviewOrderResponseModel {
  final num originalAmount;
  final num discountAmount;
  final num discountPercent;
  final String discountReason;
  final num amount;
  final bool isGoldenHour;
  final String tierName;
  final num tierDiscountPercent;
  final num voucherDiscountCapVnd;
  final String voucherError;

  PreviewOrderResponseModel({
    required this.originalAmount,
    required this.discountAmount,
    required this.discountPercent,
    this.discountReason = '',
    required this.amount,
    required this.isGoldenHour,
    required this.tierName,
    required this.tierDiscountPercent,
    this.voucherDiscountCapVnd = 0,
    this.voucherError = '',
  });

  factory PreviewOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return PreviewOrderResponseModel(
      originalAmount: json['originalAmount'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      discountPercent: json['discountPercent'] ?? 0,
      discountReason: json['discountReason'] ?? '',
      amount: json['amount'] ?? 0,
      isGoldenHour: json['isGoldenHour'] ?? false,
      tierName: json['tierName'] ?? 'None',
      tierDiscountPercent: json['tierDiscountPercent'] ?? 0,
      voucherDiscountCapVnd: json['voucherDiscountCapVnd'] ?? 0,
      voucherError: json['voucherError'] ?? '',
    );
  }
}
