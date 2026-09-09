import 'package:flutter_test/flutter_test.dart';

/// Ҳамон формулаи ҳисоби discount, ки дар
/// `AddEditProductScreen._save()` истифода мешавад — дар ин ҷо
/// алоҳида санҷида мешавад (unit-level), то UI test лозим набошад.
int? calculateDiscount(double price, double? oldPrice) {
  if (oldPrice != null && oldPrice > price && oldPrice > 0) {
    return (((oldPrice - price) / oldPrice) * 100).round();
  }
  return null;
}

void main() {
  group('calculateDiscount', () {
    test('20% discount дуруст ҳисоб мешавад', () {
      expect(calculateDiscount(80, 100), 20);
    });

    test('вақте oldPrice дода нашуда бошад, null бармегардонад', () {
      expect(calculateDiscount(80, null), null);
    });

    test('вақте oldPrice < price (мантиқан нодуруст), null бармегардонад', () {
      expect(calculateDiscount(100, 80), null);
    });

    test('50% discount', () {
      expect(calculateDiscount(50, 100), 50);
    });
  });
}
