import 'package:cloud_firestore/cloud_firestore.dart';

/// Гуфтугӯ (banди 12): User↔Seller, User↔Worker, User↔Employer,
/// User↔Service provider, User↔Courier — ҳама "як корбар ба дигар
/// корбар" аст, бинобар ин ЯК модели ягона (`chats`) кофист, на
/// коллексияи алоҳида барои ҳар намуд (banди умумии "modular, вале
/// такрор накун"). Намуди гуфтугӯ (агар лозим шавад дар UI, масалан
/// "дар бораи маҳсулот") дар `contextType`/`contextId` сабт мешавад.
class ChatModel {
  final String id;
  final List<String> participantIds; // ҳамеша 2 нафар (1-ба-1, PHASE 8)
  final Map<String, String> participantNames;
  final Map<String, String?> participantPhotos;
  final String? lastMessageText;
  final String? lastMessageSenderId;
  final DateTime? lastMessageAt;
  final Map<String, int> unreadCounts; // uid -> шумораи хабари нахонда

  /// Контекст ихтиёрӣ: "ин чат дар бораи чист" (масалан product/job/service).
  final String? contextType; // 'product' | 'job' | 'service' | null
  final String? contextId;
  final String? contextTitle;

  final DateTime? createdAt;

  const ChatModel({
    required this.id,
    required this.participantIds,
    this.participantNames = const {},
    this.participantPhotos = const {},
    this.lastMessageText,
    this.lastMessageSenderId,
    this.lastMessageAt,
    this.unreadCounts = const {},
    this.contextType,
    this.contextId,
    this.contextTitle,
    this.createdAt,
  });

  String otherParticipantId(String myUid) =>
      participantIds.firstWhere((id) => id != myUid, orElse: () => '');

  String otherParticipantName(String myUid) =>
      participantNames[otherParticipantId(myUid)] ?? 'Корбар';

  String? otherParticipantPhoto(String myUid) =>
      participantPhotos[otherParticipantId(myUid)];

  int unreadCountFor(String myUid) => unreadCounts[myUid] ?? 0;

  factory ChatModel.fromMap(String id, Map<String, dynamic> map) {
    return ChatModel(
      id: id,
      participantIds:
          ((map['participantIds'] as List?) ?? const []).map((e) => e as String).toList(),
      participantNames: Map<String, String>.from(map['participantNames'] as Map? ?? {}),
      participantPhotos:
          Map<String, String?>.from(map['participantPhotos'] as Map? ?? {}),
      lastMessageText: map['lastMessageText'] as String?,
      lastMessageSenderId: map['lastMessageSenderId'] as String?,
      lastMessageAt: (map['lastMessageAt'] as Timestamp?)?.toDate(),
      unreadCounts: Map<String, int>.from(map['unreadCounts'] as Map? ?? {}),
      contextType: map['contextType'] as String?,
      contextId: map['contextId'] as String?,
      contextTitle: map['contextTitle'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap({bool isCreate = false}) {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantPhotos': participantPhotos,
      'lastMessageText': lastMessageText,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : FieldValue.serverTimestamp(),
      'unreadCounts': unreadCounts,
      'contextType': contextType,
      'contextId': contextId,
      'contextTitle': contextTitle,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

enum MessageType { text, image }

extension MessageTypeX on MessageType {
  String get value => name;
  static MessageType fromString(String value) =>
      MessageType.values.firstWhere((e) => e.value == value,
          orElse: () => MessageType.text);
}

class MessageModel {
  final String id;
  final String senderId;
  final MessageType type;
  final String? text;
  final String? imageUrl;
  final DateTime? timestamp;
  final bool isRead;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.type,
    this.text,
    this.imageUrl,
    this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> map) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] as String? ?? '',
      type: MessageTypeX.fromString(map['type'] as String? ?? 'text'),
      text: map['text'] as String?,
      imageUrl: map['imageUrl'] as String?,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'type': type.value,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}
