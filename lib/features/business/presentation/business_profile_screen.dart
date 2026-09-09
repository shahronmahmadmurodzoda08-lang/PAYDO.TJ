import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/social_link_chip.dart';
import '../../../models/business_model.dart';
import '../../marketplace/presentation/product_card.dart';
import '../../marketplace/presentation/product_details_screen.dart';
import 'business_providers.dart';

/// Намоиши ҷамъиятии бизнес (banди 9 спецификатсия):
/// 🏪 name · ⭐ rating · 📍 location · 🚚 delivery · 📷 Instagram · 🟢 WhatsApp
/// [Products] [Reviews] [Contact] [Map]
class BusinessProfileScreen extends ConsumerWidget {
  final String businessId;
  const BusinessProfileScreen({super.key, required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessByIdProvider(businessId));

    return businessAsync.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorView(
          onRetry: () => ref.invalidate(businessByIdProvider(businessId)),
        ),
      ),
      data: (business) => _BusinessProfileBody(business: business),
    );
  }
}

class _BusinessProfileBody extends ConsumerWidget {
  final BusinessModel business;
  const _BusinessProfileBody({required this.business});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: AppColors.surfaceLight,
              foregroundColor: AppColors.textPrimaryLight,
              flexibleSpace: FlexibleSpaceBar(
                background: business.coverImageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: business.coverImageUrl!,
                        fit: BoxFit.cover,
                      )
                    : Container(color: AppColors.primaryLight),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: business.logoUrl != null
                              ? CachedNetworkImageProvider(business.logoUrl!)
                              : null,
                          child: business.logoUrl == null
                              ? const Icon(Icons.storefront_rounded,
                                  color: AppColors.primary)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      business.businessName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (business.isVerified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified_rounded,
                                        color: AppColors.info, size: 18),
                                  ],
                                ],
                              ),
                              if (business.rating > 0)
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        size: 16, color: AppColors.warning),
                                    Text(
                                      ' ${business.rating.toStringAsFixed(1)} '
                                      '(${business.reviewsCount})',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(icon: Icons.location_on_outlined, label: business.city),
                        if (business.deliveryAvailable)
                          const _Chip(
                              icon: Icons.local_shipping_outlined, label: 'Бо доставка'),
                        if (business.workingHours != null)
                          _Chip(
                              icon: Icons.access_time_outlined,
                              label: business.workingHours!),
                      ],
                    ),
                    if ((business.instagramUrl?.isNotEmpty ?? false) ||
                        (business.whatsapp?.isNotEmpty ?? false)) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: [
                          if (business.instagramUrl?.isNotEmpty ?? false)
                            SocialLinkChip.instagram(business.instagramUrl!),
                          if (business.whatsapp?.isNotEmpty ?? false)
                            SocialLinkChip.whatsapp(business.whatsapp!),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondaryLight,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Маҳсулот'),
                  Tab(text: 'Шарҳҳо'),
                  Tab(text: 'Тамос'),
                  Tab(text: 'Харита'),
                ],
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _ProductsTab(businessId: business.id),
              const EmptyView(
                message: 'Шарҳҳо дар PHASE 16 дастрас мешаванд.',
                icon: Icons.star_border_rounded,
              ),
              _ContactTab(business: business),
              const EmptyView(
                message: 'Харита дар PHASE 13 дастрас мешавад.',
                icon: Icons.map_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductsTab extends ConsumerWidget {
  final String businessId;
  const _ProductsTab({required this.businessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(businessProductsProvider(businessId));

    return productsAsync.when(
      loading: () => const LoadingView(),
      error: (e, _) => const ErrorView(),
      data: (products) {
        if (products.isEmpty) {
          return const EmptyView(
            message: 'Ин бизнес ҳанӯз маҳсулот илова накардааст.',
            icon: Icons.inventory_2_outlined,
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.62,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              product: product,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProductDetailsScreen(productId: product.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ContactTab extends StatelessWidget {
  final BusinessModel business;
  const _ContactTab({required this.business});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (business.description.isNotEmpty) ...[
          Text(business.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
        ],
        if (business.phone != null)
          ListTile(
            leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
            title: Text(business.phone!),
            contentPadding: EdgeInsets.zero,
          ),
        if (business.address != null)
          ListTile(
            leading: const Icon(Icons.location_on_outlined, color: AppColors.primary),
            title: Text(business.address!),
            contentPadding: EdgeInsets.zero,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
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
