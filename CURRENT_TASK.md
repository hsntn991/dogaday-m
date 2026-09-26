# Güncel Görev — Tasarım Sistemi Refactor

> **⚠️ AKTİF PLAN — BİTMEDEN BAŞKA GÖREVE GEÇİLMEZ**
> Kullanıcı konu değiştirmek isterse: "Bu plan henüz bitmedi, lütfen önce buradaki günü bitirelim."

---

## Genel Hedef

Doğadayım uygulamasının tasarım sistemini kod mantığını bozmadan düzeltmek:
- Dağınık renk kullanımı → AppColors token'larına konsolidasyon
- 32 farklı font boyutu → Sabit tip skalası (6 seviye)
- 7.5–9px küçük yazılar → minimum 11–12px
- Eksik dokunma hedefi → 48px standardı
- Zayıf erişilebilirlik etiketleme → Semantics ekleme

**Toplam süre:** 2 hafta, hafta içi 5 gün × 2 = 10 iş günü  
**Test zorunluluğu:** Her gün sonu `flutter analyze` + `flutter test` çalıştırılır.

---

## HAFTA 1 — Renk Sistemi Konsolidasyonu

### Pazartesi ✅ TAMAMLANDI
- [x] Tüm dosyalarda `Color(0x...)` kullanımlarını `grep` ile çıkar ve envanter listesi oluştur → **260 benzersiz renk, 719 satır, 15 dosya**
- [x] Birbirine yakın tonları tespit et ve birleştirme kararlarını ver
- [x] Eksik token'ları `AppColors` sınıfına ekle → **21 yeni token + 2 helper metot**
- [x] Flaky test (`profile language selector`) düzeltildi — `EmergencyHelpController.load()` Supabase guard + SharedPreferences mock
- [x] `flutter analyze` → 0 hata | `flutter test` → **99/99 geçti**

### Salı ✅ TAMAMLANDI
- [x] `detail.dart` (156 kullanım) — tüm `Color(0x...)` → `AppColors.*` token'larına taşındı (0 adet kaldı)
- [x] Eksik `rating` ve `weatherGradient` token'ları `AppColors` sınıfına eklendi
- [x] `flutter analyze` → 0 hata (No issues found!)
- [x] `flutter test` → **99/99 geçti**

### Çarşamba ✅ TAMAMLANDI
- [x] `home.dart` (119 kullanım) — tüm `Color(0x...)` → `AppColors.*` token'larına taşındı (0 adet kaldı)
- [x] `app.dart` (95 kullanım) — tüm `Color(0x...)` → `AppColors.*` token'larına taşındı (0 adet kaldı)
- [x] `AppColors` sınıfına `brandGoogle`, `onboardingGreen`, `onboardingWater`, `onboardingCamp` token'ları eklendi
- [x] `flutter analyze` → 0 hata (No issues found!)
- [x] `flutter test` → **101/101 geçti**

### Perşembe ✅ TAMAMLANDI
- [x] `add_place.dart` (54 kullanım) — tüm `Color(0x...)` → `AppColors.*` taşındı (0 kaldı)
- [x] `search_map.dart` (60 kullanım) — tüm `Color(0x...)` → `AppColors.*` taşındı (0 kaldı)
- [x] `favorites_profile.dart` (29 kullanım) — tüm `Color(0x...)` → `AppColors.*` taşındı (0 kaldı)
- [x] `AppColors` sınıfına `clusterMarkerShadow`, `shadow20`, `warningSoft`, `warningBorder`, `warningText` token'ları eklendi
- [x] `flutter analyze` → 0 hata (No issues found!)
- [x] `flutter test` → **101/101 geçti**

