import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/vacancy_model.dart';

void main() {
  group('VacancyModel', () {
    test('salaryRangeLabel вақте ҳарду null бошанд', () {
      const v = VacancyModel(
        id: '1',
        employerId: 'e1',
        employerName: 'Test',
        title: 'Test',
        description: '',
        city: 'Душанбе',
      );
      expect(v.salaryRangeLabel, 'Мувофиқа мешавад');
    });

    test('salaryRangeLabel вақте min ва max ҳарду дошта бошанд', () {
      const v = VacancyModel(
        id: '1',
        employerId: 'e1',
        employerName: 'Test',
        title: 'Test',
        description: '',
        city: 'Душанбе',
        salaryMin: 3000,
        salaryMax: 5000,
      );
      expect(v.salaryRangeLabel, '3000 - 5000 с.');
    });

    test('matchesAge дуруст кор мекунад', () {
      const v = VacancyModel(
        id: '1',
        employerId: 'e1',
        employerName: 'Test',
        title: 'Test',
        description: '',
        city: 'Душанбе',
        ageMin: 20,
        ageMax: 35,
      );
      expect(v.matchesAge(25), true);
      expect(v.matchesAge(18), false);
      expect(v.matchesAge(40), false);
      expect(v.matchesAge(null), true);
    });
  });
}
