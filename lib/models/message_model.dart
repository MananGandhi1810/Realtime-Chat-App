import '../models/user_model.dart';

class MessageModel {
  final String id;
  final String content;
  final UserModel user;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.content,
    required this.user,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      user: UserModel.fromJson(json['user']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'user': user.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
