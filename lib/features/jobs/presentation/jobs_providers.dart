import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/job_application_model.dart';
import '../../../models/vacancy_model.dart';
import '../../../models/worker_profile_model.dart';
import '../data/jobs_repository_impl.dart';
import '../domain/jobs_repository.dart';
import '../../auth/presentation/auth_providers.dart';

final jobsRepositoryProvider = Provider<JobsRepository>((ref) {
  return JobsRepositoryImpl();
});

/// Filter барои рӳйхати вакансия/корҷӳ (city).
class JobsFilterNotifier extends StateNotifier<String?> {
  JobsFilterNotifier() : super(null);
  void setCity(String? city) => state = city;
}

final vacancyCityFilterProvider =
    StateNotifierProvider<JobsFilterNotifier, String?>((ref) => JobsFilterNotifier());

final vacancyListProvider = StreamProvider<List<VacancyModel>>((ref) {
  final repo = ref.watch(jobsRepositoryProvider);
  final city = ref.watch(vacancyCityFilterProvider);
  return repo.watchVacancies(city: city);
});

final vacancyDetailsProvider =
    FutureProvider.family<VacancyModel, String>((ref, id) {
  final repo = ref.watch(jobsRepositoryProvider);
  return repo.getVacancy(id);
});

final myVacanciesProvider = StreamProvider<List<VacancyModel>>((ref) {
  final repo = ref.watch(jobsRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchMyVacancies(uid);
});

final workerCityFilterProvider =
    StateNotifierProvider<JobsFilterNotifier, String?>((ref) => JobsFilterNotifier());

final workerListProvider = StreamProvider<List<WorkerProfileModel>>((ref) {
  final repo = ref.watch(jobsRepositoryProvider);
  final city = ref.watch(workerCityFilterProvider);
  return repo.watchWorkers(city: city);
});

/// Профили корҷӳи корбари ҳозира (агар дошта бошад).
final myWorkerProfileProvider = StreamProvider<WorkerProfileModel?>((ref) {
  final repo = ref.watch(jobsRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(null);
  return repo.watchWorkerProfile(uid);
});

final applicationsForVacancyProvider =
    StreamProvider.family<List<JobApplicationModel>, String>((ref, vacancyId) {
  final repo = ref.watch(jobsRepositoryProvider);
  return repo.watchApplicationsForVacancy(vacancyId);
});

final hasAppliedProvider =
    FutureProvider.family<bool, String>((ref, vacancyId) {
  final repo = ref.watch(jobsRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Future.value(false);
  return repo.hasApplied(vacancyId: vacancyId, workerId: uid);
});

class JobsActionState {
  final bool isSaving;
  final String? errorMessage;
  const JobsActionState({this.isSaving = false, this.errorMessage});

  JobsActionState copyWith({bool? isSaving, String? errorMessage}) =>
      JobsActionState(isSaving: isSaving ?? this.isSaving, errorMessage: errorMessage);
}

class JobsActionController extends StateNotifier<JobsActionState> {
  final JobsRepository _repository;
  JobsActionController(this._repository) : super(const JobsActionState());

  Future<bool> createVacancy(VacancyModel vacancy) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.createVacancy(vacancy);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Хатогии сабт.');
      return false;
    }
  }

  Future<bool> updateVacancy(VacancyModel vacancy) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.updateVacancy(vacancy);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Хатогии сабт.');
      return false;
    }
  }

  Future<void> setClosed(String vacancyId, bool isClosed) =>
      _repository.setVacancyClosed(vacancyId: vacancyId, isClosed: isClosed);

  Future<void> deleteVacancy(String vacancyId) => _repository.deleteVacancy(vacancyId);

  Future<bool> saveWorkerProfile(WorkerProfileModel profile) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.saveWorkerProfile(profile);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Хатогии сабт.');
      return false;
    }
  }

  Future<bool> apply(JobApplicationModel application) async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    try {
      await _repository.applyToVacancy(application);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, errorMessage: 'Хатогии фиристодани ариза.');
      return false;
    }
  }

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) =>
      _repository.updateApplicationStatus(applicationId: applicationId, status: status);
}

final jobsActionControllerProvider =
    StateNotifierProvider<JobsActionController, JobsActionState>((ref) {
  final repo = ref.watch(jobsRepositoryProvider);
  return JobsActionController(repo);
});
