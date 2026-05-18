import 'package:dio/dio.dart';
import 'package:flutter_app/core/network/api_enpoints.dart';
import 'package:flutter_app/core/network/base_urls.dart';
import 'package:flutter_app/core/storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;

  AuthInterceptor({required Dio dio, required TokenStorage tokenStorage})
      : _dio = dio,
        _tokenStorage = tokenStorage;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenStorage.accessTokenSync;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode != 401 ||
        err.requestOptions.path == ApiEndpoints.refresh ||
        _isRefreshing) {
      handler.next(err);
      return;
    }
    _handleRefresh(err, handler);
  }

  Future<void> _handleRefresh(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    _isRefreshing = true;
    try {
      final refreshToken = _tokenStorage.refreshTokenSync;
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token');
      }

      final refreshDio = Dio(BaseOptions(baseUrl: BaseUrls.api));
      final response = await refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );

      final newAccess = response.data['accessToken'] as String;
      final newRefresh =
          (response.data['refreshToken'] as String?) ?? refreshToken;

      await _tokenStorage.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
      );

      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccess';
      final retryResponse = await _dio.fetch(opts);
      handler.resolve(retryResponse);
    } catch (_) {
      await _tokenStorage.clear();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}
