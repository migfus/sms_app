import './user_register.dart';

class TextMessage {
  final int id;
  final String content;
  final String? readAt;
  final String createdAt;
  final UserRegister userRegister;

  TextMessage({ required this.id, required this.content, required this.readAt, required this.createdAt, required this.userRegister});

  factory TextMessage.fromJson(var json) {
    return TextMessage(
      id: json['id'], 
      content: json['content'] ?? '', 
      readAt: json['read_at'], 
      createdAt: json['created_at'], 
      userRegister: UserRegister.fromJson(json['user_register'])
    );
  }
}