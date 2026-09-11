import 'package:cloud_firestore/cloud_firestore.dart';

class CertificationModel {
final String id;
final String title;
final String organization;
final int year;
final String description;

const CertificationModel({
required this.id,
required this.title,
required this.organization,
required this.year,
required this.description,
});

factory CertificationModel.fromFirestore(
DocumentSnapshot<Map<String, dynamic>> document,
) {
final data = document.data() ?? {};

return CertificationModel(
id: document.id,
title: data['title']?.toString() ?? '',
organization: data['organization']?.toString() ?? '',
year: (data['year'] as num?)?.toInt() ?? 0,
description: data['description']?.toString() ?? '',
);
}

Map<String, dynamic> toMap() {
return {
'title': title,
'organization': organization,
'year': year,
'description': description,
};
}
}
