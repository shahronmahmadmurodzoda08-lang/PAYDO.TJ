import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/courier_model.dart';
import 'package:paydo_tj/models/delivery_model.dart';

void main() {
  group('DeliveryStatus', () {
    test('пайдарпаии дуруст: assigned → pickedUp → onTheWay → delivered', () {
      expect(DeliveryStatus.assigned.next, DeliveryStatus.pickedUp);
      expect(DeliveryStatus.pickedUp.next, DeliveryStatus.onTheWay);
      expect(DeliveryStatus.onTheWay.next, DeliveryStatus.delivered);
      expect(DeliveryStatus.delivered.next, null);
    });

    test('label-ҳо дуруст бармегарданд', () {
      expect(DeliveryStatus.assigned.label, 'Таъин шуд');
      expect(DeliveryStatus.delivered.label, 'Расонида шуд');
    });
  });

  group('CourierStatus', () {
    test('fromString пешфарзи offline дорад', () {
      expect(CourierStatusX.fromString('unknown'), CourierStatus.offline);
      expect(CourierStatusX.fromString('available'), CourierStatus.available);
    });
  });

  group('DeliveryModel', () {
    test('fromMap маълумоти пурраро дуруст мехонад', () {
      final map = {
        'orderId': 'o1',
        'courierId': 'c1',
        'courierName': 'Далер',
        'customerId': 'u1',
        'customerName': 'Алишер',
        'customerAddress': 'Кӯчаи Рӯдакӣ',
        'customerCity': 'Душанбе',
        'status': 'onTheWay',
      };
      final delivery = DeliveryModel.fromMap('o1', map);

      expect(delivery.status, DeliveryStatus.onTheWay);
      expect(delivery.courierName, 'Далер');
    });
  });
}
