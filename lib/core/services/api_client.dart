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

  /// POST returning the raw byte stream (e.g. SSE endpoints). Callers read
  /// `response.data.stream` and parse chunks themselves.
  Future<Response<ResponseBody>> postStream(String path, {Object? body}) async {
    try {
      return await _dio.post<ResponseBody>(
        path,
        data: body,
        options: Options(responseType: ResponseType.stream),
      );
    } on DioException catch (e) {
      throw AppFailure(_describe(e), cause: e);
    }
  }

  Future<Response<T>> patch<T>(String path, {Object? body}) async {
    try {
      return await _dio.patch<T>(path, data: body);
    } on DioException catch (e) {
      throw AppFailure(_describe(e), cause: e);
    }
  }

  Future<Response<T>> delete<T>(String path) async {
    try {
      return await _dio.delete<T>(path);
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
