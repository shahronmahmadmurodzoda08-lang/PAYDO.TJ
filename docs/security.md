# Security — PAYDO.TJ

Мутобиқи banди 24 спецификация. Ин файл дар ҳар PHASE-и нав навсозӣ мешавад.

## Ҳолати ҳозира (PHASE 1–11)

- `firestore.rules`: коллексияи `users` — корбар танҳо документи худро сохта/навишта метавонад; хондан барои ҳар корбари ворид шуда кушода аст (барои профили ҷамъиятӣ дар оянда). Ҳама коллексияи дигар **default-deny** аст, то вақте ки феҷаи дахлдор онро кушояд.
- `firestore.rules` → `products`: хондан барои ҳама (marketplace бояд бе воридшавӣ ҳам намоён бошад — қарор), навиштан/тағйир/нест кардан танҳо барои `sellerId == auth.uid`.
- `firestore.rules` → `favorites`: хондан/навиштан/нест кардан танҳо барои `userId == auth.uid`-и худи документ.
- `firestore.rules` → `businesses`: documentId = ownerId; хондан кушода (профили ҷамъиятӣ), навиштан танҳо барои `auth.uid == ownerId`; нест кардан бастааст (танҳо тавассути admin panel, PHASE 19).
- `firestore.rules` → `orders`: хондан барои харидор ё яке аз seller-ҳои дар `sellerIds`; сохтан танҳо аз номи худи харидор (`customerId == auth.uid`); тағйир (status) барои харидор ё seller-и дахлдор; нест кардан бастааст.
- `firestore.rules` → `chats`/`messages`: танҳо 2 иштирокчии дар `participantIds` метавонанд хонанд/нависанд; хабарҳо баъд аз фиристодан ивазнашаванда/нестнашавандаанд.
- `firestore.rules` → `jobs`: хондан кушода, навиштан/тағйир/нест кардан танҳо барои `employerId == auth.uid`.
- `firestore.rules` → `worker_profiles`: documentId = uid; хондан кушода (мисли businesses), навиштан танҳо барои соҳиб.
- `firestore.rules` → `job_applications`: хондан барои корҷӳ ё корфармои дахлдор; сохтан танҳо аз номи корҷӳ; тағйир (қабул/рад) танҳо барои корфармо.
- `firestore.rules` → `services`: documentId = uid; хондан кушода (мисли worker_profiles), навиштан танҳо барои соҳиб.
- `firestore.rules` → `service_orders`: хондан/тағйир барои харидор ё хизматрасони дахлдор; сохтан танҳо аз номи харидор.
- `firestore.rules` → `debts`/`expenses`: пурра хусусӣ — танҳо `ownerId == auth.uid`.
- `storage.rules`: `profile_photos/{uid}.jpg`, `business_images/{ownerId}/{logo,cover}.jpg`, `product_images/{sellerId}/{uuid}.jpg` — ҳар корбар танҳо файли худро бор/нест карда метавонад. `chat_images/{chatId}/{uuid}.jpg` — **МУВАҚҚАТӢ** танҳо authentication санҷида мешавад (ниг. эзоҳ дар `storage.rules`, мустаҳкамкунӣ дар PHASE 20). Хондан барои ҳама кушода аст (ба ҷуз chat).
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

## TODO пеш аз release (PHASE 20)

- [ ] `storage.rules` → `chat_images`: мустаҳкам кардани санҳиши "танҳо иштирокчии чат" (ҳозир танҳо `request.auth != null`).
- [ ] Санҳиши пурраи `firestore.rules` бо Firebase Emulator барои ҳама коллексия (users, products, favorites, businesses, orders, chats/messages).
