import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { pending, accepted, rejected }

extension ApplicationStatusX on ApplicationStatus {
  String get value => name;
  static ApplicationStatus fromString(String value) =>
      ApplicationStatus.values.firstWhere((e) => e.value == value,
          orElse: () => ApplicationStatus.pending);

  String get label {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Дар интизорӣ';
      case ApplicationStatus.accepted:
        return 'Қабул шуд';
      case ApplicationStatus.rejected:
        return 'Рад шуд';
    }
  }
}

/// Аризаи корҷӳ ба вакансия ([Apply], banди 13).
class JobApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String workerId;
  final String workerName;
  final String employerId;
  final ApplicationStatus status;
  final DateTime? appliedAt;

  const JobApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.workerId,
    required this.workerName,
    required this.employerId,
    this.status = ApplicationStatus.pending,
    this.appliedAt,
  });

  factory JobApplicationModel.fromMap(String id, Map<String, dynamic> map) {
    return JobApplicationModel(
      id: id,
      jobId: map['jobId'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      workerId: map['workerId'] as String? ?? '',
      workerName: map['workerName'] as String? ?? '',
      employerId: map['employerId'] as String? ?? '',
      status: ApplicationStatusX.fromString(map['status'] as String? ?? 'pending'),
      appliedAt: (map['appliedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'workerId': workerId,
      'workerName': workerName,
      'employerId': employerId,
      'status': status.value,
      if (isCreate) 'appliedAt': FieldValue.serverTimestamp(),
    };
  }
}
