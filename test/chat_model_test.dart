import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/chat_model.dart';

void main() {
  group('ChatModel', () {
    const chat = ChatModel(
      id: 'uidA_uidB',
      participantIds: ['uidA', 'uidB'],
      participantNames: {'uidA': 'Алишер', 'uidB': 'Фурӯшанда'},
      unreadCounts: {'uidA': 0, 'uidB': 3},
    );

    test('otherParticipantId дуруст муайян мекунад', () {
      expect(chat.otherParticipantId('uidA'), 'uidB');
      expect(chat.otherParticipantId('uidB'), 'uidA');
    });

    test('otherParticipantName номи дурустро бармегардонад', () {
      expect(chat.otherParticipantName('uidA'), 'Фурӯшанда');
    });

    test('unreadCountFor барои ҳар корбар алоҳида кор мекунад', () {
      expect(chat.unreadCountFor('uidA'), 0);
      expect(chat.unreadCountFor('uidB'), 3);
    });
  });

  group('chat id determinism (concept)', () {
    // Ҳамон мантиқи _deterministicChatId дар ChatRepositoryImpl:
    // sort([a,b]).join('_') — санҷиши он ки тартиб аҳамият надорад.
    String deterministicId(String a, String b) {
      final sorted = [a, b]..sort();
      return '${sorted[0]}_${sorted[1]}';
    }

    test('тартиби параметрҳо натиҷаро тағйир намедиҳад', () {
      expect(deterministicId('uidA', 'uidB'), deterministicId('uidB', 'uidA'));
    });
  });
}
