import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:websocket_chatroom/models/message_model.dart';
import 'package:websocket_chatroom/models/user_model.dart';
import 'package:websocket_chatroom/services/secure_storage_service.dart';

import '../repositories/message_repository.dart';

class MessagesProvider extends ChangeNotifier {
  List<MessageModel> _messages = [];
  final MessageRepository _messageRepository = MessageRepository();
  final SecureStorageService _secureStorageService = SecureStorageService();
  String token = '';

  MessagesProvider() {
    debugPrint('MessagesProvider created');
    getToken();
  }

  void getToken() async {
    token = await _secureStorageService.read('token') ?? '';
  }

  List<MessageModel> get messages => _messages;

  void getPastMessages() async {
    try {
      token = await _secureStorageService.read('token') ?? '';
      if (token == '') {
        throw 'No token found. Please login';
      }
      _messages = await _messageRepository.getPastMessages(token);
      notifyListeners();
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  void onMessageReceived(event) {
    debugPrint('Received: $event');
    final data = json.decode(event);
    debugPrint('Data: $data');
    if (data['type'] == 'join-response') {
      debugPrint('Join response: ${data['message']}');
      return;
    }
    if (data['type'] == 'give-details') {
      debugPrint('Give details: ${data['type']}');
      authenticateSocketConnection();
      return;
    }
    if (data['type'] == 'error') {
      debugPrint('Error: ${data['message']}');
      return;
    }
    if (data['type'] == 'message') {
      final message = MessageModel(
        id: data['id'],
        content: data['message'],
        user: UserModel.fromJson(data['user']),
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['createdAt']),
      );
      _messages.add(message);
      notifyListeners();
    }
  }

  void onDisconnected() {
    debugPrint('Disconnected');
  }

  void initSocketConnection() async {
    try {
      token = await _secureStorageService.read('token') ?? '';
      if (token == '') {
        throw Exception('No token found. Please login');
      }
      await _messageRepository.initSocketConnection(
        token,
        onMessageReceived,
        onDisconnected,
      );
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  void authenticateSocketConnection() async {
    try {
      token = await _secureStorageService.read('token') ?? '';
      if (token == '') {
        throw Exception('No token found. Please login');
      }
      await _messageRepository.sendMessage({
        'type': 'join',
        'token': token,
      });
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }

  void sendMessage(String message) async {
    try {
      await _messageRepository
          .sendMessage({'type': 'message', 'message': message});
    } catch (e) {
      debugPrint('Error: $e');
      rethrow;
    }
  }
}
