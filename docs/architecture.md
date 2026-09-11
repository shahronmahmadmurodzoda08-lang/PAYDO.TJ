# Architecture — PAYDO.TJ

## Услуб: Clean Architecture + Feature-based

Ҳар феча (`lib/features/<name>/`) се қабат дорад:

```
features/<name>/
  data/           # татбиқи воқеӣ: Firebase, HTTP, local cache
  domain/         # abstract repository-ҳо, модел/entity-и соф (Firebase-и он ҷо нест)
  presentation/   # виҷетҳо, screen-ҳо, Riverpod providers/controllers
```

**Сабаб:** domain layer аз ягон SDK вобаста нест → санҷиш (unit test) осон аст ва агар дар оянда backend иваз шавад (масалан аз Firebase ба backend-и худ), танҳо `data/` тағйир меёбад.

## State management: Riverpod

Қарор: **Riverpod** (на Bloc) барои тамоми лоиҳа интихоб шуд.

Сабаб: барои Super App бо даҳҳо феча, `Provider`/`AsyncNotifier`-ҳои Riverpod бо ҳам осонтар таркиб мешаванд (масалан profile provider метавонад ба auth provider вобаста бошад бе бойлерплейти иловагӣ), ва DevTools/testing-и он барои лоиҳаи калон мувофиқтар аст.

**Қоида:** аз ин лаҳза сар карда, ҲАМА феча бояд Riverpod истифода барад — на Provider-и оддӣ, на setState барои ҳолати муштарак, на Bloc.

## Routing: go_router

Як `GoRouter` марказӣ дар `lib/routing/app_router.dart`. Ҳар роҳи нав дар ҳамин файл (ё дар зерфайли ба он вобаста) илова карда мешавад — на ҳар ҷо бо `Navigator.push` бевосита.

`redirect` дар router ба `authStateProvider` (Riverpod stream аз Firebase Auth) гӯш медиҳад: агар корбар ворид нашуда бошад → `/login`; агар ворид шуда бошад → `/home`. Ин мантиқ дар PHASE 2+ васеъ мешавад (масалан: агар профил пурра набошад → `/complete-profile`).

**Bottom navigation (PHASE 3):** роҳи `/home` ба `RootShell` мебарад — виҷети дохилии он (на go_router-и алоҳида барои ҳар tab) бо `IndexedStack` + `BottomNavigationBar` кор мекунад. Қарор: барои 4 tab-и оддӣ (Home/Search/Map/Profile) `StatefulShellRoute`-и go_router зарурат надошт — `IndexedStack` соддатар аст ва ҳолати ҳар tab-ро нигоҳ медорад (масалан scroll position). Агар дар оянда deep-linking ба tab-и мушаххас лозим шавад (масалан push notification → Chat tab), метавон ба `StatefulShellRoute` гузашт бе тағйири феча-ҳо.

**Business Profile (PHASE 5):** ҳар корбар ҳадди аксар як бизнес дошта метавонад дар MVP — `businesses/{ownerId}` (documentId = uid). Ин соддатар аст барои "оё корбар бизнес дорад?" (як `get`, на query). Агар дар оянда чандин филиал лозим шавад, метавон ба auto-id гузашт бе вайрон кардани UI (зеро ҳама ҷо аз рӯи `businessId` кор мекунад).

**Cart and Orders (PHASE 7):** Cart device-local аст (SharedPreferences, JSON) — на Firestore, зеро он муваққатист ва то checkout шудан "ҳолати доимӣ" лозим надорад (арзонтар барои free-tier). Order-и `items` **embedded** дар худи документи `orders/{id}` нигоҳ дошта мешавад (на коллексияи алоҳидаи `order_items`, ки banди 27 номбар кардааст) — сабаб: андозаи order одатан хурд аст (якчанд item, на садҳо), ва хондани як order ба 1 Firestore read кам мешавад. Агар дар оянда query-и мустақил лозим шавад, гузариш ба коллексияи алоҳида имконпазир аст.

**Chat (PHASE 8):** `chatId` детерминистӣ (`{uid1}_{uid2}`, sorted) — ниг. эзоҳи муфассал дар `lib/features/chat/domain/chat_repository.dart`. Ин пешгирии дучандии чат байни ҳамон ду нафар мекунад ва "чат ҳаст ё не" бе query иҷро мешавад. Chat феҳа мустақил аст (на зерфеҳаи marketplace/business/jobs), зеро як гуфтугӯ метавонад аз феҳаҳои гуногун (product/business/job/service) сар шавад — бинобар ин майдонҳои ихтиёрии `contextType`/`contextId`/`contextTitle` истифода мешаванд, на 4 феҳаи алоҳидаи чат.

