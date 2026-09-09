import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/business_model.dart';

void main() {
  group('BusinessModel', () {
    test('fromMap маълумоти пурраро дуруст мехонад', () {
      final map = {
        'ownerId': 'uid_1',
        'businessName': 'Дӯкони Алишер',
        'city': 'Душанбе',
        'deliveryAvailable': true,
        'rating': 4.5,
        'reviewsCount': 12,
      };

      final business = BusinessModel.fromMap('uid_1', map);

      expect(business.businessName, 'Дӯкони Алишер');
      expect(business.deliveryAvailable, true);
      expect(business.rating, 4.5);
    });

    test('copyWith тағйир медиҳад танҳо майдонҳои зикршуда', () {
      const business = BusinessModel(
        id: 'uid_1',
        ownerId: 'uid_1',
        businessName: 'Old',
        city: 'Душанбе',
      );

      final updated = business.copyWith(businessName: 'New', city: 'Хуҷанд');

      expect(updated.businessName, 'New');
      expect(updated.city, 'Хуҷанд');
      expect(updated.ownerId, business.ownerId);
    });

    test('id ва ownerId баробаранд (Қарори тарроҳии PHASE 5)', () {
      const business = BusinessModel(
        id: 'uid_1',
        ownerId: 'uid_1',
        businessName: 'Test',
        city: 'Душанбе',
      );
      expect(business.id, business.ownerId);
    });
  });
}
