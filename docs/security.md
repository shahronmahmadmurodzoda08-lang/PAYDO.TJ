# Security — PAYDO.TJ

Мутобиқи banди 24 спецификация. Ин файл дар ҳар PHASE-и нав навсозӣ мешавад.

## Ҳолати ҳозира (PHASE 1–4)

- `firestore.rules`: коллексияи `users` — корбар танҳо документи худро сохта/навишта метавонад; хондан барои ҳар корбари ворид шуда кушода аст (барои профили ҷамъиятӣ дар оянда). Ҳама коллексияи дигар **default-deny** аст, то вақте ки феҷаи дахлдор онро кушояд.
- `firestore.rules` → `products`: хондан барои ҳама (marketplace бояд бе воридшавӣ ҳам намоён бошад — қарор), навиштан/тағйир/нест кардан танҳо барои `sellerId == auth.uid`.
- `firestore.rules` → `favorites`: хондан/навиштан/нест кардан танҳо барои `userId == auth.uid`-и худи документ.
- `storage.rules`: `profile_photos/{uid}.jpg` — корбар танҳо файли худро бор карда метавонад (маҳдудияти андоза < 5MB, танҳо навъи `image/*`); хондан барои ҳама кушода аст (сурат дар product/chat/review намоён мешавад).
- API secret/private key дар коди Flutter нест.
- Google Sign-In credential-ҳо танҳо ба воситаи Firebase SDK коркард мешаванд (client-side secret нест).

## Қоидаҳои умумӣ (барои ҳар PHASE-и оянда)

- Seller метавонад танҳо `products`-и худро идора кунад (`resource.data.sellerId == request.auth.uid`).
- Business метавонад танҳо `orders`-и марбут ба худро бинад/идора кунад.
- Customer метавонад танҳо `orders`-и худро бинад.
- Chat: танҳо иштирокчиёни он `chat` (array `participantIds`) метавонанд `messages`-ро хонанд/нависанд.
- `accounting`, `debts`, `inventory`, `sales`, `expenses` — танҳо соҳиби бизнес (`ownerId == request.auth.uid`).
- Коллексияҳои admin-only (масалан `reports`, feature flags) — санҷиши `accountTypes` дар документи `users/{uid}` бо `admin`.

## Тест кардани Security Rules

Тавсия: Firebase Emulator Suite (`firebase emulators:start`) + `@firebase/rules-unit-testing` барои unit-test-и rules пеш аз deploy (PHASE 20/21).
