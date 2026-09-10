import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/service_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/social_link_chip.dart';
import '../../../models/service_provider_model.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../chat/presentation/chat_detail_screen.dart';
import '../../chat/presentation/chat_providers.dart';
import 'order_service_screen.dart';
import 'services_providers.dart';

class ProviderProfileScreen extends ConsumerWidget {
  final String uid;
  const ProviderProfileScreen({super.key, required this.uid});

  Future<void> _chat(BuildContext context, WidgetRef ref, ServiceProviderModel provider) async {
    final me = ref.read(authStateProvider).value;
    if (me == null) return;
    if (me.uid == provider.uid) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ин профили худи шумост.')));
      return;
    }

    final chatId = await ref.read(startChatProvider)(
      myUid: me.uid,
      myName: me.name,
      myPhoto: me.photoUrl,
      otherUid: provider.uid,
      otherName: provider.name,
      otherPhoto: provider.photoUrl,
      contextType: 'service',
      contextId: provider.uid,
      contextTitle: ServiceCategories.labelOf(provider.serviceCategory),
    );

    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatDetailScreen(chatId: chatId)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerAsync = ref.watch(providerDetailsProvider(uid));

    return Scaffold(
      appBar: AppBar(title: const Text('Хизматрасон')),
      body: providerAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(onRetry: () => ref.invalidate(providerDetailsProvider(uid))),
        data: (provider) {
          if (provider == null) {
            return const EmptyView(message: 'Профил ёфт нашуд.');
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.primaryLight,
                        backgroundImage: provider.photoUrl != null
                            ? CachedNetworkImageProvider(provider.photoUrl!)
                            : null,
                        child: provider.photoUrl == null
                            ? Icon(ServiceCategories.iconOf(provider.serviceCategory),
                                size: 44, color: AppColors.primary)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(provider.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    Center(
                      child: Text(ServiceCategories.labelOf(provider.serviceCategory),
                          style: const TextStyle(color: AppColors.primary, fontSize: 15)),
                    ),
                    if (provider.rating > 0)
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                            Text(' ${provider.rating.toStringAsFixed(1)} '
                                '(${provider.reviewsCount} шарҳ)'),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip(Icons.location_on_outlined, provider.city),
                        if (provider.price != null)
                          _chip(Icons.payments_outlined,
                              'аз ${provider.price!.toStringAsFixed(0)} с.'),
                      ],
                    ),
                    if ((provider.instagramUrl?.isNotEmpty ?? false) ||
                        (provider.whatsapp?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        children: [
                          if (provider.instagramUrl?.isNotEmpty ?? false)
                            SocialLinkChip.instagram(provider.instagramUrl!),
                          if (provider.whatsapp?.isNotEmpty ?? false)
                            SocialLinkChip.whatsapp(provider.whatsapp!),
                        ],
                      ),
                    ],
                    if (provider.description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Дар бораи хизмат', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(provider.description, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                          label: const Text('Чат'),
                          onPressed: () => _chat(context, ref, provider),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Фармоиш додан'),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderServiceScreen(provider: provider),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.textSecondaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondaryLight),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