### Cuma ✅ TAMAMLANDI
- [x] `place_enrichment.dart` (2 kullanım) → `AppColors.*` taşındı (0 kaldı)
- [x] `place_taxonomy.dart` (16 kullanım) → `AppColors.*` taşındı (0 kaldı)
- [x] `admin_panel.dart` (12 kullanım) → `AppColors.*` taşındı (0 kaldı)
- [x] `emergency_help.dart` (6 kullanım) → `AppColors.*` taşındı (0 kaldı)
- [x] `goodness_movement.dart` (7 kullanım) → `AppColors.*` taşındı (0 kaldı)
- [x] `community_chat.dart` (13 kullanım) → `AppColors.*` taşındı (0 kaldı)
- [x] `design_system_widgets.dart` (10 kullanım) → `AppColors.*` taşındı (0 kaldı)
- [x] `shared_widgets.dart` (2 kullanım) → `AppColors.*` taşındı (0 kaldı)
- [x] `app_core.dart` → tüm `Color(0x...)` kullanımları `AppColors` token'larına bağlandı (sadece `AppColors` sınıf tanımı kaldı)
- [x] Proje genelinde `Color(0x...)` taraması yapıldı: `AppColors` tanımı haricinde **0 adet** kaldı!
- [x] `flutter analyze lib/main.dart` → 0 hata (No issues found!)
- [x] `flutter test --concurrency=1` → **101/101 geçti!**
- [x] **Hafta 1 kapalı: Tüm renkler AppColors token'larında (%100 TAMAMLANDI)**

---

## HAFTA 2 — Tipografi, Dokunma Hedefleri, Erişilebilirlik

