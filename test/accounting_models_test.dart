import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/debt_model.dart';
import 'package:paydo_tj/models/expense_model.dart';
import 'package:paydo_tj/models/product_model.dart';

void main() {
  group('DebtModel', () {
    test('remaining = amount - paid', () {
      const debt = DebtModel(
        id: '1',
        ownerId: 'o1',
        customerName: 'Алишер',
        amount: 200,
        paid: 50,
      );
      expect(debt.remaining, 150);
      expect(debt.isFullyPaid, false);
    });

    test('isFullyPaid = true вақте paid >= amount', () {
      const debt = DebtModel(
        id: '1',
        ownerId: 'o1',
        customerName: 'Алишер',
        amount: 200,
        paid: 200,
      );
      expect(debt.remaining, 0);
      expect(debt.isFullyPaid, true);
    });

    test('remaining ҳеҷ гоҳ манфӣ намешавад (clamp)', () {
      const debt = DebtModel(
        id: '1',
        ownerId: 'o1',
        customerName: 'Test',
        amount: 100,
        paid: 150, // хатогии воридкунӣ эҳтимолӣ
      );
      expect(debt.remaining, 0);
    });
  });

  group('ExpenseModel', () {
    test('fromMap маълумоти пурраро дуруст мехонад', () {
      final map = {'ownerId': 'o1', 'title': 'Кироя', 'amount': 500};
      final expense = ExpenseModel.fromMap('e1', map);
      expect(expense.title, 'Кироя');
      expect(expense.amount, 500);
    });
  });

  group('ProductModel.profitPerUnit', () {
    test('фоида дуруст ҳисоб мешавад вақте purchasePrice дода шуда бошад', () {
      const product = ProductModel(
        id: '1',
        sellerId: 's1',
        name: 'Test',
        description: '',
        price: 150,
        purchasePrice: 100,
        category: 'Phones',
        city: 'Душанбе',
      );
      expect(product.profitPerUnit, 50);
    });

    test('null бармегардонад агар purchasePrice дода нашуда бошад', () {
      const product = ProductModel(
        id: '1',
        sellerId: 's1',
        name: 'Test',
        description: '',
        price: 150,
        category: 'Phones',
        city: 'Душанбе',
      );
      expect(product.profitPerUnit, null);
    });
  });
}
