import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/project_model.dart';

class ProjectService {
  ProjectService._();

  static final ProjectService instance = ProjectService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<ProjectModel>> getProjects() {
    return _firestore
        .collection('projects')
        .snapshots()
        .map((snapshot) {
      print('PROJECTS COUNT: ${snapshot.docs.length}');

      for (final document in snapshot.docs) {
        print(
          'PROJECT: ${document.id} | DATA: ${document.data()}',
        );
      }

      return snapshot.docs
          .map(
            (document) => ProjectModel.fromFirestore(document),
      )
          .toList();
    });
  }
}