import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // TODO: Replace with environment variable
      baseUrl: 'http://10.0.2.2:3000/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  // TODO: Add Auth Interceptor to attach Bearer token

  return dio;
});

class ApiException implements Exception {
  final String code;
  final String message;

  ApiException({required this.code, required this.message});

  @override
  String toString() => 'ApiException: $code - $message';

  factory ApiException.fromDioError(DioException error) {
    if (error.response?.data != null && error.response!.data is Map) {
      final data = error.response!.data as Map<String, dynamic>;
      if (data['error'] != null && data['error'] is Map) {
        final errorObj = data['error'];
        return ApiException(
          code: errorObj['code']?.toString() ?? 'UNKNOWN_ERROR',
          message: errorObj['message']?.toString() ?? 'An unknown error occurred',
        );
      }
    }
    return ApiException(
      code: 'NETWORK_ERROR',
      message: error.message ?? 'A network error occurred',
    );
  }
}
