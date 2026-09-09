import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/chat_model.dart';
import '../../auth/presentation/auth_providers.dart';
import 'chat_providers.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final _textCtrl = TextEditingController();
  bool _isSendingImage = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _markRead());
  }

  void _markRead() {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;
    ref.read(chatRepositoryProvider).markAsRead(chatId: widget.chatId, uid: uid);
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _textCtrl.text;
    if (text.trim().isEmpty) return;
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    _textCtrl.clear();
    await ref.read(chatRepositoryProvider).sendTextMessage(
          chatId: widget.chatId,
          senderId: uid,
          text: text,
        );
  }

  Future<void> _sendImage() async {
    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final xfile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (xfile == null) return;

    setState(() => _isSendingImage = true);
    try {
      await ref.read(chatRepositoryProvider).sendImageMessage(
            chatId: widget.chatId,
            senderId: uid,
            imageFile: File(xfile.path),
          );
    } finally {
      if (mounted) setState(() => _isSendingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(authStateProvider).value?.uid ?? '';
    final chatAsync = ref.watch(chatByIdProvider(widget.chatId));
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        title: chatAsync.maybeWhen(
          data: (chat) => Text(chat?.otherParticipantName(myUid) ?? 'Чат'),
          orElse: () => const Text('Чат'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => const ErrorView(),
              data: (messages) {
                if (messages.isEmpty) {
                  return const EmptyView(
                    message: 'Хабарҳо ҳанӯз нест. Аввалин хабарро фиристед!',
                    icon: Icons.chat_bubble_outline_rounded,
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == myUid;
                    return _MessageBubble(message: message, isMine: isMine);
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: _isSendingImage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.image_outlined, color: AppColors.primary),
                    onPressed: _isSendingImage ? null : _sendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Хабар нависед...',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                      ),
                      onSubmitted: (_) => _sendText(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                    onPressed: _sendText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  const _MessageBubble({required this.message, required this.isMine});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? AppColors.primary : AppColors.surfaceLight;
    final textColor = isMine ? Colors.white : AppColors.textPrimaryLight;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        padding: message.type == MessageType.image
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(16),
          border: isMine ? null : Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.type == MessageType.image && message.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: message.imageUrl!,
                  width: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Text(message.text ?? '', style: TextStyle(color: textColor)),
            if (message.timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat('HH:mm').format(message.timestamp!),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMine ? Colors.white70 : AppColors.textSecondaryLight,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
