import 'package:cloud_firestore/cloud_firestore.dart';

class MessageService {
  MessageService._();

  static final MessageService instance =
  MessageService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    await _firestore.collection('messages').add({
      'name': name.trim(),
      'email': email.trim(),
      'message': message.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}