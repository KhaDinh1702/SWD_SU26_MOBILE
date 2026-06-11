import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wave/core/network/api_enpoints.dart';
import 'package:wave/features/auth/presentation/providers/auth_provider.dart';

/// Tải ảnh lên Cloudinary thông qua backend.
///
/// Backend trả về URL ảnh sau khi lưu, dùng chung cho mọi tính năng cần ảnh.
class UploadApi {
  final Dio _dio;

  UploadApi(this._dio);

  /// Tải lên 1 ảnh. Body: multipart `file`. Trả về URL ảnh.
  Future<String> uploadImage(XFile file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.name),
    });
    final res = await _dio.post(ApiEndpoints.uploadImage, data: form);
    final data = res.data;
    return data is Map ? (data['url'] ?? '').toString() : '';
  }

  /// Tải lên nhiều ảnh (tối đa 5/lần theo giới hạn backend).
  /// Body: multipart `files[]`. Trả về danh sách URL.
  Future<List<String>> uploadImages(List<XFile> files) async {
    if (files.isEmpty) return const [];
    final form = FormData();
    for (final file in files) {
      form.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(file.path, filename: file.name),
      ));
    }
    final res = await _dio.post(ApiEndpoints.uploadImages, data: form);
    final urls = res.data is Map ? res.data['urls'] : null;
    return urls is List ? urls.map((e) => e.toString()).toList() : const [];
  }
}

final uploadApiProvider = Provider<UploadApi>((ref) {
  return UploadApi(ref.watch(dioProvider));
});
