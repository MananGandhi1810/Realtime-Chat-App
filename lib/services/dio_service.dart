import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:websocket_chatroom/models/api_response_model.dart';

class DioService {
  final Dio _dio = Dio(
    BaseOptions(
      validateStatus: (status) => status! < 500,
    ),
  );

  Future<ApiResponseModel> get(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    try {
      Response res = await _dio.get(url, queryParameters: data ?? {});
      return ApiResponseModel.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<ApiResponseModel> post(
    String url, {
    required Map<String, dynamic> data,
  }) async {
    try {
      Response res = await _dio.post(url, data: data);
      return ApiResponseModel.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<ApiResponseModel> authenticatedGet(
    String url, {
    required String token,
    Map<String, dynamic>? data,
  }) async {
    try {
      Response res = await _dio.get(
        url,
        queryParameters: data ?? {},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      debugPrint(res.data.toString());
      return ApiResponseModel.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<ApiResponseModel> authenticatedPost(
    String url, {
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      Response res = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      debugPrint(res.toString());
      return ApiResponseModel.fromJson(res.data);
    } on DioException catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
