import '../models/message_model.dart';
import 'user_model.dart';

class ApiResponseModel {
  final String message;
  final String status;
  final String? token;
  final UserModel? user;
  final List<MessageModel>? messages;

  ApiResponseModel({
    required this.message,
    required this.status,
    this.token,
    this.user,
    this.messages,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseModel(
      message: json['message'],
      status: json['status'],
      token: json['token'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      messages: json['messages'] != null
          ? List<MessageModel>.from(json['messages'].map(
              (x) => MessageModel.fromJson(x),
            ))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status': status,
      'token': token,
      'user': user?.toJson(),
      'messages': messages?.map((x) => x.toJson()).toList(),
    };
  }
}
