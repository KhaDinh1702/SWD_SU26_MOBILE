import 'package:dio/dio.dart';

String parseError(Object error) {
  if (error is DioException) {
    // Lấy message từ response body trước
    final data = error.response?.data;
    if (data is Map) {
      final msg = data['message'] ?? data['error'] ?? data['msg'];
      if (msg != null && msg.toString().trim().isNotEmpty) {
        return msg.toString();
      }
    }
    if (data is String && data.trim().isNotEmpty) return data;

    // Xử lý theo loại lỗi kết nối
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Kết nối quá thời gian. Vui lòng thử lại.';
      case DioExceptionType.connectionError:
        return 'Không có kết nối mạng. Kiểm tra lại đường truyền.';
      case DioExceptionType.badResponse:
        final code = error.response?.statusCode;
        if (code == 401) return 'Email hoặc mật khẩu không đúng.';
        if (code == 403) return 'Tài khoản không có quyền truy cập.';
        if (code == 404) return 'Không tìm thấy tài khoản.';
        if (code == 409) return 'Email đã được sử dụng.';
        if (code != null && code >= 500) return 'Lỗi máy chủ. Vui lòng thử lại sau.';
        return 'Yêu cầu thất bại (mã: $code).';
      default:
        break;
    }
  }
  return 'Có lỗi xảy ra. Vui lòng thử lại.';
}
