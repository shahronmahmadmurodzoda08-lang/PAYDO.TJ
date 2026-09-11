import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/expense_model.dart';
import '../../auth/presentation/auth_providers.dart';
import 'accounting_providers.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    final total = ref.watch(totalExpensesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Хароҷот')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Хароҷоти нав'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Ҷамъи хароҷот', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${total.toStringAsFixed(0)} сомонӣ',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryDark)),
              ],
            ),
          ),
          Expanded(
            child: expensesAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(onRetry: () => ref.invalidate(expensesProvider)),
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const EmptyView(
                    message: 'Хароҷот сабт нашудааст.',
                    icon: Icons.money_off_outlined,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: expenses.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.primaryLight,
                        child: Icon(Icons.receipt_outlined, color: AppColors.primary, size: 18),
                      ),
                      title: Text(expense.title),
                      subtitle: expense.date != null
                          ? Text(DateFormat('dd.MM.yyyy').format(expense.date!))
                          : (expense.notes != null ? Text(expense.notes!) : null),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('-${expense.amount.toStringAsFixed(0)} с.',
                              style: const TextStyle(
                                  color: AppColors.error, fontWeight: FontWeight.w600)),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () => ref
                                .read(accountingActionControllerProvider.notifier)
                                .deleteExpense(expense.id),
                          ),
                        ],
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

  Future<void> _showAddExpenseDialog(BuildContext context, WidgetRef ref) async {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Хароҷоти нав'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Ном (масалан: Кироя) *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Маблағ (сомонӣ) *'),
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
    if (titleCtrl.text.trim().isEmpty) return;

    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) return;

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final expense = ExpenseModel(
      id: '',
      ownerId: uid,
      title: titleCtrl.text.trim(),
      amount: amount,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      date: DateTime.now(),
    );

    await ref.read(accountingActionControllerProvider.notifier).addExpense(expense);
  }
}
