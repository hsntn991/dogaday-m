# Doğadayım — Flutter

Android, iOS ve web için tek Flutter kod tabanına sahip doğa keşif uygulaması.

## Proje yapısı

```text
lib/
├── main.dart                         # Uygulama başlangıcı ve modül bağlantıları
├── services/
│   ├── device_location.dart          # Platform seçimi
│   ├── device_location_mobile.dart   # Android/iOS cihaz konumu
│   └── device_location_web.dart      # Tarayıcı konumu ve yaklaşık IP yedeği
└── src/
    ├── app/app.dart                  # Tema, splash, onboarding, giriş, navigation
    ├── core/app_core.dart            # Modeller, sabitler, hava/OSM servisleri
    ├── features/
    │   ├── home.dart
    │   ├── search_map.dart
    │   ├── favorites_profile.dart
    │   ├── detail.dart
    │   └── add_place.dart
    └── widgets/shared_widgets.dart   # Ortak kart ve görsel bileşenleri
```

## Çalıştırma

```bash
flutter pub get
flutter run -d chrome
```

Android cihaz veya emülatör için:

```bash
flutter run -d android
```

iOS için proje macOS üzerinde Xcode ile açılmalıdır.

## Platform ayarları

- Android konum izinleri `android/app/src/main/AndroidManifest.xml` içindedir.
- iOS konum açıklaması `ios/Runner/Info.plist` içindedir.
- Web konumu HTTPS veya `localhost` üzerinde çalışır.
- Harita ve yakın yer verileri OpenStreetMap kaynaklıdır.
- Hava durumu Open-Meteo üzerinden alınır.

## Servis bağlantıları ve üretim durumu

- **Kimlik Doğrulama:** Supabase Auth (E-posta/Şifre, TOTP MFA, Google/Apple OAuth yapılandırması ve derin linkleme `io.supabase.dogadagezi://login-callback` hazır).
- **Veri Depolama & Senkronizasyon:** Supabase veritabanı (RLS politikaları, RPC moderasyon fonksiyonları) + local-first SharedPreferences önbelleği.
- **Kullanıcı Verileri:** Favoriler (`UserFavoritesController`), yerel incelemeler (`UserReviewsController`) ve fotoğraf katkıları kalıcı olarak saklanır; hesap silme (`delete-account` Edge Function) ile tam tasfiye edilir.
- **Harita & Navigasyon:** OpenStreetMap/vektör harita, harici navigasyon (Google Maps, Apple Maps, Yandex Haritalar) doğrudan bağlıdır.
- **Fotoğraf ve Katkılar:** Yer başvuruları (`place-submissions`) ve topluluk fotoğrafları (`community-photos`) Supabase Storage ve moderasyon hattına bağlıdır.

