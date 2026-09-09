import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/features/home/domain/home_category.dart';

void main() {
  group('HomeCategory', () {
    test('дорои 8 категорияи асосӣ мутобиқи спецификатсия аст', () {
      expect(HomeCategory.all.length, 8);
    });

    test('ҳар категория routeKey-и такрорнашаванда дорад', () {
      final keys = HomeCategory.all.map((c) => c.routeKey).toSet();
      expect(keys.length, HomeCategory.all.length);
    });

    test('категорияи "Магазин" бо routeKey=marketplace мавҷуд аст', () {
      final marketplace =
          HomeCategory.all.where((c) => c.routeKey == 'marketplace');
      expect(marketplace.length, 1);
      expect(marketplace.first.label, 'Магазин');
    });
  });
}
