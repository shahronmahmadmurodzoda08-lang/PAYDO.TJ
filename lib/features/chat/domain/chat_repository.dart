import 'dart:io';

import '../../../models/chat_model.dart';

/// Domain layer барои Chat.
///
/// Қарори тарроҳӣ: chat ID байни ду корбар **детерминистӣ** сохта
/// мешавад (`{uid1}_{uid2}`, ба тартиби alphabetically sorted), на
/// auto-id. Ин имкон медиҳад "чат байни ин ду нафар ҳаст?" бе query
/// (танҳо як `get(chatId)`), ва пешгирии сохтани якчанд чат такрорӣ
/// байни ҳамон ду нафар. Агар дар оянда чат-и гурӳҳӣ (>2 нафар) лозим
/// шавад, он метавонад auto-id гирад — ин рамз бо ҳарду навъ мувофиқ аст.
abstract class ChatRepository {
  Stream<List<ChatModel>> watchMyChats(String uid);

  Stream<ChatModel?> watchChat(String chatId);

  /// Агар чат байни ин ду корбар аллакай мавҷуд бошад, ҳамонро
  /// бармегардонад; акс ҳол чати нав месозад (get-then-create).
  Future<String> getOrCreateChat({
    required String myUid,
    required String myName,
    String? myPhoto,
    required String otherUid,
    required String otherName,
    String? otherPhoto,
    String? contextType,
    String? contextId,
    String? contextTitle,
  });

  Stream<List<MessageModel>> watchMessages(String chatId);

  Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String text,
  });

  Future<void> sendImageMessage({
    required String chatId,
    required String senderId,
    required File imageFile,
  });

  Future<void> markAsRead({required String chatId, required String uid});
}
