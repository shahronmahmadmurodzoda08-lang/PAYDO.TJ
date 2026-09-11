import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/firestore_paths.dart';
import '../../../core/errors/failures.dart';
import '../../../models/debt_model.dart';
import '../../../models/expense_model.dart';
import '../domain/accounting_repository.dart';

class AccountingRepositoryImpl implements AccountingRepository {
  final FirebaseFirestore _firestore;

  AccountingRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _debtsRef =>
      _firestore.collection(FirestorePaths.debts);

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection(FirestorePaths.expenses);

  @override
  Stream<List<DebtModel>> watchDebts(String ownerId) {
    return _debtsRef
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => DebtModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> addDebt(DebtModel debt) async {
    try {
      await _debtsRef.add(debt.toMap(isCreate: true));
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии сабти қарз: ${e.message}');
    }
  }

  @override
  Future<void> updateDebt(DebtModel debt) async {
    try {
      await _debtsRef.doc(debt.id).update(debt.toMap());
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии тағйири қарз: ${e.message}');
    }
  }

  @override
  Future<void> deleteDebt(String debtId) async {
    await _debtsRef.doc(debtId).delete();
  }

  @override
  Future<void> recordPayment({required String debtId, required double newPaidTotal}) async {
    await _debtsRef.doc(debtId).update({
      'paid': newPaidTotal,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses(String ownerId) {
    return _expensesRef
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ExpenseModel.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _expensesRef.add(expense.toMap(isCreate: true));
    } on FirebaseException catch (e) {
      throw ServerFailure('Хатогии сабти хароҷот: ${e.message}');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _expensesRef.doc(expenseId).delete();
  }
}
