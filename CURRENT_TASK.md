# Güncel Görev

## Amaç

Doğadayım uygulamasının performans ve güvenlik sertleştirmesini tamamlayarak güvenli ve akıcı bir yayın ortamı hazırlamak.

## Tamamlanan

- `PROJECT_MEMORY.md` ve `ROADMAP.md` güncellendi.
- Ana ekran performans optimizasyonu: `_TodayRecommendation` ve yakındaki yerler hesaplamaları `build()` dışına çıkarıldı, memoization eklendi, kart `cacheWidth` küçültüldü (`e5769c1`).
- `test/design_system_widgets_test.dart` içindeki obsolete profil test beklentisi güncel UI ile senkronize edildi (`ecd3a53`).
- 10 başlıklı derinlemesine salt-okunur güvenlik denetimi tamamlandı (RLS matrisi, SECURITY DEFINER fonksiyonları, Edge Function, girdi doğrulama, secrets taraması, bağımlılıklar).
- Doğrulanmış 3 adet P0 güvenlik açığı için `202609130001_submission_security_hardening.sql` hazırlandı:
  - `main_category` allowlist CHECK kısıtı
  - `facilities` JSONB boole/allowlist CHECK kısıtı
  - `district`, `location_label`, `road_access`, `environment_tags`, `features` payload boyut kısıtları
- Preflight sorgusu production'da çalıştırıldı (0 ihlal teyit edildi).
- Migration production veritabanına uygulandı ve 7/7 constraint ile helper function doğrulaması başarıyla geçti.
- `supabase_migrations` şeması başlatılarak tüm 8 migration geçmişi production'da kaydedildi ve depoyla senkronize edildi (`552f7f4`).
- Tüm testler çalıştırıldı: 62/62 test başarılı (`All tests passed!`), `dart analyze lib` 0 hata/uyarı.

## Sonraki görev

- P1 güvenlik maddelerinin değerlendirilmesi:
  - `lib/src/features/detail.dart` içindeki `launchUrl` şema kontrolünün (`http`/`https`) sıkılaştırılması.
  - `app_user_roles` ve `moderation_audit_logs` tabloları için açık `REVOKE` migration'ı (Defense-in-depth).
- Performans iyileştirmelerinin ikinci aşaması (SharedPreferences / yerel önbellek okumaları).

## Model hatırlatma

- Basit görev: `gpt-5.6-luna`
- Normal geliştirme: `gpt-5.6-terra`
- Kritik güvenlik/veri/performance: `gpt-5.6-sol`

## Son doğrulama

- 2026-09-13: 62/62 test geçti (`flutter test --no-pub`). `dart analyze lib` 0 hata, 0 uyarı.
- Production veritabanı 7/7 kısıt doğrulandı.
