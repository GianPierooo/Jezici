# Jezici · Build nativo (preparación tiendas)

Hecho en el repo:
- **applicationId / bundle**: `com.shadowgames.jezici` (Android) · `CFBundleDisplayName: Jezici` (iOS).
- **Nombre visible**: `android:label="Jezici"`.
- **Versión**: `pubspec.yaml` → `version: 1.0.0+1` (versionName 1.0.0 / versionCode 1).
- **Íconos**: generados con `flutter_launcher_icons` desde `app/brand/icon-1024.png`
  (adaptive Android + AppIcon iOS). Config en `pubspec.yaml`.
- **Permisos mínimos**:
  - Android: `INTERNET` (API Supabase + audio), `RECORD_AUDIO` (pronunciación).
  - iOS: `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`.

## Android — generar AAB/APK
Requiere Android SDK + JDK 17 (no instalados en el entorno de CI/dev actual).
```
cd app
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
# o APK:  flutter build apk --release --dart-define=...
```
Para publicar en Play:
1. Crear un **keystore** y configurar `android/key.properties` + firma en
   `android/app/build.gradle.kts` (signingConfigs release). (Pendiente: necesito
   que generes el keystore o me des uno; no debe ir al repo.)
2. Subir el `.aab` a Play Console, completar ficha, política de privacidad
   (usar la pantalla de Privacidad / hospedar la URL), y el cuestionario de
   permisos (micrófono = pronunciación).

## iOS — preparar (sin firmar)
Requiere macOS + Xcode (no disponible aquí).
```
cd app && flutter build ios --release --no-codesign --dart-define=...
```
Luego en Xcode: team de firma, capacidades (micrófono ya declarado), y subir a
App Store Connect.

## Lo que necesito de ti
- **Keystore de Android** (o permiso para generarlo) para firmar el release.
- **Cuenta de Apple Developer** + Mac para el build/firma iOS.
- Confirmar `versionName`/`versionCode` de la primera release.
