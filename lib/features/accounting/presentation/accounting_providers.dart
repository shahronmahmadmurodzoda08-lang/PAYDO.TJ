import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/debt_model.dart';
import '../../../models/expense_model.dart';
import '../../../models/order_model.dart';
import '../data/accounting_repository_impl.dart';
import '../domain/accounting_repository.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../orders/presentation/order_providers.dart';
import '../../products/presentation/product_management_providers.dart';

final accountingRepositoryProvider = Provider<AccountingRepository>((ref) {
  return AccountingRepositoryImpl();
});

final debtsProvider = StreamProvider<List<DebtModel>>((ref) {
  final repo = ref.watch(accountingRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchDebts(uid);
});

final totalRemainingDebtProvider = Provider<double>((ref) {
  final debts = ref.watch(debtsProvider).valueOrNull ?? const [];
  return debts.fold(0.0, (sum, d) => sum + d.remaining);
});

final expensesProvider = StreamProvider<List<ExpenseModel>>((ref) {
  final repo = ref.watch(accountingRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchExpenses(uid);
});

final totalExpensesProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider).valueOrNull ?? const [];
  return expenses.fold(0.0, (sum, e) => sum + e.amount);
});

/// Ҷамъбасти "фурӯш" (income) — бевосита аз `sellerOrdersProvider`-и
/// феҳаи Orders (PHASE 7) ҳисоб мешавад, на аз коллексияи алоҳида
/// (ниг. эзоҳи тарроҳӣ дар domain/accounting_repository.dart).
class SalesSummary {
  final double todaySales;
  final double monthSales;
  final double totalIncome; // ҳамаи вақт (completed)

  const SalesSummary({
    this.todaySales = 0,
    this.monthSales = 0,
    this.totalIncome = 0,
  });
}

final salesSummaryProvider = Provider<SalesSummary>((ref) {
  final uid = ref.watch(authStateProvider).value?.uid;
  final orders = ref.watch(sellerOrdersProvider).valueOrNull ?? const [];
  if (uid == null) return const SalesSummary();

  final now = DateTime.now();
  double today = 0, month = 0, total = 0;

  for (final order in orders) {
    // Ҳисоб мешавад: танҳо status=completed, ва танҳо item-ҳои ин
    // seller (на тамоми order, зеро order метавонад аз якчанд seller
    // маҳсулот дошта бошад — ниг. эзоҳи OrderModel.sellerIds).
    if (order.status != OrderStatus.completed) continue;
    final myItemsTotal = order.items
        .where((i) => i.sellerId == uid)
        .fold(0.0, (sum, i) => sum + i.subtotal);

    total += myItemsTotal;

    final createdAt = order.createdAt;
    if (createdAt == null) continue;
    if (createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day) {
      today += myItemsTotal;
    }
    if (createdAt.year == now.year && createdAt.month == now.month) {
      month += myItemsTotal;
    }
  }

  return SalesSummary(todaySales: today, monthSales: month, totalIncome: total);
});

/// Шумораи маҳсулот — бевосита аз `myProductsProvider`-и феҳаи
/// Products (PHASE 6).
final productsCountProvider = Provider<int>((ref) {
  return ref.watch(myProductsProvider).valueOrNull?.length ?? 0;
});

final netProfitProvider = Provider<double>((ref) {
  final income = ref.watch(salesSummaryProvider).totalIncome;
  final expenses = ref.watch(totalExpensesProvider);
  return income - expenses;
});

class AccountingActionState {
  final bool isSaving;
  const AccountingActionState({this.isSaving = false});
  AccountingActionState copyWith({bool? isSaving}) =>
      AccountingActionState(isSaving: isSaving ?? this.isSaving);
}

class AccountingActionController extends StateNotifier<AccountingActionState> {
  final AccountingRepository _repository;
  AccountingActionController(this._repository) : super(const AccountingActionState());

  Future<void> addDebt(DebtModel debt) async {
    state = state.copyWith(isSaving: true);
    await _repository.addDebt(debt);
    state = state.copyWith(isSaving: false);
  }

  Future<void> recordPayment(String debtId, double newPaidTotal) =>
      _repository.recordPayment(debtId: debtId, newPaidTotal: newPaidTotal);

  Future<void> deleteDebt(String debtId) => _repository.deleteDebt(debtId);

  Future<void> addExpense(ExpenseModel expense) async {
    state = state.copyWith(isSaving: true);
    await _repository.addExpense(expense);
    state = state.copyWith(isSaving: false);
  }

  Future<void> deleteExpense(String expenseId) => _repository.deleteExpense(expenseId);
}

final accountingActionControllerProvider =
    StateNotifierProvider<AccountingActionController, AccountingActionState>((ref) {
  final repo = ref.watch(accountingRepositoryProvider);
  return AccountingActionController(repo);
});
