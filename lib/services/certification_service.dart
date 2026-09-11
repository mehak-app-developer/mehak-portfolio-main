import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/certification_model.dart';

class CertificationService {
CertificationService._();

static final CertificationService instance =
CertificationService._();

final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

Stream<List<CertificationModel>> getCertifications() {
return _firestore
    .collection('certifications')
    .orderBy('year', descending: true)
    .snapshots()
    .map(
(snapshot) {
return snapshot.docs
    .map(
(document) =>
CertificationModel.fromFirestore(
document,
),
)
    .toList();
},
);
}
}

