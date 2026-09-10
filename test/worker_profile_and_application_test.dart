import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/job_application_model.dart';
import 'package:paydo_tj/models/worker_profile_model.dart';

void main() {
  group('WorkerProfileModel', () {
    test('fromMap skills-ро дуруст мехонад', () {
      final map = {
        'name': 'Алишер',
        'city': 'Душанбе',
        'profession': 'Дизайнер',
        'skills': ['Figma', 'Photoshop'],
        'isVisible': false,
      };
      final worker = WorkerProfileModel.fromMap('uid1', map);

      expect(worker.skills, ['Figma', 'Photoshop']);
      expect(worker.isVisible, false);
    });

    test('isVisible пешфарз true аст', () {
      const worker = WorkerProfileModel(
        uid: 'uid1',
        name: 'Test',
        city: 'Душанбе',
        profession: 'Test',
      );
      expect(worker.isVisible, true);
    });
  });

  group('JobApplicationModel / ApplicationStatus', () {
    test('label-ҳо дуруст бармегарданд', () {
      expect(ApplicationStatus.pending.label, 'Дар интизорӣ');
      expect(ApplicationStatus.accepted.label, 'Қабул шуд');
      expect(ApplicationStatus.rejected.label, 'Рад шуд');
    });

    test('fromMap пешфарзи pending', () {
      final map = {
        'jobId': 'j1',
        'jobTitle': 'Test',
        'workerId': 'w1',
        'workerName': 'Test',
        'employerId': 'e1',
      };
      final app = JobApplicationModel.fromMap('j1_w1', map);
      expect(app.status, ApplicationStatus.pending);
      expect(app.id, 'j1_w1');
    });
  });
}
