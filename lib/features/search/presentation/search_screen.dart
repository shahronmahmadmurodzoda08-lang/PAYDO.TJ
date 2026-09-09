import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// PLACEHOLDER: Ҷустуҷӯи пурра (бо filters) дар PHASE 17 сохта мешавад.
/// Ҳоло танҳо UI-и tab, то bottom navigation пурра кор кунад.
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Ҷустуҷӯ...',
            filled: true,
            fillColor: AppColors.backgroundLight,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Ҷустуҷӯи глобалӣ (маҳсулот, дӯконҳо, кор, хизмат) '
            'дар PHASE 17 дастрас мешавад.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}
