# Doğadayım — Kalıcı Hafıza

Son güncelleme: 2026-09-26
Son doğrulanan commit: `330415ccf372bd264e620282beded15499631532`

## Ürün amacı

Türkiye için toplum destekli doğa haritası. Gerçek konum, kaynak ve kullanıcı katkıları dürüst biçimde gösterilir; sahte örnek veri kullanılmaz. Kullanıcı katkıları yönetici onayından önce yalnız katkıyı yapan kullanıcıda görünür.

## Kalıcı kararlar

- Android, iOS ve web desteklenir.
- Tasarım beyaz zeminli, modern, keskin köşeli ve Outfit ağırlıklıdır; eski görünüm yedektedir.
- Ana ekran önerileri konum, hava, erişim, mesafe ve güven sinyalleriyle belirlenir; su çeşmeleri gezi önerisine dahil edilmez.
- Ana sayfadaki yakın yerler kullanıcı konumuna; detaydaki yakın yerler açılan mekâna göre hesaplanır.
- Sabit/sahte mesafe, süre, puan, yorum, fotoğraf veya olanak gösterilmez.
- OSM kaydı kullanıcı tarafından doğrulanmış sayılmaz. Kullanıcı katkısı başlangıçta doğrulanmamıştır.
- Yönetim, ortak parola yerine Supabase hesabı ve admin/moderatör rolüyle korunur; asıl güvenlik sınırı RLS'dir.
- Yer ekleme alan doğrulama, içerik koruması, duplicate kontrolü ve tekil submit uygular.
- Harita OSM altlığı, gerçek koordinatlar, kategori filtresi, marker cluster ve canlı kullanıcı konumu kullanır.
- Çevrimdışı local kayıtlar ve gönderim kuyruğu korunur.
- V8.5.1 araştırma motoru ve 81-il PBF önbelleği uygulama entegrasyonundan bağımsız tutulur.
- Konya KOSKİ tarihî çeşme envanteri `places` içindedir; 3.617 koordinatlı kayıt `water_fountain` utility olarak doğrulanmış ve yayınlanmıştır. Bu kayıtlar Keşfet destinasyonları değildir; haritadaki ayrı Çeşme filtresinden görünür.

## Model kullanım notları

- Kullanıcı token/kredi tüketiminin dengede tutulmasını istiyor; işler yarım kalmamalı.
- Basit görevlerde `gpt-5.6-luna`, normal geliştirmede `gpt-5.6-terra`, kritik/karmaşık işlerde `gpt-5.6-sol` önerilir.
- `gpt-5.6-sol` yalnız güvenlik, veri modeli, RLS, performans darboğazı, büyük hata ayıklama veya yüksek riskli kararlar için kullanılmalı.
- Her yeni faz başında önerilen model seviyesi kullanıcıya hatırlatılmalı.
- Gereksiz proje taraması, aynı dosyayı tekrar okuma, geniş refactor ve gereksiz test komutları token maliyeti artırdığı için kaçınılmalıdır.

## Tamamlanan ana fazlar

