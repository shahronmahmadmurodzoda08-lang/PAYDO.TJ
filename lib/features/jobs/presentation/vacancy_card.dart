import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/vacancy_model.dart';

class VacancyCard extends StatelessWidget {
  final VacancyModel vacancy;
  final VoidCallback onTap;
  const VacancyCard({super.key, required this.vacancy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vacancy.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            Text(vacancy.employerName,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _tag(Icons.payments_outlined, vacancy.salaryRangeLabel),
                _tag(Icons.location_on_outlined, vacancy.city),
                if (vacancy.schedule != null) _tag(Icons.schedule_outlined, vacancy.schedule!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryDark),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.primaryDark)),
        ],
      ),
    );
  }
}
