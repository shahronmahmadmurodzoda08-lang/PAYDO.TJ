import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/chat_model.dart';
import '../data/chat_repository_impl.dart';
import '../domain/chat_repository.dart';
import '../../auth/presentation/auth_providers.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl();
});

final myChatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return Stream.value(const []);
  return repo.watchMyChats(uid);
});

/// Ҷамъи хабарҳои нахонда дар ҳама чатҳо — барои badge дар Home/RootShell.
final totalUnreadCountProvider = Provider<int>((ref) {
  final chats = ref.watch(myChatsProvider).valueOrNull ?? const [];
  final uid = ref.watch(authStateProvider).value?.uid;
  if (uid == null) return 0;
  return chats.fold(0, (sum, c) => sum + c.unreadCountFor(uid));
});

final chatMessagesProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(chatId);
});

final chatByIdProvider =
    StreamProvider.family<ChatModel?, String>((ref, chatId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchChat(chatId);
});

/// Кушодан/сохтани чат бо корбари дигар — истифода аз Product/Business/
/// Job/Service details, бе такрори мантиқ дар ҳар феҷа.
final startChatProvider = Provider<
    Future<String> Function({
      required String myUid,
      required String myName,
      String? myPhoto,
      required String otherUid,
      required String otherName,
      String? otherPhoto,
      String? contextType,
      String? contextId,
      String? contextTitle,
    })>((ref) {
  final repo = ref.watch(chatRepositoryProvider);
  return ({
    required myUid,
    required myName,
    myPhoto,
    required otherUid,
    required otherName,
    otherPhoto,
    contextType,
    contextId,
    contextTitle,
  }) =>
      repo.getOrCreateChat(
        myUid: myUid,
        myName: myName,
        myPhoto: myPhoto,
        otherUid: otherUid,
        otherName: otherName,
        otherPhoto: otherPhoto,
        contextType: contextType,
        contextId: contextId,
        contextTitle: contextTitle,
      );
});