- Local-first performans, cache, 25 km Overpass, lazy harita ve ana ekran state koruması.
- Merkezi kategori/olanak eşlemesi, veri kaynağı ve doğrulama modeli.
- Kalıcı kullanıcı fotoğrafı, yer ekleme kalite kontrolü ve moderasyon başvuru akışı.
- Supabase yönetici paneli, güvenlik migration'ları ve başvuru/local kayıt uzlaştırması.
- Marmara hakkında, kaynak, olanak ve açık lisanslı fotoğraf zenginleştirmesi.
- Ana ekran performans optimizasyonu: build() dışına çıkarılan memoized recommendation motoru ve kart cacheWidth küçültmesi (`e5769c1`).
- Eski profil buton tasarımı testinin güncellenmesi (`ecd3a53`).
- Kapsamlı güvenlik denetimi: P0/P1/P2 sınıflandırması ve preflight doğrulaması.
- P0 Başvuru Güvenlik Sıkılaştırması (`202609130001`): `main_category`, `facilities` JSONB ve payload boyut sınırları veritabanı seviyesinde eklendi; `supabase_migrations` tablosu başlatılarak tüm migration geçmişi production'da senkronize edildi (`552f7f4`).
- P1 Güvenlik Sertleştirmesi (`202609140001`): `launchUrl` şema kontrolü (`http`/`https`), `app_user_roles` ve `moderation_audit_logs` için `anon`/`authenticated` INSERT/UPDATE/DELETE yetkilerinin açık `REVOKE` kuralı production'da uygulandı ve yerel kodla birlikte senkronize edildi (`330415c`).
- Performance Stage 2 Adım 1: `ResearchPhotoPlaces.merge` ve `RegionalResearchPlaces.merge` için $O(M \times N)$ iç içe döngüsü $O(N + M \times K)$ indeksli lookup yapısına dönüştürüldü, duplicate semantiği (sourceId veya isim + 750m mesafe) 5 birim testiyle korundu.
- Uygulama Geneli Glassmorphism Tasarımı & Topluluk Sohbeti Erişimi:
  - Giriş ekranı (`AuthScreen`): Organik doğa derinlik orbları, frosted glass form paneli, cam metin girişleri, Apple/Google cam butonları ve "Misafir olarak devam et" yüzen cam hap butonu.
  - Topluluk Sohbeti (`CommunityChatHubScreen`): Ana ekran başlığına (`_HomePremiumHeader`) eksik olan cam sohbet butonu ve Profil ekranına "Topluluk Sohbeti" menü erişimi eklendi; sohbet odaları kartları cam tasarım sistemine bağlandı.
  - Harita kontrolleri, yüzer alt gezinme barı (`_FigmaBottomBar`), detay aksiyon barı ve profil kartı Apple tarzı buzlu cam (`GlassContainer` / `GlassIconButton`) ile optimize edildi.
  - 320px–430px mobil ekran taşma testleri dahil tüm testler (59/59) ve statik analiz (0 hata/uyarı) doğrulandı.
- Dark Mode Okunabilirlik ve Harita Katmanları:
  - Harita arama ve liste alanları dark mode'da yüksek kontrastlı hale getirildi.
  - Harita chip'leri seçili ve alt kategori durumlarında buzlu cam (`GlassContainer`) yapısına kavuşturuldu.
  - Çoklu harita katmanı seçici (Standart OSM, Esri Uydu, OpenTopo Doğa/Topo) entegre edildi.
- Kalıcı Değerlendirme & Yorum Sistemi:
  - Kullanıcı yerleri ve haritadaki tüm noktalar için yapılan yorum/puanlamaların kaybolmasını önleyen `UserReviewsController` (SharedPreferences tabanlı) yazıldı. Supabase profil adı ve çevrimdışı yedekleme sağlandı. 69/69 test ve analiz tam temiz.
- Akıllı Navigasyon ve Resmi POI/Giriş Eşleştirme Sistemi:
  - Google Maps'e raw koordinat yerine yer adı ve konum etiketi (`destination=searchTarget`) ile akıllı yönlendirme sağlandı. Yüzlerce veriyi manuel düzenlemeye gerek kalmadan Google Haritalar'ın kayıtlı resmi giriş ve otopark noktasına otomatik bağlanması sağlandı. İsteğe bağlı ham GPS, Apple Maps (`&q=`), Yandex ve koordinat kopyalama eklendi. Toplam 76/76 test başarıyla geçti.
- Tasarım Sistemi Refactor (2 Haftalık Plan %100 Tamamlandı):
  - Hafta 1 (Renk Sistemi Konsolidasyonu): Proje genelindeki 700+'den fazla dağınık `Color(0x...)` kullanımı tamamen `AppColors` token'larına konsolide edildi. Projede `AppColors` sınıfı haricinde sıfır (0) adet `Color(0x...)` kaldı.
  - Hafta 2 (Tipografi, Dokunma Hedefleri, Erişilebilirlik):
    - 6 seviyeli sabit tipografi skalası (`AppFontSizes`: display 24px, heading 20px, title 16px, body 14px, label 13px, caption 11.5px) ve `AppTypography` context helper'ları kuruldu.
    - Proje genelindeki 30+ farklı font boyutu ve 7.5-9.5px arası okunamaz mikro metinler standart skalaya normalize edildi; metinler minimum 11.5px altına düşmeyecek şekilde güvenceye alındı.
    - Dokunma hedefleri denetlendi; `GlassIconButton` ve interaktif butonlar `AppControlSizes.minimumTouchTarget` (48px) standardına bağlandı.
    - `add_place.dart`, `detail.dart`, `search_map.dart`, `home.dart` ekranlarına TalkBack/VoiceOver uyumlu `Semantics` etiketleri eklendi.
    - `design_backups/` klasörü `.gitignore` kuralıyla doğrulandı.
    - 101/101 test ve 0 flutter analyze hatası/uyarısı ile tüm plan eksiksiz tamamlandı.
