import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/product_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import 'marketplace_providers.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailsProvider(productId));
    final favoriteIds = ref.watch(favoriteIdsProvider).valueOrNull ?? const {};

    return Scaffold(
      body: productAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: ErrorView(
            onRetry: () => ref.invalidate(productDetailsProvider(productId)),
          ),
        ),
        data: (product) {
          final isFavorite = favoriteIds.contains(product.id);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 300,
                backgroundColor: AppColors.surfaceLight,
                foregroundColor: AppColors.textPrimaryLight,
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? AppColors.error : null,
                    ),
                    onPressed: () => ref
                        .read(toggleFavoriteProvider)(product.id, !isFavorite),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: product.images.isNotEmpty
                      ? PageView(
                          children: product.images
                              .map((url) => CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppColors.borderLight,
                                    ),
                                  ))
                              .toList(),
                        )
                      : Container(
                          color: AppColors.borderLight,
                          child: const Icon(Icons.image_outlined, size: 64),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(0)} сомонӣ',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 10),
                            Text(
                              '${product.oldPrice!.toStringAsFixed(0)} с.',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.category_outlined,
                            label: ProductCategories.labelOf(product.category),
                          ),
                          _InfoChip(
                            icon: Icons.location_on_outlined,
                            label: product.city,
                          ),
                          if (product.deliveryAvailable)
                            const _InfoChip(
                              icon: Icons.local_shipping_outlined,
                              label: 'Бо доставка',
                            ),
                          _InfoChip(
                            icon: product.isAvailable
                                ? Icons.check_circle_outline
                                : Icons.cancel_outlined,
                            label: product.isAvailable
                                ? 'Мавҷуд (${product.quantity})'
                                : 'Номавҷуд',
                            color: product.isAvailable
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ],
                      ),
                      if (product.rating > 0) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppColors.warning, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating.toStringAsFixed(1)} '
                              '(${product.reviewsCount} шарҳ)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Тавсиф',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description.isNotEmpty
                            ? product.description
                            : 'Тавсиф илова карда нашудааст.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 100), // ҷой барои bottom bar
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: productAsync.maybeWhen(
        data: (product) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Тамос бо фурӯшанда'),
                    onPressed: () => _showComingSoon(context, 'Чат (PHASE 8)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text('Ба сабад'),
                    onPressed: product.isAvailable
                        ? () => _showComingSoon(context, 'Сабад (PHASE 7)')
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        orElse: () => null,
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature дар марҳилаи баъдӣ дастрас мешавад.')),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondaryLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: c)),
        ],
      ),
    );
  }
}
