import 'package:dio/dio.dart';
import 'package:wave/core/network/api_enpoints.dart';
import 'package:wave/features/washer/data/models/washer_order_model.dart';

class WasherApi {
  final Dio _dio;

  WasherApi(this._dio);

  Future<List<WasherOrderModel>> getWorkOrders() async {
    final response = await _dio.get(ApiEndpoints.workOrders);
    final data = response.data as List;
    return data
        .map((e) => WasherOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WasherOrderModel> getWorkOrder(String id) async {
    final response = await _dio.get('${ApiEndpoints.workOrders}/$id');
    return WasherOrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<WasherOrderModel> startWorkOrder(String id) async {
    final response = await _dio.patch('${ApiEndpoints.workOrders}/$id/start');
    return WasherOrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Cập nhật một mục checklist theo vị trí (index) trong danh sách.
  /// Body: `{ "index": int, "done": bool }`
  Future<WasherOrderModel> updateChecklistItem(
      String id, int index, bool done) async {
    final response = await _dio.patch(
      '${ApiEndpoints.workOrders}/$id/checklist',
      data: {'index': index, 'done': done},
    );
    return WasherOrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Hoàn thành work-order: IN_PROGRESS → QUALITY_CHECK.
  ///
  Future<WasherOrderModel> finishWorkOrder(String id) async {
    final response = await _dio.patch('${ApiEndpoints.workOrders}/$id/finish');
    return WasherOrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
