import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/worker_profile_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../chat/presentation/chat_detail_screen.dart';
import '../../chat/presentation/chat_providers.dart';
import 'jobs_providers.dart';

class WorkerProfileDetailScreen extends ConsumerWidget {
  final String workerId;
  const WorkerProfileDetailScreen({super.key, required this.workerId});

  Future<void> _chat(BuildContext context, WidgetRef ref, WorkerProfileModel worker) async {
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    if (me.uid == worker.uid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ин профили худи шумост.')));
      return;
    }

    final chatId = await ref.read(startChatProvider)(
      myUid: me.uid,
      myName: me.name,
      myPhoto: me.photoUrl,
      otherUid: worker.uid,
      otherName: worker.name,
      otherPhoto: worker.photoUrl,
      contextType: 'job',
      contextTitle: worker.profession,
    );

    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatDetailScreen(chatId: chatId)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workersAsync = ref.watch(workerListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Профили корҷӳ')),
      body: workersAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => const ErrorView(),
        data: (workers) {
          final matches = workers.where((w) => w.uid == workerId);
          if (matches.isEmpty) {
            return const EmptyView(message: 'Профил ёфт нашуд.');
          }
          final worker = matches.first;
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: worker.photoUrl != null
                            ? CachedNetworkImageProvider(worker.photoUrl!)
                            : null,
                        child: worker.photoUrl == null
                            ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(worker.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Center(
                      child: Text(worker.profession,
                          style: const TextStyle(color: AppColors.primary, fontSize: 15)),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(Icons.location_on_outlined, worker.city),
                        if (worker.age != null) _chip(Icons.cake_outlined, '${worker.age} сола'),
                        if (worker.experience != null)
                          _chip(Icons.work_history_outlined, worker.experience!),
                        if (worker.expectedSalary != null)
                          _chip(Icons.payments_outlined,
                              '${worker.expectedSalary!.toStringAsFixed(0)} с.'),
                      ],
                    ),
                    if (worker.skills.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Малакаҳо', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: worker.skills
                            .map((s) => Chip(label: Text(s, style: const TextStyle(fontSize: 12))))
                            .toList(),
                      ),
                    ],
                    if (worker.description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Дар бораи худ', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(worker.description, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline_rounded),
                      label: const Text('Чат бо корҷӳ'),
                      onPressed: () => _chat(context, ref, worker),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
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
