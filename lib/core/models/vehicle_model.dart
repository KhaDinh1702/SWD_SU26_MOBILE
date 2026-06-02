class VehicleModel {
  final String id;
  final String customerId;
  final String ownerName;
  final String ownerPhone;
  final String vehicleTypeId;
  final String vehicleTypeName;
  final String licensePlate;
  final String nickname;
  final String brand;
  final String model;
  final String color;
  final bool isDefault;
  final bool isActive;

  VehicleModel({
    required this.id,
    required this.customerId,
    this.ownerName = '',
    this.ownerPhone = '',
    required this.vehicleTypeId,
    this.vehicleTypeName = '',
    required this.licensePlate,
    this.nickname = '',
    this.brand = '',
    this.model = '',
    this.color = '',
    required this.isDefault,
    required this.isActive,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      customerId: json['customerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      ownerPhone: json['ownerPhone'] ?? '',
      vehicleTypeId: json['vehicleTypeId'] ?? '',
      vehicleTypeName: json['vehicleTypeName'] ?? '',
      licensePlate: json['licensePlate'] ?? '',
      nickname: json['nickname'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      color: json['color'] ?? '',
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
}

class VehicleTypeModel {
  final String id;
  final String name;
  final String description;
  final bool isActive;

  VehicleTypeModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.isActive,
  });

  factory VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }
}