- Performans Optimizasyonu (Akıcılık & GPU/CPU Yükü Azaltma):
  - `PlaceEnrichmentService` önbellek (`findSync` + `_matchCache`) ile fotoğraf eşleme yükü sıfırlandı. `NatureArtPhoto.build()` senkron ön yol eklendi.
  - `app_core.dart`: `loadCachedAndRefresh()` içindeki çoklu `places.value` bildirimleri `_readCachedPlaces()` yardımcı metoduyla tek bir bildirimde birleştirildi (3x listener tetiklemesi teke indirildi).
  - Harita çipleri ve kontrollerindeki GPU kilitleyen ağır BackdropFilter blur'ları kaldırıldı (`blur: 0`), `FlutterMap` `RepaintBoundary` ile sarıldı, alt gezinme barı blur'u optimize edildi.
- Çoklu Dil Desteği (Arapça, İngilizce, Türkçe + RTL):
  - `lib/src/core/app_locale.dart` oluşturuldu: `AppLocaleController` (SharedPreferences kalıcı kayıt), `AppStrings` sözlüğü (TR/EN/AR), `AppLanguageOption` ve RTL yardımcıları.
  - `DogaApp` `ValueListenableBuilder<Locale>` ve `Directionality` ile Arapça RTL desteğine bağlandı.
  - Alt gezinme çubuğu (`_FigmaBottomBar`) ve profil ekranına modern cam görünümlü "Dil Seçeneği" menüsü ve seçim modalı eklendi (🇹🇷 Türkçe / 🇬🇧 English / 🇸🇦 العربية).
  - `flutter_localizations` entegre edildi; 72/72 test başarıyla geçti, `flutter analyze` 0 hata/0 uyarı.
- İlk Açılış Teması & Kullanıcı Tercihi Kalıcılığı:
  - İlk defa indiren kullanıcıda uygulamanın varsayılan olarak normal (açık / light) modda başlaması güvenceye alındı.
  - Kullanıcı profil ayarlarından temayı değiştirdiğinde bu seçim `app_user_dark_mode_preference` ile yerel olarak kalıcı saklanıyor; 75/75 test geçti.
- Tam Kapsamlı Uygulama Geneli Dinamik Çoklu Dil Desteği:
  - Dil seçeneği salt mod olmaktan çıkarılarak tüm ekranlarda, arama yer tutucularında, harita katman seçicilerinde, bilgi kartlarında, olanaklarda (`facilities`), hava durumu metriklerinde, kategori chip'lerinde, favoriler ve profilde dinamik ve anlık hale getirildi.
  - Test süitindeki tüm 91/91 test eksiksiz geçti (`All tests passed!`), `flutter analyze` 0 hata/0 uyarı ile tamamlandı.
- 5 Günlük Doğa & Kamp Hava Durumu Tahmini:
  - Kampa gidecek kullanıcılar için Open-Meteo entegrasyonu 5 güne genişletildi (`forecast_days: 5`). Detay ekranındaki hava durumu kartına gün gün yağış ihtimali (`💧%`), min/maks sıcaklıklar ve hava durumu emojisini içeren yatay şerit (`Detail5DayForecastStrip`) entegre edildi. Çoklu dil (TR/EN/AR) ve RTL tam senkronize. 94/94 test ve statik analiz 0 hata/uyarı ile doğrulandı.
