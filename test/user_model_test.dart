import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('newFromGoogle sets default accountTypes = [user]', () {
      final user = UserModel.newFromGoogle(
        uid: 'uid_1',
        name: 'Алишер',
        email: 'ali@example.com',
      );

      expect(user.uid, 'uid_1');
      expect(user.accountTypes, [AccountType.user]);
      expect(user.phoneVisible, false);
      expect(user.ageVisible, false);
    });

    test('fromMap parses accountTypes рӯйхат дуруст', () {
      final map = {
        'name': 'Алишер',
        'email': 'ali@example.com',
        'accountTypes': ['user', 'business'],
        'phoneVisible': true,
      };

      final user = UserModel.fromMap('uid_2', map);

      expect(user.accountTypes,
          [AccountType.user, AccountType.business]);
      expect(user.phoneVisible, true);
    });

    test('toMap(isCreate: true) дорои createdAt мебошад', () {
      final user = UserModel.newFromGoogle(
        uid: 'uid_3',
        name: 'Test',
        email: 'test@example.com',
      );

      final map = user.toMap(isCreate: true);

      expect(map.containsKey('createdAt'), true);
      expect(map.containsKey('updatedAt'), true);
      expect(map['uid'], 'uid_3');
    });

    test('copyWith тағйир медиҳад танҳо майдонҳои зикршуда', () {
      final user = UserModel.newFromGoogle(
        uid: 'uid_4',
        name: 'Old Name',
        email: 'test@example.com',
      );

      final updated = user.copyWith(name: 'New Name', city: 'Душанбе');

      expect(updated.name, 'New Name');
      expect(updated.city, 'Душанбе');
      expect(updated.email, user.email); // тағйир наёфт
    });
  });
}
