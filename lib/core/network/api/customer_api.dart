import 'package:dio/dio.dart';
import 'package:wave/core/models/loyalty_model.dart';
import 'package:wave/core/models/loyalty_transaction_model.dart';
import 'package:wave/core/models/order_model.dart';
import 'package:wave/core/models/service_model.dart';
import 'package:wave/core/models/tier_config_model.dart';
import 'package:wave/core/models/vehicle_model.dart';
import 'package:wave/core/models/voucher_model.dart';
import 'package:wave/core/network/api_enpoints.dart';

class CustomerApi {
  final Dio dio;

  CustomerApi(this.dio);

  Future<LoyaltyModel> getLoyalty() async {
    final response = await dio.get(ApiEndpoints.loyalty);
    return LoyaltyModel.fromJson(response.data);
  }

  Future<List<ServiceTypeModel>> getServiceTypes() async {
    final response = await dio.get(ApiEndpoints.serviceTypes);
    final data = response.data as List;
    return data.map((e) => ServiceTypeModel.fromJson(e)).toList();
  }

  Future<List<TierConfigModel>> getTierConfigs() async {
    final response = await dio.get(ApiEndpoints.tierConfigs);
    final data = response.data as List;
    return data.map((e) => TierConfigModel.fromJson(e)).toList();
  }

  Future<List<VehicleModel>> getMyVehicles() async {
    final response = await dio.get(ApiEndpoints.myVehicles);
    final data = response.data as List;
    return data.map((e) => VehicleModel.fromJson(e)).toList();
  }

  Future<List<VehicleTypeModel>> getVehicleTypes() async {
    final response = await dio.get(ApiEndpoints.vehicleTypes);
    final data = response.data as List;
    return data.map((e) => VehicleTypeModel.fromJson(e)).toList();
  }

  Future<List<AvailableSlotModel>> getAvailableSlots(
      String serviceTypeId, String from, String to) async {
    final response = await dio.get(
      ApiEndpoints.availableSlots,
      queryParameters: {
        'serviceTypeId': serviceTypeId,
        'from': from,
        'to': to,
      },
    );
    final data = response.data as List;
    return data.map((e) => AvailableSlotModel.fromJson(e)).toList();
  }

  Future<PreviewOrderResponseModel> previewOrder(
      String serviceTypeId, String scheduledAt, String? voucherId) async {
    final Map<String, dynamic> body = {
      'serviceTypeId': serviceTypeId,
      'scheduledAt': scheduledAt,
    };
    if (voucherId != null && voucherId.isNotEmpty) {
      body['voucherId'] = voucherId;
    }
    final response = await dio.post(
      ApiEndpoints.previewOrder,
      data: body,
    );
    return PreviewOrderResponseModel.fromJson(response.data);
  }

  Future<OrderModel> createOrder(
      String vehicleId, String serviceTypeId, String scheduledAt, String paymentMethod, String? voucherId, String note) async {
    final Map<String, dynamic> body = {
      'vehicleId': vehicleId,
      'serviceTypeId': serviceTypeId,
      'scheduledAt': scheduledAt,
      'paymentMethod': paymentMethod,
    };
    if (voucherId != null && voucherId.isNotEmpty) body['voucherId'] = voucherId;
    if (note.isNotEmpty) body['note'] = note;
    
    final response = await dio.post(
      ApiEndpoints.orders,
      data: body,
    );
    return OrderModel.fromJson(response.data);
  }

  Future<List<OrderModel>> getMyOrders() async {
    final response = await dio.get(ApiEndpoints.orders);
    final data = response.data as List;
    return data.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<OrderModel> rescheduleOrder(String orderId, String staffShiftId, String scheduledAt) async {
    final response = await dio.patch(
      '${ApiEndpoints.orders}/$orderId/reschedule',
      data: {
        'staffShiftId': staffShiftId,
        'scheduledAt': scheduledAt,
      },
    );
    return OrderModel.fromJson(response.data);
  }

  Future<OrderModel> cancelOrder(String orderId, String reason) async {
    final response = await dio.patch(
      '${ApiEndpoints.orders}/$orderId/cancel',
      data: {'reason': reason},
    );
    return OrderModel.fromJson(response.data);
  }

  Future<List<VoucherModel>> getMyVouchers({String? status}) async {
    final response = await dio.get(
      ApiEndpoints.myVouchers,
      queryParameters: status != null ? {'status': status} : null,
    );
    final data = response.data as List;
    return data.map((e) => VoucherModel.fromJson(e)).toList();
  }

  // --- NEW: Vehicle Management ---
  Future<VehicleModel> addVehicle(String vehicleTypeId, String licensePlate, {String color = '', String brand = '', String model = ''}) async {
    final response = await dio.post(
      ApiEndpoints.myVehicles,
      data: {
        'vehicleTypeId': vehicleTypeId,
        'licensePlate': licensePlate,
        if (color.isNotEmpty) 'color': color,
        if (brand.isNotEmpty) 'brand': brand,
        if (model.isNotEmpty) 'model': model,
      },
    );
    return VehicleModel.fromJson(response.data);
  }

  Future<void> removeVehicle(String id) async {
    await dio.delete('${ApiEndpoints.myVehicles}/$id');
  }

  Future<VehicleModel> setDefaultVehicle(String id) async {
    final response = await dio.patch('${ApiEndpoints.myVehicles}/$id/set-default');
    return VehicleModel.fromJson(response.data);
  }

  // --- NEW: Loyalty Transactions ---
  Future<LoyaltyTransactionListResponse> getLoyaltyTransactions({int page = 1, int limit = 20}) async {
    final response = await dio.get(
      '${ApiEndpoints.loyalty}/transactions',
      queryParameters: {'page': page, 'limit': limit},
    );
    return LoyaltyTransactionListResponse.fromJson(response.data);
  }
}
