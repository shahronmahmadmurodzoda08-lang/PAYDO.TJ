import 'package:flutter/material.dart';

/// Категорияҳои асосии Home Page (banди 7 спецификатсия).
/// PHASE 3: rout кардани ин категорияҳо ба феҷаи дахлдор ҳанӯз placeholder
/// аст (то он феҷа сохта шавад) — ниг. `HomeCategory.route`.
class HomeCategory {
  final String label;
  final IconData icon;
  final Color color;
  final String routeKey;

  const HomeCategory({
    required this.label,
    required this.icon,
    required this.color,
    required this.routeKey,
  });

  static const List<HomeCategory> all = [
    HomeCategory(
      label: 'Магазин',
      icon: Icons.storefront_rounded,
      color: Color(0xFF12B76A),
      routeKey: 'marketplace',
    ),
    HomeCategory(
      label: 'Кор',
      icon: Icons.work_outline_rounded,
      color: Color(0xFF2563EB),
      routeKey: 'jobs',
    ),
    HomeCategory(
      label: 'Хизмат',
      icon: Icons.build_outlined,
      color: Color(0xFFF79009),
      routeKey: 'services',
    ),
    HomeCategory(
      label: 'Дафтари ҳисоб',
      icon: Icons.receipt_long_outlined,
      color: Color(0xFF7C3AED),
      routeKey: 'accounting',
    ),
    HomeCategory(
      label: 'Доставка',
      icon: Icons.local_shipping_outlined,
      color: Color(0xFFF04438),
      routeKey: 'delivery',
    ),
    HomeCategory(
      label: 'Харита',
      icon: Icons.map_outlined,
      color: Color(0xFF0891B2),
      routeKey: 'maps',
    ),
    HomeCategory(
      label: 'Чат',
      icon: Icons.chat_bubble_outline_rounded,
      color: Color(0xFF25D366),
      routeKey: 'chat',
    ),
    HomeCategory(
      label: 'Эълонҳо',
      icon: Icons.campaign_outlined,
      color: Color(0xFFDB2777),
      routeKey: 'advertising',
    ),
  ];
}
