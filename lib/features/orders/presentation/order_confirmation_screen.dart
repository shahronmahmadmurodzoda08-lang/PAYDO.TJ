import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/order_model.dart';
import 'order_history_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final OrderModel order;
  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              Text(
                'Фармоиши шумо қабул шуд!',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${order.deliveryType.label} · ${order.total.toStringAsFixed(0)} сомонӣ',
                style: const TextStyle(color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                    (route) => route.isFirst,
                  ),
                  child: const Text('Фармоишҳои ман'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('Бозгашт ба Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
