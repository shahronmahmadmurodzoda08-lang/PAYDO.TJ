import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/order_model.dart';

void main() {
  group('OrderStatus', () {
    test('пайдарпаии дуруст: pending → accepted → ... → completed', () {
      expect(OrderStatus.pending.next, OrderStatus.accepted);
      expect(OrderStatus.accepted.next, OrderStatus.preparing);
      expect(OrderStatus.preparing.next, OrderStatus.ready);
      expect(OrderStatus.ready.next, OrderStatus.shipped);
      expect(OrderStatus.shipped.next, OrderStatus.delivering);
      expect(OrderStatus.delivering.next, OrderStatus.completed);
    });

    test('completed ва cancelled next=null доранд (охирин ҳолат)', () {
      expect(OrderStatus.completed.next, null);
      expect(OrderStatus.cancelled.next, null);
    });
  });

  group('OrderModel', () {
    test('fromMap items-ро дуруст мехонад', () {
      final map = {
        'customerId': 'c1',
        'customerName': 'Алишер',
        'customerPhone': '900000000',
        'customerCity': 'Душанбе',
        'items': [
          {
            'productId': 'p1',
            'productName': 'Test',
            'price': 100,
            'quantity': 2,
            'sellerId': 's1',
          },
        ],
        'deliveryType': 'delivery',
        'subtotal': 200,
        'deliveryFee': 15,
        'total': 215,
        'status': 'accepted',
        'sellerIds': ['s1'],
      };

      final order = OrderModel.fromMap('o1', map);

      expect(order.items.length, 1);
      expect(order.items.first.subtotal, 200);
      expect(order.status, OrderStatus.accepted);
      expect(order.total, 215);
    });

    test('copyWithId ID-ро дуруст иваз мекунад, боқимонда тағйир намеёбад', () {
      const order = OrderModel(
        id: '',
        customerId: 'c1',
        customerName: 'Test',
        customerPhone: '900000000',
        customerCity: 'Душанбе',
        items: [],
        deliveryType: DeliveryType.pickup,
        subtotal: 0,
        deliveryFee: 0,
        total: 0,
        sellerIds: [],
      );

      final withId = order.copyWithId('new_id');
      expect(withId.id, 'new_id');
      expect(withId.customerId, order.customerId);
    });
  });
}
