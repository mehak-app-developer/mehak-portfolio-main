import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String title;
  final String year;
  final String location;
  final String description;
  final String technologies;
  final String imageUrl;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.year,
    required this.location,
    required this.description,
    required this.technologies,
    required this.imageUrl,
  });

  factory ProjectModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data() ?? {};

    return ProjectModel(
      id: document.id,
      title: data['title']?.toString() ?? '',
      year: data['year']?.toString() ?? '',
      location: data['location']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      technologies: data['technologies']?.toString() ?? '',
      imageUrl: data['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'year': year,
      'location': location,
      'description': description,
      'technologies': technologies,
      'imageUrl': imageUrl,
    };
  }
}