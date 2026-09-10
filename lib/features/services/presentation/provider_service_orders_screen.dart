import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/service_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/service_order_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../chat/presentation/chat_detail_screen.dart';
import '../../chat/presentation/chat_providers.dart';
import 'services_providers.dart';

class ProviderServiceOrdersScreen extends ConsumerWidget {
  const ProviderServiceOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(providerServiceOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Дархостҳои омада')),
      body: ordersAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(providerServiceOrdersProvider)),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyView(
              message: 'Ҳанӯз дархост нест.',
              icon: Icons.build_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _ProviderOrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _ProviderOrderCard extends ConsumerWidget {
  final ServiceOrderModel order;
  const _ProviderOrderCard({required this.order});

  Future<void> _chat(BuildContext context, WidgetRef ref) async {
    final me = ref.read(authStateProvider).value;
    if (me == null) return;

    final chatId = await ref.read(startChatProvider)(
      myUid: me.uid,
      myName: me.name,
      myPhoto: me.photoUrl,
      otherUid: order.customerId,
      otherName: order.customerName,
      contextType: 'service',
      contextTitle: ServiceCategories.labelOf(order.serviceCategory),
    );

    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatDetailScreen(chatId: chatId)));
  }

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
                child: Text(order.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                onPressed: () => _chat(context, ref),
              ),
            ],
          ),
          Text(order.customerPhone,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
          if (order.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(order.notes, style: const TextStyle(fontSize: 13)),
          ],
          if (order.status != ServiceOrderStatus.completed &&
              order.status != ServiceOrderStatus.cancelled) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (order.status == ServiceOrderStatus.pending)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ref
                          .read(servicesActionControllerProvider.notifier)
                          .updateOrderStatus(order.id, ServiceOrderStatus.accepted),
                      child: const Text('Қабул кардан'),
                    ),
                  ),
                if (order.status == ServiceOrderStatus.accepted)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => ref
                          .read(servicesActionControllerProvider.notifier)
                          .updateOrderStatus(order.id, ServiceOrderStatus.completed),
                      child: const Text('Анҷом ёфт'),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    onPressed: () => ref
                        .read(servicesActionControllerProvider.notifier)
                        .updateOrderStatus(order.id, ServiceOrderStatus.cancelled),
                    child: const Text('Бекор кардан'),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(order.status.label,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
          ],
        ],
      ),
    );
  }
}
