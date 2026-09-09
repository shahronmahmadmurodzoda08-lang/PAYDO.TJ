import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// PLACEHOLDER: Харитаи Тоҷикистон (MapLibre + OSM) дар PHASE 13
/// сохта мешавад. Ҳоло танҳо UI-и tab.
class MapPlaceholderScreen extends StatelessWidget {
  const MapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Харита')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined,
                  size: 48, color: AppColors.textSecondaryLight),
              SizedBox(height: 12),
              Text(
                'Харитаи Тоҷикистон (дӯконҳо, хизматрасонҳо, курьерҳо) '
                'дар PHASE 13 дастрас мешавад.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
