import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String name;
  final String email;
  final String message;
  final DateTime? createdAt;

  const MessageModel({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    this.createdAt,
  });

  factory MessageModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    final timestamp = data['createdAt'];

    return MessageModel(
      id: document.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}