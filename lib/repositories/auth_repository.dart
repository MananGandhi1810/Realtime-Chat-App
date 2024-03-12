import 'package:flutter/material.dart';
import 'package:websocket_chatroom/constants.dart';

import '../models/api_response_model.dart';
import '../services/dio_service.dart';

class AuthRepository {
  final DioService _dioService = DioService();
  final String _baseUrl = Constants.apiBaseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      ApiResponseModel response = await _dioService.post(
        '$_baseUrl/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return {
        'status': response.status,
        'message': response.message,
        'user': response.user,
        'token': response.token,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      ApiResponseModel response = await _dioService.post(
        '$_baseUrl/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );
      return {
        'status': response.status,
        'message': response.message,
        'user': response.user,
        'token': response.token,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUser(String token) async {
    try {
      ApiResponseModel response = await _dioService.authenticatedPost(
        '$_baseUrl/verify_user',
        data: {},
        token: token,
      );
      return {
        'status': response.status,
        'message': response.message,
        'user': response.user,
      };
    } catch (e) {
      rethrow;
    }
  }
}
