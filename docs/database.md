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

## Феҳристи коллексияҳои банақшагирифташуда (аз спецификация, банди 27)

Ин рӯйхат дар `lib/core/constants/firestore_paths.dart` аллакай ҳамчун constant мавҷуд аст (то ном дар кодбоза дучандиягӣ надошта бошад), вале худи схема дар марҳилаи феҷаи дахлдор муайян карда мешавад:

- `businesses` — PHASE 5
- `products`, `categories` — PHASE 4/6
- `orders`, `order_items` — PHASE 7
- `chats`, `messages` — PHASE 8
- `jobs`, `job_applications` — PHASE 9
- `services`, `service_orders` — PHASE 10
- `accounting`, `debts`, `inventory`, `sales`, `expenses` — PHASE 11
- `deliveries`, `couriers` — PHASE 12
- `reviews` — PHASE 16
- `notifications` — PHASE 15
- `favorites` — PHASE 4
- `reports`, `advertisements` — PHASE 18/19
- `cities` — PHASE 13 (ё static list, санҷиш дар PHASE 13)

## Қоидаи умумӣ

- ID-ҳо ҳамеша auto-id-и Firestore, ба ҷуз `users/{uid}` (= Firebase Auth uid).
- Ҳар коллексия, ки ба корбар/бизнес тааллуқ дорад, майдони `ownerId`/`sellerId`/`businessId`-ро барои Security Rules нигоҳ медорад (ниг. `docs/security.md`).
- Duplicate-ро то ҳадди имкон канорагирӣ мекунем; агар barои query денормализатсия лозим шавад (масалан номи seller дар product барои нашон додани list бе join), ин дар феҷаи дахлдор ҳуҷҷатгузорӣ мешавад.
