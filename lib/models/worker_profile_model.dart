import 'package:cloud_firestore/cloud_firestore.dart';

/// Профили корҷӳ (banди 13 спецификатсия).
///
/// Қарори тарроҳӣ (мутобиқи ҳамон нақшаи `businesses/{ownerId}`,
/// PHASE 5): documentId = uid, як профили корҷӳ барои ҳар корбар.
class WorkerProfileModel {
  final String uid;
  final String name;
  final String? photoUrl;
  final int? age;
  final String city;
  final String profession;
  final String? experience;
  final String? education;
  final double? expectedSalary;
  final List<String> skills;
  final String description;

  /// Privacy (banди 13: "корҷӳ бояд интихоб кунад кадом маълумоташ
  /// public бошад") — соддакардашуда ба як switch: агар false, профил
  /// дар ҷустуҷӳи "Корҷӳён" барои корфармоён намоён намешавад, вале
  /// худи корбар то боз кушодан онро нигоҳ медорад (пинҳон, на нест).
  final bool isVisible;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const WorkerProfileModel({
    required this.uid,
    required this.name,
    this.photoUrl,
    this.age,
    required this.city,
    required this.profession,
    this.experience,
    this.education,
    this.expectedSalary,
    this.skills = const [],
    this.description = '',
    this.isVisible = true,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkerProfileModel.fromMap(String uid, Map<String, dynamic> map) {
    return WorkerProfileModel(
      uid: uid,
      name: map['name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      age: map['age'] as int?,
      city: map['city'] as String? ?? '',
      profession: map['profession'] as String? ?? '',
      experience: map['experience'] as String?,
      education: map['education'] as String?,
      expectedSalary: (map['expectedSalary'] as num?)?.toDouble(),
      skills:
          ((map['skills'] as List?) ?? const []).map((e) => e as String).toList(),
      description: map['description'] as String? ?? '',
      isVisible: map['isVisible'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'uid': uid,
      'name': name,
      'photoUrl': photoUrl,
      'age': age,
      'city': city,
      'profession': profession,
      'experience': experience,
      'education': education,
      'expectedSalary': expectedSalary,
      'skills': skills,
      'description': description,
      'isVisible': isVisible,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
