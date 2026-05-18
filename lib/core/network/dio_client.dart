import 'package:dio/dio.dart';
import 'package:flutter_app/core/network/base_urls.dart';
import 'package:flutter_app/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_app/core/network/interceptors/error_interceptor.dart';
import 'package:flutter_app/core/storage/token_storage.dart';

class DioClient {
  static Dio create(TokenStorage tokenStorage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: BaseUrls.api,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      AuthInterceptor(dio: dio, tokenStorage: tokenStorage),
    );
    dio.interceptors.add(ErrorInterceptor());

    return dio;
  }
}
