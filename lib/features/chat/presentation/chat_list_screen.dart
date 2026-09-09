import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../models/chat_model.dart';
import '../../auth/presentation/auth_providers.dart';
import 'chat_detail_screen.dart';
import 'chat_providers.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(myChatsProvider);
    final myUid = ref.watch(authStateProvider).value?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Чат')),
      body: chatsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(myChatsProvider)),
        data: (chats) {
          if (chats.isEmpty) {
            return const EmptyView(
              message: 'Шумо ҳанӯз гуфтугӳ надоред.\n'
                  'Аз саҳифаи маҳсулот ё бизнес "Тамос бо фурӯшанда"-ро пахш кунед.',
              icon: Icons.chat_bubble_outline_rounded,
            );
          }
          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 76),
            itemBuilder: (context, index) {
              final chat = chats[index];
              final unread = chat.unreadCountFor(myUid);
              final otherName = chat.otherParticipantName(myUid);
              final otherPhoto = chat.otherParticipantPhoto(myUid);

              return ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryLight,
                  backgroundImage:
                      otherPhoto != null ? CachedNetworkImageProvider(otherPhoto) : null,
                  child: otherPhoto == null
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
                ),
                title: Text(
                  otherName,
                  style: TextStyle(
                    fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  chat.contextTitle != null
                      ? '${chat.contextTitle}: ${chat.lastMessageText ?? ''}'
                      : (chat.lastMessageText ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: unread > 0
                        ? AppColors.textPrimaryLight
                        : AppColors.textSecondaryLight,
                    fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chat.lastMessageAt != null)
                      Text(
                        DateFormat('HH:mm').format(chat.lastMessageAt!),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondaryLight),
                      ),
                    if (unread > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Text(
                          '$unread',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatDetailScreen(chatId: chat.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
