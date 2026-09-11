import 'package:cloud_firestore/cloud_firestore.dart';

class EducationModel {
  final String id;
  final String name;
  final String institute;
  final String affiliation;
  final int startYear;
  final int endYear;

  const EducationModel({
    required this.id,
    required this.name,
    required this.institute,
    required this.affiliation,
    required this.startYear,
    required this.endYear,
  });

  factory EducationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    return EducationModel(
      id: document.id,
      name: data['name']?.toString() ?? '',
      institute: data['institute']?.toString() ?? '',
      affiliation: data['affiliation']?.toString() ?? '',
      startYear: (data['startYear'] as num?)?.toInt() ?? 0,
      endYear: (data['endYear'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'institute': institute,
      'affiliation': affiliation,
      'startYear': startYear,
      'endYear': endYear,
    };
  }
}