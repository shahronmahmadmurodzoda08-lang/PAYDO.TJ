import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/tj_cities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import 'create_edit_vacancy_screen.dart';
import 'jobs_providers.dart';
import 'my_vacancies_screen.dart';
import 'vacancy_card.dart';
import 'vacancy_details_screen.dart';
import 'worker_card.dart';
import 'worker_profile_detail_screen.dart';
import 'worker_profile_form_screen.dart';

class JobsHomeScreen extends ConsumerWidget {
  const JobsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Кор'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondaryLight,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Вакансияҳо'),
              Tab(text: 'Корҷӳён'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'post') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateEditVacancyScreen()),
                  );
                } else if (value == 'my_vacancies') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyVacanciesScreen()),
                  );
                } else if (value == 'worker_profile') {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WorkerProfileFormScreen()),
                  );
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'post', child: Text('Вакансияи нав')),
                PopupMenuItem(value: 'my_vacancies', child: Text('Вакансияҳои ман')),
                PopupMenuItem(value: 'worker_profile', child: Text('Профили корҷӳи ман')),
              ],
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _VacanciesTab(),
            _WorkersTab(),
          ],
        ),
      ),
    );
  }
}

class _VacanciesTab extends ConsumerWidget {
  const _VacanciesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(vacancyCityFilterProvider);
    final vacanciesAsync = ref.watch(vacancyListProvider);

    return Column(
      children: [
        _CityFilterBar(
          selectedCity: city,
          onChanged: (c) => ref.read(vacancyCityFilterProvider.notifier).setCity(c),
        ),
        Expanded(
          child: vacanciesAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(onRetry: () => ref.invalidate(vacancyListProvider)),
            data: (vacancies) {
              if (vacancies.isEmpty) {
                return const EmptyView(
                  message: 'Дар ин шаҳр вакансия ёфт нашуд.',
                  icon: Icons.work_outline_rounded,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: vacancies.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => VacancyCard(
                  vacancy: vacancies[index],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          VacancyDetailsScreen(vacancyId: vacancies[index].id),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WorkersTab extends ConsumerWidget {
  const _WorkersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(workerCityFilterProvider);
    final workersAsync = ref.watch(workerListProvider);

    return Column(
      children: [
        _CityFilterBar(
          selectedCity: city,
          onChanged: (c) => ref.read(workerCityFilterProvider.notifier).setCity(c),
        ),
        Expanded(
          child: workersAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => ErrorView(onRetry: () => ref.invalidate(workerListProvider)),
            data: (workers) {
              if (workers.isEmpty) {
                return const EmptyView(
                  message: 'Дар ин шаҳр корҷӳ ёфт нашуд.',
                  icon: Icons.badge_outlined,
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: workers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => WorkerCard(
                  worker: workers[index],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          WorkerProfileDetailScreen(workerId: workers[index].uid),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CityFilterBar extends StatelessWidget {
  final String? selectedCity;
  final ValueChanged<String?> onChanged;
  const _CityFilterBar({required this.selectedCity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          _chip(context, 'Ҳама шаҳрҳо', selectedCity == null, () => onChanged(null)),
          const SizedBox(width: 8),
          ...TjCities.all.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _chip(context, c, selectedCity == c, () => onChanged(c)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: selected ? AppColors.primaryDark : AppColors.textPrimaryLight,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: AppColors.surfaceLight,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.borderLight),
    );
  }
}
