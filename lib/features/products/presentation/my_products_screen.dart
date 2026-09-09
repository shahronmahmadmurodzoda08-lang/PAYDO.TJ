import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/product_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/product_model.dart';
import 'add_edit_product_screen.dart';
import 'product_management_providers.dart';

class MyProductsScreen extends ConsumerWidget {
  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(myProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Маҳсулоти ман')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditProductScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Маҳсулоти нав'),
      ),
      body: productsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(myProductsProvider)),
        data: (products) {
          if (products.isEmpty) {
            return const EmptyView(
              message: 'Шумо ҳанӯз маҳсулот илова накардаед.',
              icon: Icons.inventory_2_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _MyProductTile(product: products[index]),
          );
        },
      ),
    );
  }
}

class _MyProductTile extends ConsumerWidget {
  final ProductModel product;
  const _MyProductTile({required this.product});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Нест кардани маҳсулот?'),
        content: Text('"${product.name}" бебозгашт нест карда мешавад.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Бекор'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Нест кардан',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(productFormControllerProvider.notifier).delete(product.id);
    }
  }

  Future<void> _editQuantity(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: product.quantity.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тағйири миқдор'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Миқдор (дона)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Бекор'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(int.tryParse(ctrl.text.trim())),
            child: const Text('Нигоҳ доштан'),
          ),
        ],
      ),
    );

    if (result != null && result >= 0) {
      await ref
          .read(productFormControllerProvider.notifier)
          .updateQuantity(product.id, result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: product.primaryImage.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.primaryImage,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: AppColors.borderLight,
                    child: const Icon(Icons.image_outlined),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${product.price.toStringAsFixed(0)} с. · '
                  '${ProductCategories.labelOf(product.category)}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _editQuantity(context, ref),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        product.quantity > 0
                            ? Icons.inventory_2_outlined
                            : Icons.warning_amber_rounded,
                        size: 14,
                        color: product.quantity > 0
                            ? AppColors.textSecondaryLight
                            : AppColors.error,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.quantity > 0
                            ? '${product.quantity} дона'
                            : 'Номавҷуд',
                        style: TextStyle(
                          fontSize: 12,
                          color: product.quantity > 0
                              ? AppColors.textSecondaryLight
                              : AppColors.error,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
                if (product.isHidden)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Пинҳон',
                          style: TextStyle(fontSize: 10, color: AppColors.warning)),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AddEditProductScreen(existing: product),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  product.isHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () => ref
                    .read(productFormControllerProvider.notifier)
                    .setHidden(product.id, !product.isHidden),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 20, color: AppColors.error),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
