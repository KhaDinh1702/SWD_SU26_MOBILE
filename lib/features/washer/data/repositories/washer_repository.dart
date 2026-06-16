import 'package:wave/features/washer/data/models/washer_order_model.dart';
import 'package:wave/features/washer/data/repositories/washer_api.dart';

class WasherRepository {
  final WasherApi _api;

  WasherRepository(this._api);

  Future<List<WasherOrderModel>> getWorkOrders() {
    return _api.getWorkOrders();
  }

  Future<WasherOrderModel> getWorkOrder(String id) {
    return _api.getWorkOrder(id);
  }

  Future<WasherOrderModel> startWorkOrder(String id) {
    return _api.startWorkOrder(id);
  }

  Future<WasherOrderModel> finishWorkOrder(
      String id, List<String> checkoutPhotoUrls) {
    return _api.finishWorkOrder(id, checkoutPhotoUrls);
  }
}
