import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/service_order_model.dart';
import 'package:paydo_tj/models/service_provider_model.dart';

void main() {
  group('ServiceProviderModel', () {
    test('fromMap маълумоти пурраро дуруст мехонад', () {
      final map = {
        'name': 'Фарҳод',
        'serviceCategory': 'Electrician',
        'city': 'Душанбе',
        'price': 150,
        'isVisible': true,
      };
      final provider = ServiceProviderModel.fromMap('uid1', map);

      expect(provider.name, 'Фарҳод');
      expect(provider.serviceCategory, 'Electrician');
      expect(provider.price, 150);
    });

    test('isVisible пешфарз true аст', () {
      const provider = ServiceProviderModel(
        uid: 'uid1',
        name: 'Test',
        serviceCategory: 'Plumber',
        city: 'Хуҷанд',
      );
      expect(provider.isVisible, true);
    });
  });

  group('ServiceOrderStatus', () {
    test('label-ҳо дуруст бармегарданд', () {
      expect(ServiceOrderStatus.pending.label, 'Дар интизорӣ');
      expect(ServiceOrderStatus.accepted.label, 'Қабул шуд');
      expect(ServiceOrderStatus.completed.label, 'Анҷом ёфт');
      expect(ServiceOrderStatus.cancelled.label, 'Бекор карда шуд');
    });

    test('fromString пешфарзи pending дорад', () {
      expect(ServiceOrderStatusX.fromString('unknown'), ServiceOrderStatus.pending);
      expect(ServiceOrderStatusX.fromString('completed'), ServiceOrderStatus.completed);
    });
  });
}
