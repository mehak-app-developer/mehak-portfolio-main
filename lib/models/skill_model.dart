import 'package:cloud_firestore/cloud_firestore.dart';

class SkillModel {
  final String id;
  final String name;
  final String category;
  final int level;

  const SkillModel({
    required this.id,
    required this.name,
    required this.category,
    required this.level,
  });

  factory SkillModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    final dynamic rawLevel = data['level'];

    int parsedLevel = 0;

    if (rawLevel is num) {
      parsedLevel = rawLevel.toInt();
    } else if (rawLevel is String) {
      parsedLevel = int.tryParse(rawLevel) ?? 0;
    }

    return SkillModel(
      id: document.id,
      name: data['name']?.toString() ?? '',
      category: data['category']?.toString() ?? '',
      level: parsedLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'level': level,
    };
  }
}