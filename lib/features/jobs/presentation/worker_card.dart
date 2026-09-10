import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/worker_profile_model.dart';

class WorkerCard extends StatelessWidget {
  final WorkerProfileModel worker;
  final VoidCallback onTap;
  const WorkerCard({super.key, required this.worker, required this.onTap});

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
              backgroundImage:
                  worker.photoUrl != null ? CachedNetworkImageProvider(worker.photoUrl!) : null,
              child: worker.photoUrl == null
                  ? const Icon(Icons.person, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(worker.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(worker.profession,
                      style: const TextStyle(fontSize: 13, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textSecondaryLight),
                      const SizedBox(width: 2),
                      Text(worker.city,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondaryLight)),
                      if (worker.age != null) ...[
                        const SizedBox(width: 8),
                        Text('${worker.age} сола',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondaryLight)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
