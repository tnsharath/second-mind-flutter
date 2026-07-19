import 'package:dio/dio.dart';

import '../errors/failure.dart';

/// Thin REST wrapper over Dio. All backend calls go through here so that
/// error handling and auth headers stay in one place.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: query);
    } on DioException catch (e) {
      throw AppFailure(_describe(e), cause: e);
    }
  }

  Future<Response<T>> post<T>(String path, {Object? body}) async {
    try {
      return await _dio.post<T>(path, data: body);
    } on DioException catch (e) {
      throw AppFailure(_describe(e), cause: e);
    }
  }

  String _describe(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Could not reach AURA. Check your connection.';
    }
    return 'AURA backend request failed (${e.response?.statusCode ?? 'no response'}).';
  }
}
