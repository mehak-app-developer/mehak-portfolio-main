import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/education_model.dart';

class EducationService {
  EducationService._();

  static final EducationService instance =
  EducationService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<EducationModel>> getEducation() {
    return _firestore
        .collection('education')
        .snapshots()
        .map(
          (snapshot) {
        return snapshot.docs
            .map(
              (document) =>
              EducationModel.fromFirestore(document),
        )
            .toList();
      },
    );
  }
}