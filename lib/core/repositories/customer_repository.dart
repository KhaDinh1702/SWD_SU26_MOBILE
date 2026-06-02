import 'package:wave/core/models/loyalty_model.dart';
import 'package:wave/core/models/loyalty_transaction_model.dart';
import 'package:wave/core/models/order_model.dart';
import 'package:wave/core/models/service_model.dart';
import 'package:wave/core/models/tier_config_model.dart';
import 'package:wave/core/models/vehicle_model.dart';
import 'package:wave/core/models/voucher_model.dart';
import 'package:wave/core/network/api/customer_api.dart';

class CustomerRepository {
  final CustomerApi _api;

  CustomerRepository(this._api);

  Future<LoyaltyModel> getLoyalty() => _api.getLoyalty();
  
  Future<List<ServiceTypeModel>> getServiceTypes() => _api.getServiceTypes();
  
  Future<List<TierConfigModel>> getTierConfigs() => _api.getTierConfigs();
  
  Future<List<VehicleModel>> getMyVehicles() => _api.getMyVehicles();
  
  Future<List<VehicleTypeModel>> getVehicleTypes() => _api.getVehicleTypes();
  
  Future<List<AvailableSlotModel>> getAvailableSlots(String serviceTypeId, String from, String to) =>
      _api.getAvailableSlots(serviceTypeId, from, to);
      
  Future<PreviewOrderResponseModel> previewOrder(String serviceTypeId, String scheduledAt, String? voucherId) =>
      _api.previewOrder(serviceTypeId, scheduledAt, voucherId);
      
  Future<OrderModel> createOrder({
    required String vehicleId,
    required String serviceTypeId,
    required String scheduledAt,
    required String paymentMethod,
    String? voucherId,
    String note = '',
  }) => _api.createOrder(vehicleId, serviceTypeId, scheduledAt, paymentMethod, voucherId, note);

  Future<List<OrderModel>> getMyOrders() => _api.getMyOrders();

  Future<OrderModel> rescheduleOrder(String orderId, String staffShiftId, String scheduledAt) =>
      _api.rescheduleOrder(orderId, staffShiftId, scheduledAt);
      
  Future<OrderModel> cancelOrder(String orderId, String reason) =>
      _api.cancelOrder(orderId, reason);

  Future<List<VoucherModel>> getMyVouchers({String? status}) => _api.getMyVouchers(status: status);

  // --- NEW: Vehicle Management ---
  Future<VehicleModel> addVehicle(String vehicleTypeId, String licensePlate, {String color = '', String brand = '', String model = ''}) => 
      _api.addVehicle(vehicleTypeId, licensePlate, color: color, brand: brand, model: model);

  Future<void> removeVehicle(String id) => _api.removeVehicle(id);

  Future<VehicleModel> setDefaultVehicle(String id) => _api.setDefaultVehicle(id);

  // --- NEW: Loyalty Transactions ---
  Future<LoyaltyTransactionListResponse> getLoyaltyTransactions({int page = 1, int limit = 20}) => 
      _api.getLoyaltyTransactions(page: page, limit: limit);
}