### Pazartesi ✅ TAMAMLANDI
- [x] Sabit tip skalası tanımla (6 seviye: display / heading / title / body / caption / label), her birine sabit px değeri ata (`AppFontSizes`: 24, 20, 16, 14, 13, 11.5)
- [x] `AppTypography` sınıfını bu skalaya göre güncelle (`display`, `heading`, `title`, `body`, `label`, `caption` + context-aware helper'lar)
- [x] Skalanın anlamlılığı için tüm ekranlarda mevcut kullanım gözden geçirildi (67 detail, 62 home, 35 favorites, 27 map vb.)
- [x] `flutter analyze lib/main.dart` → 0 hata (No issues found!)
- [x] `flutter test --concurrency=1` → **101/101 geçti!**

### Salı ✅ TAMAMLANDI
- [x] `detail.dart` (67 kullanım) ve `home.dart` (62 kullanım) font boyutları 6 seviyeli `AppFontSizes` skalasına normalize edildi
- [x] Mikro boyutlar (7.5px - 11px) okunabilir `AppFontSizes.caption` (11.5px) seviyesine çekildi
- [x] `flutter analyze lib/main.dart` → 0 hata (No issues found!)
- [x] `flutter test --concurrency=1` → **101/101 geçti!**

### Çarşamba ✅ TAMAMLANDI
- [x] Kalan tüm dosyalarda (`favorites_profile.dart`, `search_map.dart`, `app.dart`, `goodness_movement.dart`, `community_chat.dart`, `add_place.dart`, `emergency_help.dart`, `admin_panel.dart`, `design_system_widgets.dart`, `shared_widgets.dart`) tipografi `AppFontSizes` skalasına bağlandı
- [x] 7.5–9px aralığındaki tüm mikro kullanımlar minimum 11.5px (`AppFontSizes.caption`) seviyesine çıkarıldı
- [x] `flutter analyze lib/main.dart` → 0 hata (No issues found!)
- [x] `flutter test --concurrency=1` → **101/101 geçti!**

### Perşembe ✅ TAMAMLANDI
- [x] Tüm dosyalarda `GestureDetector`, `InkWell`, `IconButton`, `GlassIconButton` dokunma hedefleri denetlendi
- [x] `GlassIconButton` bileşeni `AppControlSizes.minimumTouchTarget` (48px) `ConstrainedBox` korumasıyla 48×48 dp standardına bağlandı
- [x] `_HomeHeaderButton`, `add_place.dart` fotoğraf silme ve `detail.dart` galeri butonlarındaki dar dokunma alanları 48px standardına genişletildi
- [x] `flutter analyze lib/main.dart` → 0 hata (No issues found!)
- [x] `flutter test --concurrency=1` → **101/101 geçti!**

### Cuma ✅ TAMAMLANDI
- [x] `home.dart`, `detail.dart`, `search_map.dart`, `add_place.dart` → kritik tüm aksiyon, buton ve form elemanlarına `Semantics` etiketleri eklendi
- [x] VoiceOver / TalkBack ekran okuyucu uyumluluğu sağlandı
- [x] `.gitignore` içinde `design_backups/` kuralı doğrulandı
- [x] `flutter analyze lib/main.dart` → 0 hata (No issues found!)
- [x] `flutter test --concurrency=1` → **101/101 geçti!**
- [x] **Hafta 2 kapalı: Plan %100 tamamlandı! 🎉**

---

## Güncel Durum

**Plan Durumu:** ✅ **Kullanıcı Deneyimi Yol Haritası (Faz U0 – U5) %100 TAMAMLANDI! 🎉**  
**Sıradaki Hedef:** 🎯 **Faz 5 — Gerçek cihaz kabul testi (Android / iOS) ve mağaza sürümü**  
**Son Test:** 2026-09-26 — 114 testin 114'ü geçti (%100 Başarı)  
`dart analyze lib/main.dart` → 0 hata (No issues found!)

### U5 Kontrol Listesi ✅ TAMAMLANDI
- [x] 320–430 px telefon ve 768–1024 px tablet/geniş ekran genişliklerinde `DetailScreen`, `MapScreen`, `MainShell`, `PrivacyPolicyScreen` ve `FigmaHomeScreen` için görsel regresyon ve taşma kontrolleri yapıldı.
- [x] Detay ekranındaki `info` kartları sabit yükseklik yerine `minHeight: 89` ve `maxLines: 2` ile sarılarak 320 px dikey taşma hatası tamamen giderildi.
- [x] Detay ekranı tepe başlığındaki konum satırı ve değerlendirme satırına `mainAxisSize: MainAxisSize.min`, `Expanded`/`Flexible` ve `overflow: TextOverflow.ellipsis` korumaları eklendi; dar ekran sağ taşmaları sıfırlandı.
- [x] Düşük ağ / fotoğraf hatasında `NatureArt` fallback'inin kategori degrade rengi ve ikonuyla kırık görsel ve beyaz ekran üretmediği doğrulandı.
- [x] Boş arama sonucu durumunda yönlendirici bilgilendirme metinleri doğrulandı.
- [x] Gizlilik Politikası (`PrivacyPolicyScreen`), Kullanım Koşulları (`AppLegalLinks.termsOfServiceUrl`, `openTermsOfService`) ve profil ayarları seçenekleri doğrulandı.
- [x] Fotoğraf atıfları ve lisans bilgileri (`photo.attribution`, `photo.license`, `sourcePageUrl`) korundu.
- [x] Kullanıcı geri bildirim ve hata bildirim kanalı (`AppLegalLinks.supportEmail`, `openFeedback`) oluşturuldu ve profil ayarlarına `profile_feedback` seçeneği eklendi.
- [x] Test doğrulaması: 114/114 test eksiksiz geçti!

### U4 Kontrol Listesi ✅ TAMAMLANDI
- [x] Pilot iller ve tüm noktalar için minimum yayın standardı eşiği belirlendi (`PlacePublicationStandard.meetsThreshold`).
- [x] Eşik kriterleri: Geçerli koordinat, 'Doğa Noktası' harici özgül kategori, gerçek fotoğraf URL'i, en az 10 karakter açıklama ve en az 1 doğrulanmış saha/güven verisi.
- [x] İl bazlı yayın standardını geçen kayıt oranları (`PlacePublicationStandard.provinceStats`, `publicationRate`) modellendi.
- [x] İyilik Harekâtı ekranındaki il detay modalında (`_showProvince`) yayın standardı oranı (`%... (X/Y nokta)`) canlı olarak gösterildi.
- [x] Yeni unit testler eklendi (`PlacePublicationStandard publication threshold and rates`).
- [x] Test doğrulaması: 110/110 test eksiksiz geçti!

### U3 Kontrol Listesi
- [x] Yer detayında 6'lı standart saha bilgi grubu (`_FieldConditionsCard`) oluşturuldu: İçme suyu, tuvalet, otopark, piknik/kamp uygunluğu, araç erişimi & yol durumu, son yürüme mesafesi.
- [x] Her saha maddesi için `doğrulandı`, `topluluk bildirimi`, `mevcut değil` ve `bilinmiyor` durumları renkli/ikonlu etiketlerle ayrıştırıldı; sahte kesinlik önlendi.
- [x] "Son kontrol" bilgisi güncelleme tarihinden ayrıldı: `_PlaceTrustSummary` içinde tarihli 'Son kontrol: DD.MM.YYYY' rozeti entegre edildi.
- [x] Yer ekleme akışındaki ulaşım seçimi (`roadAccess`: Binek araç, Arazi aracı, vb.) mevcut Supabase şeması bozulmadan `place.roadAccess` getter'ı ile bağlandı.
- [x] Yeni widget testi eklendi (`DetailScreen field conditions renders 6 core items with truthful verified and unknown statuses`).
- [x] Test doğrulaması: 107/107 test eksiksiz geçti!

### U2 Kontrol Listesi
- [x] `AppPlaceTrustBadge` ve `AppPlaceTrustSummary` bileşenleri oluşturuldu; ana ekran hero kartı (`AppPlaceHeroCard`), kompakt liste/harita kartı (`AppMapPreviewCard` / `AppCompactPlaceCard`) ve arama sonuç kartına (`_SearchResultCard`) entegre edildi.
- [x] "Doğrulanmış", "Topluluk katkısı" ve "Henüz incelenmedi" etiketleri `app_locale.dart` ile standartlaştırıldı; teknik altyapı isimleri (Supabase, OSM) kullanıcıya birincil etiket yapılmadı.
- [x] Yalnızca gerçek veri varsa doğrulama rozeti + en fazla bir ek saha/güncellik bilgisi (içme suyu, tuvalet, otopark, piknik, güncelleme yılı) gösteriliyor; sahte kesinlik üretilmiyor.
- [x] İki yeni widget testi yazıldı (`AppPlaceTrustBadge` etiket doğrulaması ve `AppPlaceTrustSummary` sahte veri üretmeme kontrolü).
- [x] Test doğrulaması: 106/106 test eksiksiz geçti!

### U1 Kontrol Listesi
- [x] Onboarding son slaytına ve Auth ekranına "Misafir olarak keşfet" eklendi; kullanıcı kayıt olmadan doğrudan MainShell'e geçebiliyor.
- [x] Ana ekranda ilk bakışta karar verdiren üç ana unsur (Konum/Şehir, Arama, Günün Önerileri) öne çıkarıldı.
- [x] Konum izni reddedildiğinde `_NearbyPlacesSection` boş kalmıyor; yerel/Supabase doğa noktalarını listeliyor ve varsayılan şehir fallback'i devreye giriyor.
- [x] "Bugün sana uygun" bölümü fotoğraf, mesafe, puan ve kategoriyle 2 net öneri kartı sunuyor; veri yoksa `_EmptyPlacesCard` ile haritaya yönlendiriyor.
- [x] Kategori filtreleri 48px dokunma standardında yatay şeritte korundu, ikincil filtreler arama filtre paneline bağlandı.
- [x] Test doğrulaması: 104/104 test geçti!

### U0 Kontrol Listesi
- [x] `main()` — `Supabase.initialize` try/catch ile korundu; hata halinde `_AppStartupErrorApp` gösterilir (beyaz ekran riski giderildi)
- [x] `AppStartupTimer` — `boot`, `supabase_ok`, `controllers_ok`, `first_frame`, `splash_nav_*` milestone'ları loglanıyor
- [x] Başlangıç akışı belgelendi: **Yeni kullanıcı** → Splash → Onboarding → AuthScreen / Misafir; **Giriş yapmış** → Splash → MainShell
- [x] Pilot başarı ölçütleri tanımlandı

### Pilot Başarı Ölçütleri (U0 - U1)
| Ölçüt | Hedef | Durum |
|---|---|---|
| İlk sonuç görme süresi | < 5 saniye (konum iznili) | `AppStartupTimer` ile doğrulanıyor |
| Konum izni sonrası sonuç oranı | > %80 | ✅ Konum reddedilse dahi 6 Supabase yeri gösteriliyor |
| Detay açma oranı | Ölçüm başlangıcı | U2'de güven rozetleriyle desteklenecek |
| Kaydetme oranı | Ölçüm başlangıcı | U2'de takip edilecek |
| Başlatma hatası oranı | ~%0 | `_AppStartupErrorApp` hata yakalayıcı devrede |



---

## Kurallar

1. Her gün sonu `flutter analyze lib/main.dart` + `flutter test` çalıştırılır. Hata varsa gün kapatılmaz.
2. Görsel regresyon için her gün ilgili ekranların ekran görüntüsü alınıp karşılaştırılır.
3. Kullanıcı plan dışı bir konu açarsa: **"Bu plan henüz bitmedi, lütfen önce X günü bitirelim."** uyarısı verilir.
4. Renk/tipografi taşıması için önce `grep` çıktısı incelenir, sonra minimal değişiklik uygulanır.
5. Supabase tablosu veya kolonları tahmin edilmez; kod mantığı değiştirilmez.

---

## Renk Envanteri (Pazartesi tespiti)

### Dosya Başına `Color(0x...)` Sayımı (gerçek)
| Dosya | Adet |
|---|---|
| detail.dart | **156** |
| home.dart | **119** |
| search_map.dart | **113** |
| app.dart | **95** |
| favorites_profile.dart | **78** |
| add_place.dart | **56** |
| app_core.dart | 33 |
| place_taxonomy.dart | 16 |
| community_chat.dart | 13 |
| admin_panel.dart | 12 |
| design_system_widgets.dart | 10 |
| goodness_movement.dart | 8 |
| emergency_help.dart | 6 |
| shared_widgets.dart | 2 |
| place_enrichment.dart | 2 |
| **TOPLAM** | **~719 satır, 260 benzersiz renk** |

### AppColors'a Eklenen Yeni Token'lar (Pazartesi ✅)
- `accentOrange` / `darkAccentOrange` — Seçili marker turuncu
- `darkPrimaryLight` — Koyu mod aktif chip yeşili (`0xFF8FD8A8`)
- `categoryWater/Mountain/Formation/Nature/Camp/Route/Discovery/Wildlife/Utility` — Harita marker renkleri
- `clusterMarker` — Harita küme daire rengi
- `shadow08/26/33/80` — Gölge sabitleri
- `darkGlass`, `darkSurfaceDeep` — Cam ve derin yüzey overlay'leri
- `accentOrangeOf()`, `primaryLightOf()` — Theme-aware helper'lar

### Birleştirme Kararları
Aşağıdaki çok yakın tonlar tek token'da birleştirilecek (Salı–Perşembe taşıma sırasında):
- `0xFF0F1512`, `0xFF0F1511`, `0xFF111713` → `AppColors.darkSurfaceDeep`
- `0xFF8A8680`, `0xFF9A968E`, `0xFF8C8983` → `AppColors.textTertiary` (yakın ton, kabul edilebilir fark)
- `0xFF1E2D23`, `0xFF152A1C` → `AppColors.darkPrimarySoft` (zaten token'da)
- Shadow siyahları (`0x44`, `0x33`, `0x18...`) → `AppColors.shadow26/33/08`


---

## Model Hatırlatma

| Görev Tipi | Model |
|---|---|
| Grep / envanter / tek dosya taşıma | Flash (Hızlı) |
| Çoklu dosya refactor / tipografi normalizasyonu | Terra (Normal) |
| Semantics / a11y / erişilebilirlik denetimi | Terra (Normal) |
| Kritik mimari kararlar | Sol (Kapsamlı) |
