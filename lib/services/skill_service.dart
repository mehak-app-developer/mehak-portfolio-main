import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/skill_model.dart';

class SkillService {
  SkillService._();

  static final SkillService instance = SkillService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<SkillModel>> getSkills() {
    return _firestore
        .collection('skills')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(
            (document) => SkillModel.fromFirestore(document),
      )
          .toList();
    });
  }
}