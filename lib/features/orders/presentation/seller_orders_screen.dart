import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/order_model.dart';
import '../../auth/presentation/auth_providers.dart';
import 'order_providers.dart';

/// Экрани "order-ҳо барои идоракунӣ" аз тарафи seller/business owner
/// (banди 11: "Business owner бояд order-ҳоро бинад").
class SellerOrdersScreen extends ConsumerWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(sellerOrdersProvider);
    final myUid = ref.watch(authStateProvider).value?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Фармоишҳои фурӯш')),
      body: ordersAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(sellerOrdersProvider)),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyView(
              message: 'Ҳанӯз фармоише барои маҳсулоти шумо нест.',
              icon: Icons.receipt_long_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _SellerOrderCard(order: orders[index], myUid: myUid ?? ''),
          );
        },
      ),
    );
  }
}

class _SellerOrderCard extends ConsumerWidget {
  final OrderModel order;
  final String myUid;
  const _SellerOrderCard({required this.order, required this.myUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Танҳо item-ҳои ин seller дар доxили order нишон дода мешаванд.
    final myItems = order.items.where((i) => i.sellerId == myUid).toList();
    final nextStatus = order.status.next;

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
                child: Text(order.customerName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Text(order.status.label,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Text(order.customerPhone,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          ...myItems.map(
            (item) => Text(
              '${item.quantity}× ${item.productName} — '
              '${item.subtotal.toStringAsFixed(0)} с.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                order.deliveryType == DeliveryType.delivery
                    ? Icons.local_shipping_outlined
                    : Icons.store_outlined,
                size: 14,
                color: AppColors.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              Text(order.deliveryType.label,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondaryLight)),
              if (order.customerAddress != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.customerAddress!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondaryLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          if (nextStatus != null && order.status != OrderStatus.cancelled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(orderStatusUpdateProvider)(
                        order.id, OrderStatus.cancelled),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        minimumSize: const Size.fromHeight(40)),
                    child: const Text('Бекор кардан'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => ref
                        .read(orderStatusUpdateProvider)(order.id, nextStatus),
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40)),
                    child: Text('→ ${nextStatus.label}'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
