import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wave/core/models/vehicle_model.dart';
import 'package:wave/core/providers/customer_provider.dart';

final vehicleManagementProvider = AsyncNotifierProvider<VehicleManagementNotifier, List<VehicleModel>>(() {
  return VehicleManagementNotifier();
});

class VehicleManagementNotifier extends AsyncNotifier<List<VehicleModel>> {
  @override
  Future<List<VehicleModel>> build() async {
    final repo = ref.watch(customerRepositoryProvider);
    return repo.getMyVehicles();
  }

  Future<void> addVehicle(String vehicleTypeId, String licensePlate, {String color = '', String brand = '', String model = ''}) async {
    final repo = ref.read(customerRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.addVehicle(vehicleTypeId, licensePlate, color: color, brand: brand, model: model);
      return repo.getMyVehicles();
    });
  }

  Future<void> removeVehicle(String id) async {
    final repo = ref.read(customerRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.removeVehicle(id);
      return repo.getMyVehicles();
    });
  }

  Future<void> setDefaultVehicle(String id) async {
    final repo = ref.read(customerRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.setDefaultVehicle(id);
      return repo.getMyVehicles();
    });
  }
}

final vehicleTypesProvider = FutureProvider((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  return repo.getVehicleTypes();
});
