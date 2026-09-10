import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/job_application_model.dart';
import '../../../models/vacancy_model.dart';
import '../../chat/presentation/chat_detail_screen.dart';
import '../../chat/presentation/chat_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import 'create_edit_vacancy_screen.dart';
import 'jobs_providers.dart';

class MyVacanciesScreen extends ConsumerWidget {
  const MyVacanciesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacanciesAsync = ref.watch(myVacanciesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Вакансияҳои ман')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateEditVacancyScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Вакансияи нав'),
      ),
      body: vacanciesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(myVacanciesProvider)),
        data: (vacancies) {
          if (vacancies.isEmpty) {
            return const EmptyView(
              message: 'Шумо ҳанӯз вакансия эҷод накардаед.',
              icon: Icons.work_outline_rounded,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vacancies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _MyVacancyTile(vacancy: vacancies[index]),
          );
        },
      ),
    );
  }
}

class _MyVacancyTile extends ConsumerWidget {
  final VacancyModel vacancy;
  const _MyVacancyTile({required this.vacancy});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(vacancy.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              if (vacancy.isClosed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondaryLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Пушида', style: TextStyle(fontSize: 11)),
                ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateEditVacancyScreen(existing: vacancy),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                    vacancy.isClosed ? Icons.lock_open_outlined : Icons.lock_outline_rounded,
                    size: 18),
                onPressed: () => ref
                    .read(jobsActionControllerProvider.notifier)
                    .setClosed(vacancy.id, !vacancy.isClosed),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                onPressed: () => ref
                    .read(jobsActionControllerProvider.notifier)
                    .deleteVacancy(vacancy.id),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${vacancy.city} · ${vacancy.salaryRangeLabel}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
          const Divider(height: 20),
          _ApplicantsList(vacancyId: vacancy.id),
        ],
      ),
    );
  }
}

class _ApplicantsList extends ConsumerWidget {
  final String vacancyId;
  const _ApplicantsList({required this.vacancyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync = ref.watch(applicationsForVacancyProvider(vacancyId));

    return applicationsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (applications) {
        if (applications.isEmpty) {
          return const Text('Ҳанӯз ариза нест.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Аризадиҳандагон (${applications.length})',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...applications.map((app) => _ApplicantRow(application: app)),
          ],
        );
      },
    );
  }
}

class _ApplicantRow extends ConsumerWidget {
  final JobApplicationModel application;
  const _ApplicantRow({required this.application});

  Color get _statusColor {
    switch (application.status) {
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.rejected:
        return AppColors.error;
      case ApplicationStatus.pending:
        return AppColors.warning;
    }
  }

  Future<void> _chat(BuildContext context, WidgetRef ref) async {
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    final chatId = await ref.read(startChatProvider)(
      myUid: me.uid,
      myName: me.name,
      myPhoto: me.photoUrl,
      otherUid: application.workerId,
      otherName: application.workerName,
      contextType: 'job',
      contextId: application.jobId,
      contextTitle: application.jobTitle,
    );

    if (!context.mounted) return;
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ChatDetailScreen(chatId: chatId)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(application.workerName, style: const TextStyle(fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(application.status.label,
                style: TextStyle(fontSize: 10, color: _statusColor)),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
            onPressed: () => _chat(context, ref),
          ),
          if (application.status == ApplicationStatus.pending) ...[
            IconButton(
              icon: const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success),
              onPressed: () => ref
                  .read(jobsActionControllerProvider.notifier)
                  .updateApplicationStatus(application.id, ApplicationStatus.accepted),
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, size: 16, color: AppColors.error),
              onPressed: () => ref
                  .read(jobsActionControllerProvider.notifier)
                  .updateApplicationStatus(application.id, ApplicationStatus.rejected),
            ),
          ],
        ],
      ),
    );
  }
}
