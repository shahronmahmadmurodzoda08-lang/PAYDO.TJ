import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/product_model.dart';
import 'marketplace_providers.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoriteIdsProvider).valueOrNull ?? const {};
    final isFavorite = favoriteIds.contains(product.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  product.primaryImage.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: product.primaryImage,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.borderLight,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.borderLight,
                            child: const Icon(Icons.image_not_supported_outlined),
                          ),
                        )
                      : Container(
                          color: AppColors.borderLight,
                          child: const Icon(Icons.image_outlined,
                              color: AppColors.textSecondaryLight),
                        ),
                  if (product.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Badge(
                        text: '-${product.discount ?? 0}%',
                        color: AppColors.error,
                      ),
                    ),
                  if (!product.isAvailable)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Badge(
                        text: 'Номавҷуд',
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color:
                            isFavorite ? AppColors.error : Colors.white,
                        shadows: const [
                          Shadow(blurRadius: 6, color: Colors.black45),
                        ],
                      ),
                      onPressed: () => ref
                          .read(toggleFavoriteProvider)(product.id, !isFavorite),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} с.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 6),
                        Text(
                          '${product.oldPrice!.toStringAsFixed(0)} с.',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textSecondaryLight,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          product.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ),
                      if (product.rating > 0) ...[
                        const Icon(Icons.star_rounded,
                            size: 13, color: AppColors.warning),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}
