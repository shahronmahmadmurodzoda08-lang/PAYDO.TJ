# Firebase — Танзим

## Хизматҳои фаъолшуда (free tier, banди 25)

- **Authentication** → Google provider фаъол
- **Cloud Firestore** → production mode, `firestore.rules` аз reпо deploy кунед
- **Cloud Storage** → PHASE 2-ро сар кардан пеш аз он фаъол кунед (сурати профил)
- **Cloud Messaging** → PHASE 15

## Квотаҳои free-tier (Spark plan) — бояд назорат шаванд

- Firestore: 50K хониш / 20K навиштан / 20K нест кардан дар як рӯз (тағйирёбанда, ҳамеша дар Firebase Console санҷед)
- Storage: 5GB нигоҳдорӣ, 1GB/рӯз даунлоуд
- Authentication: маҳдудияти амалӣ надорад барои Google Sign-In

Агар лоиҳа аз ин ҳудуд гузарад, бояд ба Blaze plan гузарем (banди 25 мегӯяд: "Do not introduce paid infrastructure unless necessary" — яъне танҳо вақте зарур шавад).

## Қадамҳои насб (такрор аз README, барои пуррагӣ дар ин ҷо ҳам)

1. `firebase login`
2. Лоиҳаи Firebase нав созед дар console.firebase.google.com (масалан `paydo-tj`)
3. `dart pub global activate flutterfire_cli`
4. Дар решаи лоиҳа: `flutterfire configure` — Android platform-ро интихоб кунед
5. Google Sign-In-ро дар Firebase Console → Authentication → Sign-in method фаъол кунед
6. SHA-1/SHA-256 fingerprint-ро илова кунед (ниг. README)
7. `firebase deploy --only firestore:rules`

## Мулоҳиза оид ба амният

Ҳеҷ калиди хусусӣ (API secret) дар коди Flutter гузошта нашудааст — `google-services.json` файли public-safe аст (мутобиқи амалияи расмии Firebase барои Android), вале худи он бояд дар `.gitignore` бошад агар шумо нахоҳед дар reпо-и public бошад (ниг. `.gitignore`).