**Jobs (PHASE 9):** `worker_profiles/{uid}` ҳамон нақшаи `businesses/{ownerId}` (PHASE 5) — як профил барои ҳар корбар, documentId=uid. `job_applications` docId детерминистӣ (`{jobId}_{workerId}`) — ҳамон мантиқи `favorites`/`chats`: пешгирии сабти такрорӣ бе query иловагӣ. Employer↔Worker ва Employer↔Applicant chat аз феҳаи умумии Chat (PHASE 8) истифода мешавад — коди чат такрор нашуд.

**Services (PHASE 10):** ҳамон 3 нақшаи такроршавандаи "profile-per-user" (business/worker/service — documentId=uid) идома ёфт. `accountType` барои хизматрасон дар спецификатсия алоҳида зикр нашудааст (banди 6: танҳо user/business/worker/employer/courier/admin) — бинобар ин `AccountType.business` истифода мешавад (қарор сабтшуда дар коди `provider_profile_form_screen.dart`). `ServiceOrderModel` бо `OrderModel`-и marketplace якхела нест — pipeline-и соддатар (4 ҳолат, на 8), зеро хизматрасонӣ delivery/inventory надорад.

**Accounting (PHASE 11):** `sales` ва `inventory` (banди 27) қасдан ба сифати коллексияи алоҳида сохта НАШУДАНД — dashboard бевосита аз `orders` (PHASE 7) ва `products` (PHASE 6, бо майдони нави `purchasePrice`) ҳисоб мекунад, то ду манбаи ҳақиқат ва хатари desync пайдо нашавад. Ниг. тавзеҳи пурра дар `docs/database.md` ва эзоҳи код дар `lib/features/accounting/domain/accounting_repository.dart`. `debts`/`expenses` бошанд коллексияҳои воқеӣ ҳастанд, зеро маълумоти комилан нав (на дучандшуда аз феҳаи дигар).

**Delivery (PHASE 12):** `DeliveryStatus` (курьер-марказӣ) аз `OrderStatus` (тиҷорат-марказӣ, PHASE 7) қасдан ҷудо нигоҳ дошта шуд — ду concern-и гуногун. Композитсияи байни онҳо (масалан таъини courier → order.status='shipped'; delivered → order.status='completed' + courier → 'available') дар сатҳи `DeliveryActionController` (presentation layer, ниг. `lib/features/delivery/presentation/delivery_providers.dart`) анҷом дода мешавад — на дар дохили худи `DeliveryRepository`/`OrderRepository` (то ин ду repository ба ҳамдигар вобаста набошанд, coupling-и кам дар data layer).

## Firebase

- **Authentication:** Google Sign-In танҳо (PHASE 1). Дигар усулҳо (телефон, email/parol) дар спецификация зикр нашудаанд — илова намешаванд, то аз spec берун набароем.
- **Firestore:** сохтори коллексия дар `docs/database.md`.
- **Storage:** барои сурати профил (PHASE 2) ва сурати маҳсулот (PHASE 6+).
- **Messaging:** PHASE 15.

## Theme

Як `AppTheme` (`lib/core/theme/`) — light/dark, ранги брендӣ сабз (`AppColors.primary`). Ягон виҷет набояд ранг/style-ро ба таври hardcode нависад — ҳама аз `Theme.of(context)` ё `AppColors`/`AppTheme` мегиранд.

## Хатогиҳо (Error handling)

`lib/core/errors/failures.dart` — синфҳои `Failure` (Network, Auth, Server, Cache, Permission, Unknown). Repository-ҳо хатогиро ба ин намуд табдил медиҳанд, то UI паём бо забони Тоҷикӣ нишон диҳад, на technical exception-и хом.

## Чиро дар PHASE 0 қасдан НАСОХТЕМ

- Payment integration — banди 22/36 мегӯяд то backend омода нашавад, фаъол накунед. Ҳоло ягон коди пардохт нест.
- AI features — banди 36, барои марҳилаи оянда.
- l10n (ru/en) — ҳоло матнҳо мустақим дар `AppStrings` бо Тоҷикӣ; сохтори он тавре аст, ки ба package `intl`/ARB осон кӯчонида шавад вақте ки лозим шавад.