- İngilizce Dil Modu Kapsamlı Çeviri ve Sekme Önbellek Düzeltmesi:
  - Ekran görüntülerinde iletilen İngilizce modundaki Türkçe kalan 4 ana ekran tamamen düzeltildi:
    1. Ana Ekran: `_MainShellState` altındaki önbelleğe alınmış sekmeler (`_tabScreens`) dil değiştiğinde reaktif olarak geçersiz kılınarak anında yeni dilde yeniden oluşturulması sağlandı. Üst konum çipi ("Location required" / "My Location") ve bölüm başlıkları ("Handpicked for Today", "Nearby places", "See all >") yerelleştirildi.
    2. Topluluk Sohbeti: Başlık ("Community Chats"), alt başlık, açıklama, kategori kart başlıkları (`category.localizedLabel`), alt yazılar ve mesaj odası içi metinler çevrildi.
    3. Alan Ekleme Ekranı: Başlık ("Add Place"), banner, alan adı ve açıklama alanları, harita konumu seçimi, fotoğraf ekleme alanı ve seçilen fotoğraf sayısı, kategori çipleri, çevre yapısı, ulaşım, olanaklar/uyarılar ve "Submit" butonu İngilizce/Arapça olarak yerelleştirildi (`AppStrings.addPlaceOption`). Veritabanı/Supabase kanonik veri yapısı tam olarak korundu.
    4. Profil Ekranı: Varsayılan kullanıcı adı ("Doğadayım User") yerelleştirildi.
  - 94/94 test ve `flutter analyze` 0 hata/uyarı ile doğrulandı.
