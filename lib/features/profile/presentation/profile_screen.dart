import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/social_link_chip.dart';
import '../../../models/user_model.dart';
import '../../auth/presentation/auth_providers.dart';
import 'profile_providers.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final currentUid = authState.value?.uid;

    if (currentUid == null) {
      return const Scaffold(body: LoadingView());
    }

    final userAsync = ref.watch(watchUserProvider(currentUid));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navProfile),
        actions: [
          userAsync.maybeWhen(
            data: (user) => IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(user: user),
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: userAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: AppStrings.somethingWentWrong,
          onRetry: () => ref.invalidate(watchUserProvider(currentUid)),
        ),
        data: (user) => _ProfileBody(user: user),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  final UserModel user;
  const _ProfileBody({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primaryLight,
            backgroundImage: user.photoUrl != null
                ? CachedNetworkImageProvider(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? const Icon(Icons.person, size: 48, color: AppColors.primary)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (user.nickname != null && user.nickname!.isNotEmpty)
            Text(
              '@${user.nickname}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondaryLight),
            ),
          const SizedBox(height: 4),
          Text(user.email,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondaryLight)),
          const SizedBox(height: 16),
          if ((user.instagramUrl?.isNotEmpty ?? false) ||
              (user.whatsapp?.isNotEmpty ?? false))
            Wrap(
              spacing: 10,
              children: [
                if (user.instagramUrl?.isNotEmpty ?? false)
                  SocialLinkChip.instagram(user.instagramUrl!),
                if (user.whatsapp?.isNotEmpty ?? false)
                  SocialLinkChip.whatsapp(user.whatsapp!),
              ],
            ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.location_city_outlined,
                    label: 'Шаҳр',
                    value: user.city ?? '—',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Телефон',
                    value: user.phoneVisible
                        ? (user.phone ?? '—')
                        : 'Пинҳон',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.cake_outlined,
                    label: 'Синну сол',
                    value: user.ageVisible
                        ? (user.age?.toString() ?? '—')
                        : 'Пинҳон',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  ref.read(signInControllerProvider.notifier).signOut(),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              label: const Text(
                AppStrings.signOut,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondaryLight),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
