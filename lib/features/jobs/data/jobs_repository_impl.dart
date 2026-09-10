import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/job_application_model.dart';
import '../../../models/vacancy_model.dart';
import '../../../models/worker_profile_model.dart';
import '../domain/jobs_repository.dart';

class JobsRepositoryImpl implements JobsRepository {
  final FirebaseFirestore _firestore;

  JobsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _vacanciesRef =>
      _firestore.collection(FirestorePaths.jobs);

  CollectionReference<Map<String, dynamic>> get _workersRef =>
      _firestore.collection(FirestorePaths.workerProfiles);

  CollectionReference<Map<String, dynamic>> get _applicationsRef =>
      _firestore.collection(FirestorePaths.jobApplications);

  // ---- Vacancies ----

  @override
  Stream<List<VacancyModel>> watchVacancies({String? city}) {
    Query<Map<String, dynamic>> query =
        _vacanciesRef.where('isClosed', isEqualTo: false);
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }
    query = query.orderBy('createdAt', descending: true).limit(50);

    return query.snapshots().map(
          (snap) => snap.docs.map((d) => VacancyModel.fromMap(d.id, d.data())).toList(),
        );
  }

  @override
  Stream<List<VacancyModel>> watchMyVacancies(String employerId) {
    return _vacanciesRef
        .where('employerId', isEqualTo: employerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => VacancyModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<VacancyModel> getVacancy(String vacancyId) async {
    final snap = await _vacanciesRef.doc(vacancyId).get();
    if (!snap.exists || snap.data() == null) {
      throw const ServerFailure('Вакансия ёфт нашуд.');
    }
    return VacancyModel.fromMap(snap.id, snap.data()!);
  }

  @override
  Future<String> createVacancy(VacancyModel vacancy) async {
    try {
      final docRef = await _vacanciesRef.add(vacancy.toMap(isCreate: true));
      return docRef.id;
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии сохтани вакансия: ${e.message}');
    }
  }

  @override
  Future<void> updateVacancy(VacancyModel vacancy) async {
    try {
      await _vacanciesRef.doc(vacancy.id).update(vacancy.toMap());
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии тағйири вакансия: ${e.message}');
    }
  }

  @override
  Future<void> setVacancyClosed({
    required String vacancyId,
    required bool isClosed,
  }) async {
    await _vacanciesRef.doc(vacancyId).update({
      'isClosed': isClosed,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteVacancy(String vacancyId) async {
    await _vacanciesRef.doc(vacancyId).delete();
  }

  // ---- Worker Profiles ----

  @override
  Stream<List<WorkerProfileModel>> watchWorkers({String? city, String? profession}) {
    Query<Map<String, dynamic>> query =
        _workersRef.where('isVisible', isEqualTo: true);
    if (city != null) {
      query = query.where('city', isEqualTo: city);
    }
    if (profession != null) {
      query = query.where('profession', isEqualTo: profession);
    }
    query = query.orderBy('createdAt', descending: true).limit(50);

    return query.snapshots().map((snap) =>
        snap.docs.map((d) => WorkerProfileModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<WorkerProfileModel?> getMyWorkerProfile(String uid) async {
    final snap = await _workersRef.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return WorkerProfileModel.fromMap(snap.id, snap.data()!);
  }

  @override
  Stream<WorkerProfileModel?> watchWorkerProfile(String uid) {
    return _workersRef.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return WorkerProfileModel.fromMap(snap.id, snap.data()!);
    });
  }

  @override
  Future<void> saveWorkerProfile(WorkerProfileModel profile) async {
    final docRef = _workersRef.doc(profile.uid);
    final existing = await docRef.get();
    try {
      await docRef.set(
        profile.toMap(isCreate: !existing.exists),
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии нигоҳдории профили корҷӳ: ${e.message}');
    }
  }

  // ---- Applications ----

  @override
  Future<void> applyToVacancy(JobApplicationModel application) async {
    try {
      // docId детерминистӣ (vacancyId_workerId) — пешгирии аризаи такрорӣ.
      final docId = '${application.jobId}_${application.workerId}';
      await _applicationsRef.doc(docId).set(application.toMap(isCreate: true));
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии фиристодани ариза: ${e.message}');
    }
  }

  @override
  Future<bool> hasApplied({required String vacancyId, required String workerId}) async {
    final docId = '${vacancyId}_$workerId';
    final snap = await _applicationsRef.doc(docId).get();
    return snap.exists;
  }

  @override
  Stream<List<JobApplicationModel>> watchApplicationsForVacancy(String vacancyId) {
    return _applicationsRef
        .where('jobId', isEqualTo: vacancyId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => JobApplicationModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
  }) async {
    await _applicationsRef.doc(applicationId).update({'status': status.value});
  }
}
