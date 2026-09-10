# Android native scaffold — ҳанӯз сохта нашудааст

Дар ин муҳити sandbox Flutter SDK насб нест, бинобар ин ман наметавонам
`flutter create .` -ро воқеан иҷро кунам, ки маъмулан файлҳои зерин ва
ғайраро худкор месозад:

- `android/build.gradle`, `android/app/build.gradle`
- `android/settings.gradle`, gradle wrapper
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/.../MainActivity.kt`
- `android/gradle.properties`

Навиштани ин файлҳо ба таври дастӣ (бе Flutter SDK барои санҷиш) хатари
он дорад, ки версияи Gradle/Kotlin/compileSdk кӯҳна ё номувофиқ бошад ва
шуморо ба хатогиҳои печида дучор кунад.

## Қадами дуруст дар маҳали худ

```bash
cd paydo_tj
flutter create . --platforms=android --org tj.paydo
```

Ин фармон `android/`-ро дар канори `lib/` (ки аллакай тайёр аст) месозад,
бидуни он ки ба `lib/`, `pubspec.yaml` ё файлҳои дигари мо даст расонад.

Пас аз ин:

1. `flutterfire configure` — `google-services.json`-ро худкор ҷойгир мекунад ва плагини Google Services-ро ба `android/app/build.gradle` илова мекунад.
2. `minSdkVersion`-ро дар `android/app/build.gradle` ба ҳадди аққал **21** гузоред (талаботи `google_sign_in`/Firebase).
3. `android/app/src/main/AndroidManifest.xml` — иҷозати INTERNET аллакай бо флагманд аст (Flutter template пешфарз медиҳад), барои Location (PHASE 14) баъдтар `ACCESS_FINE_LOCATION` илова мешавад.

Ин қадам дар PHASE 0-и ҳозира ба сифати "TODO пеш аз якум flutter run" сабт мешавад — дар `docs/roadmap.md` ва README қайд шудааст.