- Faz U0 — Sağlam Başlangıç ve Ölçüm Zemini:
  - `Supabase.initialize` try/catch ile korundu; ağ hatası veya çökmede beyaz/siyah ekran yerine kullanıcıya dostane `_AppStartupErrorApp` gösterilmesi sağlandı.
  - `AppStartupTimer` eklendi (`boot`, `supabase_ok`, `controllers_ok`, `first_frame`, `splash_nav_*` milestone'ları).
- Faz U1 — İlk 30 saniye: "Bugün nereye gidebilirim?":
  - Onboarding son slaytına ve Auth ekranına "Misafir olarak keşfet" seçeneği eklendi; kullanıcı kayıt akışında kaybolmadan 1 tıklamayla keşif paneline ulaşabiliyor.
  - Konum izni reddedildiğinde veya koordinat yokken `_NearbyPlacesSection` boş alan üretmek yerine Supabase/yerel gerçek doğa noktalarını listeliyor; varsayılan şehir fallback'i devreye giriyor.
  - "Bugün sana uygun" bölümünde 2 net görsel öneri kartı sunuluyor; veri bulunamadığında `_EmptyPlacesCard` ile haritaya yönlendiriliyor.
  - 104/104 test eksiksiz geçti (`All tests passed!`), `dart analyze` 0 hata ile doğrulandı.
- Faz U2 — Keşif kartlarında görünür güven bilgisi:
  - `AppPlaceTrustBadge` ve `AppPlaceTrustSummary` bileşenleri oluşturuldu; ana ekran hero kartı (`AppPlaceHeroCard`), kompakt liste/harita kartı (`AppMapPreviewCard` / `AppCompactPlaceCard`) ve arama sonuç kartına (`_SearchResultCard`) entegre edildi.
  - "Doğrulanmış", "Topluluk katkısı" ve "Henüz incelenmedi" etiketleri `app_locale.dart` ile standartlaştırıldı; teknik altyapı isimleri kullanıcıya birincil etiket yapılmadı.
  - Sahte kesinlik üretmeden yalnızca gerçek veri varsa doğrulama rozeti + en fazla bir ek saha/güncellik bilgisi (içme suyu, tuvalet, otopark, piknik, güncelleme yılı) gösteriliyor.
  - 106/106 test eksiksiz geçti (`All tests passed!`), `dart analyze` 0 hata ile doğrulandı.
- Faz U3 — "Gidersem neyle karşılaşırım?" saha bilgisi:
  - Yer detayında 6'lı standart saha bilgi grubu (`_FieldConditionsCard`) oluşturuldu: İçme suyu, tuvalet, otopark, piknik/kamp uygunluğu, araç erişimi & yol durumu, son yürüme mesafesi.
  - `_FieldInfoStatus` ile doğrulandı, topluluk bildirimi, mevcut değil ve bilinmiyor durumları renkli/ikonlu etiketlerle ayrıştırıldı; sahte kesinlik önlendi.
  - "Son kontrol" bilgisi güncelleme tarihinden ayrıldı: `_PlaceTrustSummary` içinde tarihli 'Son kontrol: DD.MM.YYYY' rozeti entegre edildi.
  - Yer ekleme akışındaki ulaşım seçimi (`roadAccess`: Binek araç, Arazi aracı, vb.) mevcut Supabase şeması bozulmadan `place.roadAccess` getter'ı ile bağlandı.
  - 107/107 test eksiksiz geçti (`All tests passed!`), `dart analyze` 0 hata ile doğrulandı.
- Faz U4 — İçerik ve fotoğraf yayın standardı:
  - Pilot iller ve genel yerler için minimum yayın eşiği belirlendi (`PlacePublicationStandard.meetsThreshold`). Eşik: geçerli koordinat, 'Doğa Noktası' harici özgül kategori, gerçek fotoğraf, en az 10 karakter açıklama ve en az 1 doğrulanmış saha/güven verisi.
  - İl bazlı yayın standardı oranları (`PlacePublicationStandard.provinceStats`, `publicationRate`) modellendi; İyilik Harekâtı il modalında canlı gösterildi.
  - 110/110 test eksiksiz geçti (`All tests passed!`), `dart analyze` 0 hata ile doğrulandı.
- Faz U5 — Akıcılık, hata dayanımı ve yayın doğrulaması:
  - 320–430 px telefon ve 768–1024 px tablet/geniş ekranlarda görsel regresyon ve taşma kontrolleri yapıldı. Detay ekranı `info` kartları `minHeight: 89` ve `maxLines: 2` ile esnetilerek 320 px dikey taşma hatası tamamen giderildi; tepe konum ve değerlendirme satırları `mainAxisSize: MainAxisSize.min`, `Expanded`/`Flexible` ve `overflow: TextOverflow.ellipsis` ile korumaya alındı.
  - Fotoğraf hatalarında `NatureArt`'ın degrade arkaplan + kategori ikonuyla sıfır beyaz/kırık ekran ürettiği, arama boş sonuç durumlarında rehber mesajların gösterildiği doğrulandı.
  - Kullanıcı geri bildirim ve hata bildirimi kanalı (`AppLegalLinks.openFeedback`, `supportEmail`), Kullanım Koşulları (`AppLegalLinks.termsOfServiceUrl`, `openTermsOfService`) ve profil ayarlarına `profile_feedback` / `profile_terms` seçenekleri eklendi.
  - 114/114 test eksiksiz geçti (`All tests passed!`), `dart analyze` 0 hata ile doğrulandı.
- Faz 4 & Faz 5 — Sürüm Hazırlığı, Hata İzleme ve Yayın Checklist'i:
  - Supabase URL ve Publishable Key `String.fromEnvironment` ile yapılandırıldı; `--dart-define` desteği sağlandı (`lib/main.dart`).
  - `.gitignore` Python cache (`__pycache__/`, `*.pyc`), test coverage ve işletim sistemi çöp dosyalarıyla güçlendirildi.
  - Sürüm yayınlama, kötüye kullanım önleme ve operasyonel hata izleme checklist'i (`docs/RELEASE_CHECKLIST.md`) oluşturuldu.
- Faz 1 & Faz 3 — Önbellek ve Türkiye Kapsamı Doğrulaması:
  - `SupabasePlacesController` SharedPreferences önbelleği ve `compute` arka plan isolate decode mekanizması doğrulandı.
  - 81 il araştırma paketi (`assets/data/turkiye_research_places.json`) ve veri modeli entegrasyonu test edildi (`test/turkiye_research_asset_test.dart`).
- Faz 2 — Fotoğraf ve Yer Gönderim Akışı:
  - `PlacePhotoStorage` yerel dosya persistansı, `place-submissions` binary storage yükleme, `attach_submission_photo` RPC ilişkilendirme ve başarısızlık durumunda otomatik rollback temizliği doğrulandı.

## Açık riskler

- Android/iOS gerçek cihaz konum, fotoğraf, çevrimdışı ve arka plan senaryoları uçtan uca test edilmelidir.
- Yönetici hesabına güçlü parola ve mümkünse MFA eklenmelidir.
- OSM public tile kullanımı üretim trafiği için ayrıca değerlendirilmelidir.
- Supabase RLS/RPC smoke testleri her migration sonrasında çalıştırılmalıdır.

## Komutlar

- `başlıyoruz`: hafıza, görev ve yol haritasını oku; Git'i kontrol et; sonra işe başla.
- `tamam bu kadar` / `bugünlük bu kadar`: doğrula, belgeleri güncelle, commit et ve push et.
