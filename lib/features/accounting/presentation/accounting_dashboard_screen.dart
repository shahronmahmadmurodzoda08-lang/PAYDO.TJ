import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../orders/presentation/seller_orders_screen.dart';
import '../../products/presentation/my_products_screen.dart';
import 'accounting_providers.dart';
import 'debt_book_screen.dart';
import 'expenses_screen.dart';

/// Dashboard (banди 15): Today's sales, Monthly sales, Products,
/// Inventory, Debts, Orders, Income, Expenses, Profit.
class AccountingDashboardScreen extends ConsumerWidget {
  const AccountingDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(salesSummaryProvider);
    final productsCount = ref.watch(productsCountProvider);
    final totalDebt = ref.watch(totalRemainingDebtProvider);
    final totalExpenses = ref.watch(totalExpensesProvider);
    final netProfit = ref.watch(netProfitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Дафтари ҳисоб')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                label: 'Фурӯши имрӯз',
                value: '${sales.todaySales.toStringAsFixed(0)} с.',
                icon: Icons.today_outlined,
                color: AppColors.primary,
              ),
              _StatCard(
                label: 'Фурӯши моҳ',
                value: '${sales.monthSales.toStringAsFixed(0)} с.',
                icon: Icons.calendar_month_outlined,
                color: AppColors.info,
              ),
              _StatCard(
                label: 'Даромади умумӣ',
                value: '${sales.totalIncome.toStringAsFixed(0)} с.',
                icon: Icons.trending_up_rounded,
                color: AppColors.success,
              ),
              _StatCard(
                label: 'Хароҷот',
                value: '${totalExpenses.toStringAsFixed(0)} с.',
                icon: Icons.trending_down_rounded,
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: netProfit >= 0 ? AppColors.primaryLight : AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Фоидаи соф (Даромад − Хароҷот)',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  '${netProfit.toStringAsFixed(0)} с.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: netProfit >= 0 ? AppColors.primaryDark : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Идоракунӣ', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _NavTile(
            icon: Icons.inventory_2_outlined,
            label: 'Маҳсулот / Inventory',
            trailing: '$productsCount дона',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyProductsScreen()),
            ),
          ),
          _NavTile(
            icon: Icons.receipt_long_outlined,
            label: 'Фармоишҳо',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SellerOrdersScreen()),
            ),
          ),
          _NavTile(
            icon: Icons.book_outlined,
            label: 'Дафтари қарз',
            trailing: totalDebt > 0 ? '${totalDebt.toStringAsFixed(0)} с.' : null,
            trailingColor: totalDebt > 0 ? AppColors.error : null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DebtBookScreen()),
            ),
          ),
          _NavTile(
            icon: Icons.money_off_outlined,
            label: 'Хароҷот',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExpensesScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

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
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.trailingColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(label),
        trailing: trailing != null
            ? Text(trailing!,
                style: TextStyle(
                    color: trailingColor ?? AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w600))
            : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
        onTap: onTap,
      ),
    );
  }
}
