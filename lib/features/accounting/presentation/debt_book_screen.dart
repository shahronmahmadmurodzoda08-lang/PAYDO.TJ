import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/debt_model.dart';
import '../../auth/presentation/auth_providers.dart';
import 'accounting_providers.dart';

class DebtBookScreen extends ConsumerWidget {
  const DebtBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsProvider);
    final totalDebt = ref.watch(totalRemainingDebtProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Дафтари қарз')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDebtDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Қарзи нав'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ҷамъи қарзи боқимонда', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${totalDebt.toStringAsFixed(0)} сомонӣ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.error)),
              ],
            ),
          ),
          Expanded(
            child: debtsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(onRetry: () => ref.invalidate(debtsProvider)),
              data: (debts) {
                if (debts.isEmpty) {
                  return const EmptyView(
                    message: 'Дафтари қарз холист.',
                    icon: Icons.book_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: debts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _DebtTile(debt: debts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDebtDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Қарзи нав'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Номи мизоҷ *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Телефон'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Маблағи қарз (сомонӣ) *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Эзоҳ'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Бекор'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Сабт кардан'),
          ),
        ],
      ),
    );

    if (result != true) return;
    if (nameCtrl.text.trim().isEmpty) return;

    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) return;

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final debt = DebtModel(
      id: '',
      ownerId: uid,
      customerName: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      amount: amount,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      date: DateTime.now(),
    );

    await ref.read(accountingActionControllerProvider.notifier).addDebt(debt);
  }
}

class _DebtTile extends ConsumerWidget {
  final DebtModel debt;
  const _DebtTile({required this.debt});

  Future<void> _addPayment(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пардохт илова кардан'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
              labelText: 'Маблағ (боқимонда: ${debt.remaining.toStringAsFixed(0)} с.)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Бекор'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(double.tryParse(ctrl.text.trim())),
            child: const Text('Сабт кардан'),
          ),
        ],
      ),
    );

    if (result != null && result > 0) {
      final newPaid = (debt.paid + result).clamp(0, debt.amount);
      await ref
          .read(accountingActionControllerProvider.notifier)
          .recordPayment(debt.id, newPaid.toDouble());
    }
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
                child: Text(debt.customerName, style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              if (debt.isFullyPaid)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Пардохта шуд',
                      style: TextStyle(fontSize: 11, color: AppColors.success)),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                onPressed: () =>
                    ref.read(accountingActionControllerProvider.notifier).deleteDebt(debt.id),
              ),
            ],
          ),
          if (debt.phone != null)
            Text(debt.phone!,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _amountColumn('Қарз', debt.amount, AppColors.textPrimaryLight),
              ),
              Expanded(
                child: _amountColumn('Пардохт', debt.paid, AppColors.success),
              ),
              Expanded(
                child: _amountColumn('Боқимонда', debt.remaining, AppColors.error),
              ),
            ],
          ),
          if (debt.notes != null) ...[
            const SizedBox(height: 6),
            Text(debt.notes!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
          if (!debt.isFullyPaid) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _addPayment(context, ref),
                child: const Text('Пардохт илова кардан'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _amountColumn(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        Text('${value.toStringAsFixed(0)} с.',
            style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
      ],
    );
  }
}
