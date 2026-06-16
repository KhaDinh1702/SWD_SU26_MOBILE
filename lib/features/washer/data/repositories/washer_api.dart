import 'package:dio/dio.dart';
import 'package:wave/core/network/api_enpoints.dart';
import 'package:wave/features/washer/data/models/washer_order_model.dart';

class WasherApi {
  final Dio _dio;

  WasherApi(this._dio);

  Future<List<WasherOrderModel>> getWorkOrders() async {
    final response = await _dio.get(ApiEndpoints.workOrders);
    final raw = response.data;
    final List data;
    if (raw is List) {
      data = raw;
    } else if (raw is Map) {
      // backend trả về { data: [...] } hoặc { items: [...] } hoặc { workOrders: [...] }
      final inner = raw['data'] ?? raw['items'] ?? raw['workOrders'] ?? raw['content'];
      data = inner is List ? inner : [];
    } else {
      data = [];
    }
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

  /// Hoàn thành work-order: IN_PROGRESS → QUALITY_CHECK.
  /// [checkoutPhotoUrls] là danh sách URL ảnh sau khi rửa đã upload lên Cloudinary.
  Future<WasherOrderModel> finishWorkOrder(
      String id, List<String> checkoutPhotoUrls) async {
    final response = await _dio.patch(
      '${ApiEndpoints.workOrders}/$id/finish',
      data: {'checkoutPhotos': checkoutPhotoUrls},
    );
    return WasherOrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
