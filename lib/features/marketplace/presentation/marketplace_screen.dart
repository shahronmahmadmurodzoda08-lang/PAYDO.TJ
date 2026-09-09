import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/product_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import 'marketplace_providers.dart';
import 'product_card.dart';
import 'product_details_screen.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(productFilterProvider);
    final productsAsync = ref.watch(productListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Магазин')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'Ҳама',
                  selected: filter.category == null,
                  onTap: () =>
                      ref.read(productFilterProvider.notifier).setCategory(null),
                ),
                const SizedBox(width: 8),
                ...ProductCategories.all.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _CategoryChip(
                      label: ProductCategories.labelOf(c),
                      selected: filter.category == c,
                      onTap: () =>
                          ref.read(productFilterProvider.notifier).setCategory(c),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: productsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(
                onRetry: () => ref.invalidate(productListProvider),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyView(
                    message: 'Дар ин категория ҳанӯз маҳсулот нест.',
                    icon: Icons.storefront_outlined,
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsScreen(productId: product.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
      side: BorderSide(
        color: selected ? AppColors.primary : AppColors.borderLight,
      ),
    );
  }
}
