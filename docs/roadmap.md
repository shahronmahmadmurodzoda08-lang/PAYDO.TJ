# Roadmap — PAYDO.TJ

Мутобиқи specification (банди 3). Ҳар марҳила бояд пеш аз гузаштан ба навбатӣ бо
`flutter analyze` / `flutter test` тасдиқ шавад (дар маҳали худи шумо, бо Flutter насбшуда).

| # | PHASE | Ҳолат | Файлҳои асосӣ |
|---|---|---|---|
| 0 | Project architecture | ✅ Анҷом ёфт | `lib/core/`, `lib/routing/`, `pubspec.yaml` |
| 1 | Registration / Authentication | ✅ Анҷом ёфт | `lib/features/auth/`, `lib/models/user_model.dart`, `firestore.rules` |
| 2 | User Profile | ✅ Анҷом ёфт | `lib/features/profile/`, `storage.rules` |
| 3 | Home Page | ✅ Анҷом ёфт | `lib/features/home/presentation/root_shell.dart`, `home_tab_screen.dart` |
| 4 | Marketplace | ✅ Анҷом ёфт | `lib/features/marketplace/`, `lib/models/product_model.dart` |
| 5 | Business Profile | ✅ Анҷом ёфт | `lib/features/business/`, `lib/models/business_model.dart` |
| 6 | Product management | ✅ Анҷом ёфт | `lib/features/products/` |
| 7 | Cart and Orders | ✅ Анҷом ёфт | `lib/features/cart/`, `lib/features/orders/`, `lib/models/order_model.dart` |
| 8 | Chat | ✅ Анҷом ёфт | `lib/features/chat/`, `lib/models/chat_model.dart` |
| 9 | Jobs / Employment | ✅ Анҷом ёфт | `lib/features/jobs/`, `lib/models/vacancy_model.dart`, `worker_profile_model.dart`, `job_application_model.dart` |
| 10 | Services | ✅ Анҷом ёфт | `lib/features/services/`, `lib/models/service_provider_model.dart`, `service_order_model.dart` |
| 11 | Accounting / Дафтари ҳисоб | ✅ Анҷом ёфт | `lib/features/accounting/`, `lib/models/debt_model.dart`, `expense_model.dart` |
| 12 | Delivery | ⏳ | `lib/features/delivery/` |
| 13 | Map of Tajikistan | ⏳ | `lib/features/maps/` |
| 14 | Live Delivery Tracking | ⏳ | `lib/features/delivery/`, `lib/features/maps/` |
| 15 | Notifications | ⏳ | `lib/features/notifications/` |
| 16 | Ratings / Reviews | ⏳ | `lib/features/reviews/` |
| 17 | Search and filters | ⏳ | `lib/features/search/` |
| 18 | Advertising / Premium | ⏳ | `lib/features/advertising/` |
| 19 | Admin Panel | ⏳ | (феҷаи нав дар оянда) |
| 20 | Security | ⏳ | `firestore.rules` (пурра) |
| 21 | Testing | ⏳ | `test/` |
| 22 | Optimization | ⏳ | — |
| 23 | Release APK | ⏳ | — |
| 24 | Release AAB | ⏳ | — |
| 25 | Play Store preparation | ⏳ | — |

## Оянда (баъд аз 25 phase, banди 36)

AI assistant, AI product search, AI job matching, online payments, wallet, loyalty, coupons, QR codes, advanced analytics, subscription, multi-language, multi-currency, advanced delivery routing, push campaigns, promoted listings, video products, live commerce.

Architecture (feature-based + Riverpod + Clean Architecture) тавре сохта шудааст, ки ин функсияҳоро дар оянда бе аз нав навиштани лоиҳа илова кардан мумкин бошад.
