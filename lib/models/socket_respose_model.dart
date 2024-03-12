import 'package:websocket_chatroom/models/user_model.dart';

class SocketResponseModel {
  final String type;
  final String message;
  final UserModel? user;

  SocketResponseModel({
    required this.type,
    required this.message,
    this.user,
  });

  factory SocketResponseModel.fromJson(Map<String, dynamic> json) {
    return SocketResponseModel(
      type: json['type'],
      message: json['message'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'message': message,
      'user': user?.toJson(),
    };
  }
}
