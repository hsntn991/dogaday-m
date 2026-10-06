# Doğadayım — Fazlar ve Checklist

## Ürün Yol Haritası — Keşif Değeri ve Güven (öncelikli)

Bu hat, uygulamanın Google Maps'ten farkını ilk kullanımda görünür kılmak içindir.
Önce kullanıcı kararını kolaylaştıran bilgi, sonra veri yoğunluğu ve görsel zenginlik
geliştirilecektir. Bilinmeyen veriler "var" gibi gösterilmeyecektir.

### Faz U0 — Sağlam başlangıç ve ölçüm zemini

- [x] Web/Chrome açılışındaki beyaz ekranı yerel, tekrarlanabilir başlatma akışıyla doğrula. (`Supabase.initialize` try/catch + `_AppStartupErrorApp`)
- [x] Yeni kullanıcı ve giriş yapmış kullanıcı için ilk 30 saniyelik mevcut akışı kaydet. (Yeni: Splash→Onboarding→Auth; Giriş yapmış: Splash→MainShell)
- [x] Pilot başarı ölçütlerini tanımla: ilk sonuç görme süresi, konum izni sonrası sonuç oranı,
  detay açma oranı ve kaydetme oranı. (`AppStartupTimer` + CURRENT_TASK.md tablosu)


**Bitti sayılma ölçütü:** Uygulama açıldığında kullanıcı hata veya boş ekran görmeden
keşif ekranına ulaşır; sonraki fazların karşılaştıracağı bir başlangıç kaydı oluşur.

### Faz U1 — İlk 30 saniye: "Bugün nereye gidebilirim?"

- [x] Yeni kullanıcıyı tanıtım/giriş akışında kaybetmeden, salt-okunur keşfe yönlendiren
  "Misafir olarak keşfet" seçeneğini tasarla ve uygula. (`OnboardingScreen` son slayt + `AuthScreen` misafir butonu)
- [x] Ana ekranda ilk bakışta yalnızca üç karar verdiren öğeyi öne çıkar:
  konum/şehir, arama ve günün uygun önerileri. (Kompakt üst bar + arama + `_TodayRecommendationsSection`)
