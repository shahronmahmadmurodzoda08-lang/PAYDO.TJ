import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('isAvailable = true вақте quantity>0 ва isHidden=false', () {
      const product = ProductModel(
        id: '1',
        sellerId: 's1',
        name: 'Test',
        description: '',
        price: 100,
        category: 'Phones',
        quantity: 5,
        city: 'Душанбе',
      );
      expect(product.isAvailable, true);
    });

    test('isAvailable = false вақте quantity=0', () {
      const product = ProductModel(
        id: '1',
        sellerId: 's1',
        name: 'Test',
        description: '',
        price: 100,
        category: 'Phones',
        quantity: 0,
        city: 'Душанбе',
      );
      expect(product.isAvailable, false);
    });

    test('hasDiscount = true вақте oldPrice > price', () {
      const product = ProductModel(
        id: '1',
        sellerId: 's1',
        name: 'Test',
        description: '',
        price: 80,
        oldPrice: 100,
        category: 'Phones',
        quantity: 1,
        city: 'Душанбе',
      );
      expect(product.hasDiscount, true);
    });

    test('fromMap маълумоти пурраро дуруст мехонад', () {
      final map = {
        'sellerId': 's1',
        'name': 'iPhone 15',
        'description': 'Нав',
        'price': 12000,
        'category': 'Phones',
        'quantity': 3,
        'city': 'Хуҷанд',
        'images': ['url1', 'url2'],
      };
      final product = ProductModel.fromMap('p1', map);

      expect(product.name, 'iPhone 15');
      expect(product.primaryImage, 'url1');
      expect(product.price, 12000);
    });
  });
}
