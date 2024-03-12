import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:websocket_chatroom/constants.dart';
import 'package:websocket_chatroom/services/dio_service.dart';

import '../models/api_response_model.dart';
import '../models/message_model.dart';

class MessageRepository {
  final DioService _dioService = DioService();
  WebSocketChannel? channel;

  final String _baseUrl = Constants.apiBaseUrl;
  final String _socketUrl = Constants.webSocketBaseUrl;

  Future<List<MessageModel>> getPastMessages(String token) async {
    try {
      ApiResponseModel response = await _dioService
          .authenticatedGet('$_baseUrl/messages', token: token);
      return response.messages!;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future initSocketConnection(
    String token,
    Function onMessageReceived,
    Function onDisconnected,
  ) async {
    try {
      debugPrint('Connecting to $_socketUrl');
      channel = WebSocketChannel.connect(
        Uri.parse(_socketUrl),
      );
      channel?.stream.listen(
        (event) {
          onMessageReceived(event);
        },
        onDone: () {
          onDisconnected();
        },
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future sendMessage(Map<String, dynamic> message) async {
    try {
      String data = json.encode(message);
      channel?.sink.add(data);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