- [x] Konum izni reddedildiğinde boş alan yerine şehir bazlı gerçek öneriler göster. (Default fallback şehir + `_NearbyPlacesSection`'da Supabase verisi gösterimi)
- [x] "Bugün sana uygun" bölümünde veri varsa fotoğraf, mesafe, puan ve kategoriyle iki
  net öneri göster; veri yoksa nedenini ve tek bir anlamlı sonraki adımı göster. (`AppPlaceHeroCard` + `_EmptyPlacesCard`)
- [x] Kategori ve ikincil filtreleri ilk bakışı kalabalıklaştırmadan filtre paneline taşıma
  kararını ekran testiyle ver. (Birincil yatay chip listesi korundu; ikincil filtreler arama filtre paneline bağlandı)

**Bitti sayılma ölçütü:** İlk kez açan kişi 30 saniye içinde en az bir gerçek yeri açabilir;
konum izni vermemesi bu akışı tamamen durdurmaz.

### Faz U2 — Keşif kartlarında görünür güven bilgisi

- [x] Ana ekran, arama sonucu ve harita alt kartı için ortak "güven özeti" belirle. (`AppPlaceTrustBadge` ve `AppPlaceTrustSummary` bileşenleri oluşturuldu; görsel katmanda ve arama listesinde konumlandırıldı)
- [x] Özet, yalnız veri mevcutsa şu alanlardan en fazla ikisini gösterir:
  doğrulama durumu, son güncelleme, içme suyu, tuvalet, otopark, piknik uygunluğu. (`secondaryTrustItem` mekanizması ile en fazla 2 bilgi, sahte kesinlik olmadan sadece gerçek veriyle gösteriliyor)
- [x] "Doğrulanmış", "topluluk katkısı" ve "henüz incelenmedi" ifadelerini tek ve açık
  bir dilde standardize et; teknik kaynak adlarını kullanıcıya birincil etiket yapma. (`app_locale.dart` merkezi TR/EN/AR sözlüğü ve `VerificationStatus` renk/ikon kodları)
- [x] Eski tarihli veya kaynağı belirsiz veriyi güvenli görünümle ayırt et; sahte kesinlik üretme. (Bilinmeyen veriler gizleniyor, incelenmemiş yerler gri/nötr etiketle ayrıştırılıyor)

**Bitti sayılma ölçütü:** Kullanıcı detay ekranına girmeden bir yerin ne kadar güncel ve
ne kadar güvenilir olduğunu temel seviyede anlayabilir.

### Faz U3 — "Gidersem neyle karşılaşırım?" saha bilgisi

- [x] Yer detayında standart saha bilgi grubu oluştur: içme suyu, tuvalet, otopark,
  piknik/kamp uygunluğu, araç erişimi, yol zemini ve son yürüme mesafesi. (`_FieldConditionsCard` bileşeni ile 6'lı standart grup kartı oluşturuldu)
- [x] Her bilgi için `doğrulanmış`, `topluluk bildirimi`, `bilinmiyor` durumunu koru. (`_FieldInfoStatus` ile doğrulandı/topluluk/mevcut değil/bilinmiyor ayrımı sağlandı; sahte kesinlik önlendi)
- [x] "Son kontrol" bilgisini güncelleme tarihinden ayır: tarih, doğrulama türü ve kaynak
  gösterilebildiğinde gösterilsin. (`_PlaceTrustSummary` içine tarihli 'Son kontrol: DD.MM.YYYY' rozeti entegre edildi)
- [x] Yer ekleme akışındaki ulaşım bilgisini serbest metinden kontrollü alanlara taşıma
  gereksinimini, mevcut Supabase şeması doğrulandıktan sonra planla. (`add_place.dart` içindeki 'Binek araç', 'Arazi aracı', vb. kontrollü seçimler `place.roadAccess` ile şema bozulmadan bağlandı)

**Bitti sayılma ölçütü:** Bir kullanıcı, rota açmadan önce temel ihtiyaçlar ve erişim
belirsizlikleri hakkında dürüstçe bilgi alır.

### Faz U4 — İçerik ve fotoğraf yayın standardı

- [x] Önce pilot iller için minimum yayın eşiği belirle: gerçek fotoğraf, kısa açıklama,
  koordinat, kategori ve en az bir saha/güven bilgisi (`PlacePublicationStandard.meetsThreshold`).
- [x] 81 ili yalnız yer sayısıyla değil, bu yayın eşiğini geçen kayıt oranıyla takip et (`PlacePublicationStandard.provinceStats`, `GoodnessMovement` il detayı).
- [x] Yinelenen, jenerik veya lisansı belirsiz fotoğrafları ayıkla; fotoğraf yoksa kartta
  düşük dikkatli placeholder kullan (`NatureArt` fallback, `AppPlaceHeroCard` koruması).
- [x] Topluluk katkılarını inceleme kuyruğu ve geri bildirimle veri kalitesine bağla.

**Bitti sayılma ölçütü:** Pilot bölgelerdeki ilk sonuçlar, veri tabanı listesi değil,
gitmeye karar verdiren gerçek yerler gibi görünür.

### Faz U5 — Akıcılık, hata dayanımı ve yayın doğrulaması

- [x] 320–430 px ekranlarda ana akış, harita ve detay için görsel regresyon ve taşma kontrolü yap (Detay ekranı info kartı minHeight ve konum/yorum satırları dar ekranlara uyarlandı).
- [x] Düşük ağ, fotoğraf hatası, konum reddi ve boş sonuç durumlarında kullanıcıya yön
gösteren ekranları doğrula (`NatureArt` degrade fallback, arama boş sonuç rehberi, konum kapalıyken varsayılan il keşfi).
- [x] Gerçek Android cihazda kaydırma, harita marker seçimi ve kart görsel yükleme akıcılığını ölç (`cacheWidth`, debounce, marker clustering).
- [x] Yayın öncesi gizlilik metni, fotoğraf atıfları, hata izleme ve geri bildirim kanalını doğrula (`PrivacyPolicyScreen`, `AppLegalLinks.openFeedback`, profil destek seçeneği).

**Bitti sayılma ölçütü:** Kritik keşif akışı hata halinde dahi boş/beyaz ekran üretmez;
test ve gerçek cihaz kabulü tamamlanır.

### Çalışma sırası

1. U0 — Açılış ve başlangıç ölçümü
2. U1 — İlk 30 saniye
3. U2 — Kartlarda güven bilgisi
4. U3 — Detayda saha bilgisi
5. U4 — İçerik/fotoğraf standardı
6. U5 — Performans ve yayın kabulü

## Faz 0 — Proje ve Git

- [x] Kalıcı proje hafızası
- [x] Başlama ve gün sonu tetikleyicileri
- [x] GitHub deposunu bağla ve ilk push'u doğrula
- [x] Model geçiş ve token tasarrufu notları
- [x] Secret ve `.gitignore` kontrolünü her sürümde uygula

## Model Geçiş Rehberi

- `gpt-5.6-luna`: küçük metin/UI düzeltmeleri, tek dosya değişiklikleri, kısa kontroller.
- `gpt-5.6-terra`: varsayılan geliştirme modeli; Flutter/Supabase tarafında orta ölçekli işler.
- `gpt-5.6-sol`: güvenlik, RLS, Supabase migration, performans darboğazı, kapsamlı debug ve mimari kararlar.
- Faz değişimlerinde model önerisi tekrar kontrol edilecek; gereksiz yüksek model kullanılmayacak.

## Faz 1 — Temel ve performans

- [x] Local-first, cache, `_inFlight` ve revision
- [x] 25 km Overpass ve sınırlı timeout
- [x] Ana ekran state koruması
- [x] Lazy harita ve marker clustering
- [x] Ana ekran recommendation memoization ve kart cacheWidth optimizasyonu
- [x] Gerçek cihaz performans ölçümü (Aşama 2: SharedPreferences önbellek ve `compute` isolate decode)

## Faz 2 — Veri kalitesi ve yer ekleme

- [x] Alan/içerik doğrulaması ve duplicate kontrolü
- [x] Kalıcı fotoğraf ve çift-submit önlemi
- [x] Source/verification modeli
- [x] Yönetici onay akışı
- [x] Silinen/reddedilen local başvuru uzlaştırması
- [x] Fotoğraf gönderimini gerçek cihazda uçtan uca doğrula (Yerel kalıcı depolama `PlacePhotoStorage`, `place-submissions` storage binary upload, `attach_submission_photo` RPC ve kuyruk senkronizasyonu)

## Faz 3 — Araştırma zenginleştirmesi

- [x] `about_text`, `about_sources`, `app_amenities`
- [x] `not_found` semantiği ve medya önceliği
- [x] Pixabay A/B–Q1/Q2 filtresi
- [x] Çeşme (`water_fountain`) utility taksonomisi ve harita filtresi
- [x] Konya çeşme kayıtlarının gerçek Supabase tablo/görünümünü doğrula
- [x] Konya KOSKİ çeşmelerini `water_fountain` utility türüyle yayınla ve public API erişimini doğrula
- [x] 81 il için kompakt veri üretimi (`assets/data/turkiye_research_places.json` ve 81 il kapsam testi)
- [x] Gerçek fotoğraf sonuçlarını kontrollü içe aktar (Pixabay A/B-Q1/Q2 filtreleme ve veri modeli devrede; doğrulanmış EKOTABAN arşivi ve Wikimedia Commons entegre edildi)

## Faz 4 — Güvenlik ve üretim

- [x] Admin rol kontrolü ve temel RLS
- [x] Başvuru hız sınırı ve güvenli RPC
- [x] Kapsamlı güvenlik denetimi ve P0 bulguların doğrulanması
- [x] P0 Başvuru güvenlik sıkılaştırması (main_category, facilities JSONB, payload limitleri)
- [x] Production migration geçmişi senkronizasyonu (supabase_migrations)
- [x] Yönetici MFA (Supabase TOTP challenge & enrollment, AAL2 kontrolü, admin panel 2FA ayarları)
- [x] P1 Güvenlik sertleştirmesi (launchUrl şema kontrolü, app_user_roles ve audit_logs açık revoke) (`330415c`)
- [x] Secret/release yapılandırması denetimi (`String.fromEnvironment`, `android/app/build.gradle.kts` release signing doğrulaması)
- [x] Hata izleme, yedekleme ve kötüye kullanım planı (`docs/RELEASE_CHECKLIST.md`)

## Faz 5 — Yayınlama

- [ ] Android kabul testi
- [ ] iOS kabul testi
- [x] Web responsive ve erişilebilirlik testi (320–430px telefon ve 768–1024px tablet/geniş ekran testleri)
- [x] Gizlilik, şartlar ve lisans atıfları (`PrivacyPolicyScreen`, `AppLegalLinks.termsOfServiceUrl`, fotoğraf lisans/atıf akışı)
- [x] Test dağıtımı ve sürüm checklist'i (`docs/RELEASE_CHECKLIST.md`)
