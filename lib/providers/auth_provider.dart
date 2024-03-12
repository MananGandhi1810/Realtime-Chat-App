import 'package:flutter/material.dart';
import 'package:websocket_chatroom/repositories/auth_repository.dart';
import 'package:websocket_chatroom/services/secure_storage_service.dart';

import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  final AuthRepository _authRepository = AuthRepository();
  final SecureStorageService _secureStorageService = SecureStorageService();

  UserModel? get user => _user;

  AuthProvider() {
    debugPrint('AuthProvider created');
    getUser();
  }

  Future<void> getUser() async {
    try {
      String? token = await _secureStorageService.read('token');
      debugPrint('Token: $token');
      if (token != null) {
        Map<String, dynamic> response = await _authRepository.getUser(token);
        if (response['status'] == "success") {
          _user = response['user'];
          notifyListeners();
        } else {
          await _secureStorageService.delete('token');
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      Map<String, dynamic> response =
          await _authRepository.login(email, password);
      if (response['status'] == "success") {
        _user = response['user'];
        if (_user != null) {
          _user!.setToken(response['token']);
          await _secureStorageService.write('token', response['token']!);
        }
        notifyListeners();
      } else {
        throw response['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      Map<String, dynamic> response =
          await _authRepository.register(name, email, password);
      if (response['status'] == "success") {
        _user = response['user'];
        debugPrint('User: $_user');
        if (_user != null) {
          _user!.setToken(response['token']);
          await _secureStorageService.write('token', response['token']!);
        }
        notifyListeners();
      } else {
        throw response['message'];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _user = null;
    await _secureStorageService.delete('token');
    notifyListeners();
  }
}
