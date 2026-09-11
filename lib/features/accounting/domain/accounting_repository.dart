import '../../../models/debt_model.dart';
import '../../../models/expense_model.dart';

/// Domain layer барои Дафтари ҳисоб (banди 15).
///
/// Қарори тарроҳӣ: "Sales" ва "Products/Inventory" дар ин repository
/// НЕСТАНД — онҳо аз феҳаҳои аллакай мавҷуда (Orders, PHASE 7 ва
/// Products, PHASE 6) бевосита истифода мешаванд, на дучандӣ карда
/// мешаванд дар коллексияи алоҳидаи `sales`/`inventory`. Сабаб:
/// `orders` (status=completed) аллакай ҳамаи маълумоти "фурӯш"-ро
/// дорад, ва `products` (бо purchasePrice-и нав, ниг. PHASE 11-и
/// pubspec/models) аллакай ҳамаи маълумоти "inventory"-ро дорад —
/// сохтани коллексияи дуввум маънои ду манбаи ҳақиқат ва хатари
/// desync-ро дошт (хилофи banди 27: "Avoid unnecessary duplication").
/// Ниг. тавзеҳи муфассал дар docs/architecture.md.
abstract class AccountingRepository {
  // ---- Debts ----
  Stream<List<DebtModel>> watchDebts(String ownerId);
  Future<void> addDebt(DebtModel debt);
  Future<void> updateDebt(DebtModel debt);
  Future<void> deleteDebt(String debtId);
  Future<void> recordPayment({required String debtId, required double newPaidTotal});

  // ---- Expenses ----
  Stream<List<ExpenseModel>> watchExpenses(String ownerId);
  Future<void> addExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
}
