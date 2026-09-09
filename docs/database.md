# Database — Cloud Firestore

## Ҳолати ҳозира (PHASE 1)

### `users/{uid}`

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| uid | string | = document id |
| name | string | аз Google profile |
| email | string | аз Google profile |
| phone | string? | ихтиёрӣ, PHASE 2 |
| age | int? | ихтиёрӣ, PHASE 2 |
| nickname | string? | PHASE 2 |
| photoUrl | string? | аз Google, баъдтар аз Storage (PHASE 2) |
| instagramUrl | string? | PHASE 2 |
| whatsapp | string? | PHASE 2 |
| city | string? | PHASE 2 |
| accountTypes | array\<string\> | зермаҷмӯи: user, business, worker, employer, courier, admin |
| phoneVisible | bool | privacy toggle (PHASE 2) |
| ageVisible | bool | privacy toggle (PHASE 2) |
| createdAt | timestamp | server timestamp, дар create танҳо |
| updatedAt | timestamp | server timestamp, дар ҳар навсозӣ |

### `products/{productId}` (PHASE 4)

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| sellerId | string | = Firebase Auth uid-и фурӯшанда |
| businessId | string? | агар аз тарафи бизнес гузошта шуда бошад (PHASE 5) |
| name, description | string | |
| price, oldPrice | number | oldPrice барои нишон додани discount |
| discount | int? | фоиз |
| images | array\<string\> | URL-ҳои Storage (боркунӣ дар PHASE 6) |
| category | string | аз `ProductCategories.all` |
| quantity | int | 0 = "Номавҷуд" |
| city | string | аз `TjCities.all` |
| location | geopoint? | барои Map (PHASE 13) |
| deliveryAvailable | bool | |
| rating, reviewsCount | number/int | навсозӣ мешавад дар PHASE 16 |
| isHidden | bool | true = аз feed пинҳон (PHASE 6) |
| createdAt, updatedAt | timestamp | |

**Index-ҳои лозимӣ (PHASE 21 пеш аз release тасдиқ карда шавад):**
`isHidden + category + createdAt`, `isHidden + city + createdAt`, `isHidden + createdAt`.

### `favorites/{uid}_{itemId}` (PHASE 4)

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| userId | string | |
| itemId | string | масалан productId |
| itemType | string | ҳоло танҳо `'product'`; PHASE 9/10 метавонанд `'job'`/`'service'` илова кунанд |
| createdAt | timestamp | |

Қарори тарроҳӣ: docId = `{uid}_{itemId}` (на auto-id), то "toggle" (илова/нест кардан) бе query иловагӣ иҷро шавад — мустақим `favorites/{uid}_{productId}` дастрас аст.

## Феҳристи коллексияҳои банақшагирифташуда (аз спецификация, банди 27)

Ин рӯйхат дар `lib/core/constants/firestore_paths.dart` аллакай ҳамчун constant мавҷуд аст (то ном дар кодбоза дучандиягӣ надошта бошад), вале худи схема дар марҳилаи феҷаи дахлдор муайян карда мешавад:

- `businesses` — PHASE 5
- `categories` — placeholder (ҳоло `ProductCategories` static, PHASE 19 динамикӣ мешавад)
- `orders`, `order_items` — PHASE 7
- `chats`, `messages` — PHASE 8
- `jobs`, `job_applications` — PHASE 9
- `services`, `service_orders` — PHASE 10
- `accounting`, `debts`, `inventory`, `sales`, `expenses` — PHASE 11
- `deliveries`, `couriers` — PHASE 12
- `reviews` — PHASE 16
- `notifications` — PHASE 15
- `reports`, `advertisements` — PHASE 18/19
- `cities` — PHASE 13 (ё static list, санҷиш дар PHASE 13)

## Қоидаи умумӣ

- ID-ҳо ҳамеша auto-id-и Firestore, ба ҷуз `users/{uid}` (= Firebase Auth uid).
- Ҳар коллексия, ки ба корбар/бизнес тааллуқ дорад, майдони `ownerId`/`sellerId`/`businessId`-ро барои Security Rules нигоҳ медорад (ниг. `docs/security.md`).
- Duplicate-ро то ҳадди имкон канорагирӣ мекунем; агар barои query денормализатсия лозим шавад (масалан номи seller дар product барои нашон додани list бе join), ин дар феҷаи дахлдор ҳуҷҷатгузорӣ мешавад.
