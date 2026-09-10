import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/service_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/service_provider_model.dart';

class ProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;
  final VoidCallback onTap;
  const ProviderCard({super.key, required this.provider, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: provider.photoUrl != null
                  ? CachedNetworkImageProvider(provider.photoUrl!)
                  : null,
              child: provider.photoUrl == null
                  ? Icon(ServiceCategories.iconOf(provider.serviceCategory),
                      color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(ServiceCategories.labelOf(provider.serviceCategory),
                      style: const TextStyle(fontSize: 13, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 2),
                      Text(provider.city,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondaryLight)),
                      if (provider.rating > 0) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                        Text(provider.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (provider.price != null)
              Text('${provider.price!.toStringAsFixed(0)} с.',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
