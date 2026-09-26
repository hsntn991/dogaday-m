# Doğadayım — Sürüm Yayınlama, Güvenlik ve Hata İzleme Checklist'i

Bu doküman, Doğadayım uygulamasının mağaza sürümleri (Google Play & App Store) ve web dağıtımı öncesinde uygulanması gereken operasyonel ve teknik adımları içerir.

---

## 1. Kod Kalitesi ve Statik Doğrulama (Preflight)

- [x] **Statik Kod Analizi:** `dart analyze lib/main.dart` çıktısında 0 hata ve 0 uyarı bulunmalıdır.
- [x] **Otomatik Test Paketi:** `flutter test --concurrency=1` tüm birim ve widget testlerini (114+ test) eksiksiz geçmelidir.
- [x] **Çoklu Ekran Taşma Denetimi:** 320px–430px telefon ekranları ve 768px–1024px tablet/web ekranlarında sıfır `RenderFlex` taşması doğrulanmalıdır.

---

## 2. Gizlilik, Hukuk ve Mağaza Uyumluluğu

- [x] **Gizlilik Politikası:** `PrivacyPolicyScreen` uygulama içinde yerel olarak ve web üzerinde (`https://dogadayim.github.io/dogadayim-privacy/`) güncel (7 Eylül 2026 versiyonu) olarak erişilebilir olmalıdır.
- [x] **Kullanım Koşulları:** `AppLegalLinks.termsOfServiceUrl` ve `openTermsOfService` bağlantısı aktif olmalıdır.
- [x] **Hesap ve Veri Silme:** Google Play gereksinimi olan web tabanlı hesap silme URL'i (`docs/delete-account.html`) ve uygulama içi hesap silme akışı çalışır durumda olmalıdır.
- [x] **Fotoğraf Telif ve Atıfları:** Yer detay ekranında üçüncü taraf fotoğraf kaynakları için lisans ve yazar atıfları gösterilmelidir.

---

## 3. Secret ve Release Yapılandırması

- [x] **Ortam Değişkenleri:** Supabase URL ve Anon Key, `String.fromEnvironment` ile tanımlıdır. Üretim derlemesinde aşağıdaki parametrelerle geçilebilir:
  ```bash
  flutter build appbundle --release \
    --dart-define=SUPABASE_URL=https://lluypcdjiuyskelbwxys.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=sb_publishable__...
  ```
- [x] **Keystore & İmzalama:** `android/key.properties` ve `upload-keystore.jks` dosyaları `.gitignore` ile korunur; asla depoya commit edilmez.
- [x] **Gradle Doğrulaması:** `android/app/build.gradle.kts` içinde `validateSigningRelease` görevi tanımlıdır; key.properties olmadan derleme sessizce debug key'e düşmez.

---

## 4. Kötüye Kullanım ve Veri Güvenliği (Anti-Abuse)

- [x] **Veritabanı RLS:** `places`, `user_favorites`, `app_user_roles` ve `moderation_audit_logs` tablolarında Row Level Security (RLS) devrededir. Anonim kullanıcılar yönetici tablolarına doğrudan erişemez.
- [x] **RPC Hız Sınırı (Rate Limiting):** Yer ve değerlendirme başvuruları `submit_place_proposal` güvenli RPC fonksiyonu üzerinden IP ve kullanıcı bazlı rate-limiting ile sınırlandırılır.
- [x] **XSS ve Şema Doğrulaması:** `isSafeExternalUrl` ile `http:` ve `https:` dışındaki tehlikeli URL şemaları engellenir.

---

## 5. Hata İzleme ve Operasyonel Yedekleme Planı

- [x] **Başlangıç Hata Yakalama:** `main()` içinde `_AppStartupErrorApp` ağ ve altyapı çökmesinde kullanıcıya beyaz ekran yerine anlaşılır Türkçe hata sunar.
- [x] **Kullanıcı Geri Bildirim Kanalı:** Profil ekranındaki `AppLegalLinks.openFeedback` ile kullanıcılar `dogadayim.destek@gmail.com` adresine doğrudan hata ve geri bildirim iletebilir.
- [x] **Veritabanı Yedekleme:** Supabase Dashboard üzerinden günlük otomatik yedekler (Point-in-time Recovery - PITR) aktiftir. Kritik güncellemeler öncesinde yerel SQL dump alınmalıdır.
