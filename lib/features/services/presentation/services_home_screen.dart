import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/service_categories.dart';
import '../../../core/constants/tj_cities.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import 'my_service_orders_screen.dart';
import 'provider_card.dart';
import 'provider_profile_form_screen.dart';
import 'provider_profile_screen.dart';
import 'services_providers.dart';

class ServicesHomeScreen extends ConsumerWidget {
  const ServicesHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(servicesFilterProvider);
    final providersAsync = ref.watch(providersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Хизматрасонӣ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Дархостҳои ман',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyServiceOrdersScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.storefront_outlined),
            tooltip: 'Профили хизматрасони ман',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProviderProfileFormScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _CategoryIconChip(
                  label: 'Ҳама',
                  icon: Icons.apps_rounded,
                  selected: filter.category == null,
                  onTap: () => ref.read(servicesFilterProvider.notifier).setCategory(null),
                ),
                ...ServiceCategories.all.map(
                  (c) => _CategoryIconChip(
                    label: ServiceCategories.labelOf(c),
                    icon: ServiceCategories.iconOf(c),
                    selected: filter.category == c,
                    onTap: () => ref.read(servicesFilterProvider.notifier).setCategory(c),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _cityChip(context, ref, 'Ҳама шаҳрҳо', null, filter.city == null),
                ...TjCities.all.map(
                  (c) => _cityChip(context, ref, c, c, filter.city == c),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: providersAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(onRetry: () => ref.invalidate(providersListProvider)),
              data: (providers) {
                if (providers.isEmpty) {
                  return const EmptyView(
                    message: 'Дар ин категория/шаҳр хизматрасон ёфт нашуд.',
                    icon: Icons.build_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => ProviderCard(
                    provider: providers[index],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProviderProfileScreen(uid: providers[index].uid),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _cityChip(
      BuildContext context, WidgetRef ref, String label, String? value, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => ref.read(servicesFilterProvider.notifier).setCity(value),
        selectedColor: AppColors.primaryLight,
        labelStyle: TextStyle(
          color: selected ? AppColors.primaryDark : AppColors.textPrimaryLight,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: AppColors.surfaceLight,
        side: BorderSide(color: selected ? AppColors.primary : AppColors.borderLight),
      ),
    );
  }
}

class _CategoryIconChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryIconChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: selected ? AppColors.primaryDark : AppColors.textSecondaryLight),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: selected ? AppColors.primaryDark : AppColors.textSecondaryLight,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
