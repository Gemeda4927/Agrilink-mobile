import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'token_manager.dart';

class DioClient {
  late final Dio dio;
  final TokenManager tokenManager;

  DioClient({required this.tokenManager}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add token if exists
          final token = tokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print("➡️ [REQUEST] ${options.method} ${options.uri}");
          print("Headers: ${options.headers}");
          print("Data: ${options.data}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            "✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}",
          );
          print("Data: ${response.data}");
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print("❌ [ERROR] ${e.response?.statusCode} ${e.requestOptions.uri}");
          print("Message: ${e.message}");
          if (e.response != null) print("Data: ${e.response?.data}");
          return handler.next(e);
        },
      ),
    );
  }

  // HTTP methods
  Future<Response<dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.get(url, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.post(url, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> put(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.put(url, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> patch(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.patch(url, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> delete(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return dio.delete(url, data: data, queryParameters: queryParameters);
  }
}
