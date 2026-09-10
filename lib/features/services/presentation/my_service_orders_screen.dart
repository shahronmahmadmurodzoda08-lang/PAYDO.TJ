import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/service_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/service_order_model.dart';
import 'services_providers.dart';

class MyServiceOrdersScreen extends ConsumerWidget {
  const MyServiceOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myServiceOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Дархостҳои ман')),
      body: ordersAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(myServiceOrdersProvider)),
        data: (orders) {
          if (orders.isEmpty) {
            return const EmptyView(
              message: 'Шумо ҳанӯз дархости хизматрасонӣ надодаед.',
              icon: Icons.build_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _OrderCard(order: orders[index]),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ServiceOrderModel order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case ServiceOrderStatus.pending:
        return AppColors.warning;
      case ServiceOrderStatus.accepted:
        return AppColors.info;
      case ServiceOrderStatus.completed:
        return AppColors.success;
      case ServiceOrderStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: Text(order.providerName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.status.label,
                    style: TextStyle(fontSize: 11, color: _statusColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Text(ServiceCategories.labelOf(order.serviceCategory),
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
          if (order.notes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(order.notes, style: const TextStyle(fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
