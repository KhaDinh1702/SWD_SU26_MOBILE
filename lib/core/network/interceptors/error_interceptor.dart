import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('API ERROR ${err.response?.statusCode}: ${err.response?.data}');
    handler.next(err);
  }
}
