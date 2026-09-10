import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/job_application_model.dart';
import '../../../models/vacancy_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../chat/presentation/chat_detail_screen.dart';
import '../../chat/presentation/chat_providers.dart';
import 'jobs_providers.dart';

class VacancyDetailsScreen extends ConsumerWidget {
  final String vacancyId;
  const VacancyDetailsScreen({super.key, required this.vacancyId});

  Future<void> _apply(BuildContext context, WidgetRef ref, VacancyModel vacancy) async {
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    if (me.uid == vacancy.employerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ин вакансияи худи шумост.')),
      );
      return;
    }

    final application = JobApplicationModel(
      id: '',
      jobId: vacancy.id,
      jobTitle: vacancy.title,
      workerId: me.uid,
      workerName: me.name,
      employerId: vacancy.employerId,
    );

    final ok = await ref.read(jobsActionControllerProvider.notifier).apply(application);

    if (!context.mounted) return;
    ref.invalidate(hasAppliedProvider(vacancy.id));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Аризаи шумо фиристода шуд!' : 'Хатогии фиристодани ариза.'),
      ),
    );
  }

  Future<void> _chatWithEmployer(
      BuildContext context, WidgetRef ref, VacancyModel vacancy) async {
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    if (me.uid == vacancy.employerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ин вакансияи худи шумост.')),
      );
      return;
    }

    final chatId = await ref.read(startChatProvider)(
      myUid: me.uid,
      myName: me.name,
      myPhoto: me.photoUrl,
      otherUid: vacancy.employerId,
      otherName: vacancy.employerName,
      contextType: 'job',
      contextId: vacancy.id,
      contextTitle: vacancy.title,
    );

    if (!context.mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatDetailScreen(chatId: chatId)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vacancyAsync = ref.watch(vacancyDetailsProvider(vacancyId));

    return Scaffold(
      appBar: AppBar(title: const Text('Вакансия')),
      body: vacancyAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) =>
            ErrorView(onRetry: () => ref.invalidate(vacancyDetailsProvider(vacancyId))),
        data: (vacancy) {
          final hasAppliedAsync = ref.watch(hasAppliedProvider(vacancyId));

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(vacancy.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(vacancy.employerName,
                        style: const TextStyle(color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(icon: Icons.payments_outlined, label: vacancy.salaryRangeLabel),
                        _InfoChip(icon: Icons.location_on_outlined, label: vacancy.city),
                        if (vacancy.schedule != null)
                          _InfoChip(icon: Icons.schedule_outlined, label: vacancy.schedule!),
                        if (vacancy.experience != null)
                          _InfoChip(icon: Icons.work_history_outlined, label: vacancy.experience!),
                        if (vacancy.education != null)
                          _InfoChip(icon: Icons.school_outlined, label: vacancy.education!),
                        if (vacancy.ageMin != null || vacancy.ageMax != null)
                          _InfoChip(
                            icon: Icons.cake_outlined,
                            label:
                                '${vacancy.ageMin ?? "0"}-${vacancy.ageMax ?? "∞"} сола',
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text('Тавсиф',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(vacancy.description, style: Theme.of(context).textTheme.bodyMedium),
                    if (vacancy.contact != null) ...[
                      const SizedBox(height: 16),
                      Text('Тамос: ${vacancy.contact}',
                          style: const TextStyle(color: AppColors.textSecondaryLight)),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('Чат'),
                          onPressed: () => _chatWithEmployer(context, ref, vacancy),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: hasAppliedAsync.maybeWhen(
                          data: (hasApplied) => ElevatedButton.icon(
                            icon: Icon(hasApplied
                                ? Icons.check_circle_outline
                                : Icons.send_rounded),
                            label: Text(hasApplied ? 'Ариза фиристода шуд' : 'Ариза додан'),
                            onPressed:
                                hasApplied || vacancy.isClosed ? null : () => _apply(context, ref, vacancy),
                          ),
                          orElse: () => ElevatedButton(
                            onPressed: null,
                            child: const Text('...'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textSecondaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryLight),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
