# Doğadayım — Kalıcı Hafıza

Son güncelleme: 2026-10-07
Son doğrulanan commit: `99e0765fda6ee343f7a6ff3e3dd1902864b61787`

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

- Üretime Hazırlık, Yerel Kalıcılık & Fotoğraf Zenginleştirmesi (P0/P1/P2):
  - Yerel favori kalıcılığı: `UserFavoritesController` SharedPreferences (`user_favorites_v1`) ile cihazda kalıcı kılındı; hesap silme akışında temizlenmesi doğrulandı.
  - Harita kümeleme regresyon düzeltmesi: Tekil noktaların sayı rozeti olarak görünmesi engellendi; yerel kayıtların harita açılışında görünürlüğü sağlandı.
  - Kontrollü fotoğraf aktarımı & doğrulama: `PlacePhotoPolicy` Pixabay A/B-Q1/Q2 kalite kuralları ve EKOTABAN onaylı görsel arşivi entegre edildi.
  - Veri temizleme araçları: `tools/clean_places_data.py` ve `tools/import_81il_master.py` testleri başarıyla doğrulandı.
  - Yayın öncesi preflight: `docs/RELEASE_CHECKLIST.md` ve `PLAY_STORE_RELEASE_PLAN.md` kriterleri tamamlandı.
  - 217/217 test (%100) başarıyla geçti, `flutter analyze` 0 hata.

- Yönetici Paneli Tamamlama & Yönetici MFA (P1 #5 & #6):
  - Duplicate kontrolü: Başvuru incelemesinde ~1 km bbox ve ada göre benzer yer tespit ve uyarı bileşeni (`_DuplicateCheck`) eklendi.
  - Moderasyon geçmişi (audit log): `moderation_audit_logs` tablosundan değiştirilemeyen işlem geçmişini kronolojik gösteren `_AuditLogSection` eklendi.
  - Canlı dashboard istatistikleri: Bekleyen, onaylanan, reddedilen, düzeltme bekleyen sayıları chip rozetlerine bağlandı.
  - Yönetici MFA (TOTP 2FA): Supabase Auth TOTP iki aşamalı doğrulama entegrasyonu tamamlandı; AAL2 güvence seviyesi kontrolü (`_AdminGateState`), 6 haneli kod doğrulama ekranı (`_AdminMfaVerifyScreen`) ve panel içi TOTP kurulum/kaldırma dialogu (`_AdminMfaSettingsDialog`) eklendi.
  - 217/217 test (%100) başarıyla geçti, `flutter analyze` 0 hata.

- Yayın Öncesi Güvenlik Sıkılaştırması:
  - Yardım çağrısı tam koordinat ve iletişim gizliliği sağlandı; `help_requests` tablosu RLS ile kilitlendi, genel kullanıcılar için maskelenmiş `help_requests_feed` görünümü oluşturuldu.
  - Sunucu taraflı `help_request_acceptances` tablosu, `accept_help_request` ve `cancel_help_request_acceptance` RPC fonksiyonları oluşturuldu. Yardım kabulü sunucu tarafında yetkilendirildi.
  - Tüm bekleyen migration'lar (`202609250001`, `202609270001`, `202609280001`, `202610020001`, `202610020002`, `202610020003`) canlı Supabase veritabanına uygulandı.
  - `user_notifications` tablosundaki doğrudan `UPDATE` yetkisi kaldırıldı; yalnızca `mark_notification_as_read` fonksiyonuyla sınırlandı.
  - Fotoğraflarda EXIF/GPS temizliği (`stripExif` ve `requestFullMetadata: false`) eklendi.
  - `AndroidManifest.xml` içinde `allowBackup="false"` tanımlandı; çıkış/hesap silme işlemlerinde son koordinatlar ve avatar temizlendi.
  - 3+ şikayet alan yardım çağrılarını otomatik gizleyen/sonlandıran veritabanı tetikleyicisi (`check_help_request_reports_threshold`) eklendi.
  - 167/167 test (%100) başarıyla geçti, `flutter analyze` 0 hata.

- Kullanıcı Adıyla Arama ve Supabase Entegrasyonu:
  - Arama ekranında (`FigmaSearchScreen`) hem yer adı hem de doğrudan kişi adına (örneğin "Hüsnü Tuna") göre arama desteği sağlandı; @ zorunluluğu olmadan doğal arama deneyimi sunuldu.
  - Katkıda bulunan kişi eşleştiğinde sonuçların altında `👤 [Kullanıcı] tarafından eklenenler` başlığıyla yerler listelenir.
  - Supabase'de `place_submissions` ve `places` tablolarına `author_name` kolonları, `stamp_place_submission_author` trigger'ı ve `approve_place_submission` RPC fonksiyonu migration ile canlıya uygulandı (`npx supabase db push`).
  - `Place` modeline `contributorName` eklendi; yerel SharedPreferences ve Supabase önbelleklerinde çift yönlü destek sağlandı.
  - 167/167 test (%100) başarıyla geçti, `flutter analyze` 0 hata.

- İhtiyaç Yerleri (WC, İçme Suyu, Çeşme) ve Servis Kartlarında Hava Durumunun Kaldırılması:
  - WC, içme suyu ve çeşme gibi temel ihtiyaç yerleri (`isUtility`) ile mobil servislerin (`isMobileService`) detay ekranlarındaki Bölge Havası (`_LiveWeatherCard`) kartı gizlendi.
  - İhtiyaç yerleri için gereksiz arka plan hava durumu ağ istekleri (`WeatherService.fetchTarget`) engellenerek veri tasarrufu sağlandı.
  - Doğa/gezi destinasyonlarında hava durumu kartı korunurken, 166/166 test başarıyla geçti, `flutter analyze` 0 hata.

- Yer Detayı "Bölge Havası" Kartının Kompaktlaştırılması:
  - 400+ px dikey alan kaplayan hava kartı varsayılan olarak ~120 px kompakt özet görünümüne getirildi (%70 alan tasarrufu).
  - Şık açılır/kapanır "5 Günlük Doğa & Kamp Tahmini ▾" butonuyla tam metrikler ve 5 günlük tahmin isteğe bağlı açılır kılındı.
  - 164/164 test başarıyla geçti, `flutter analyze` 0 hata.

- Ana Sayfa Canlı Harita Bölümünün Kaldırılması & Harita "Haritada Göster" Butonu Koruması:
  - Kullanıcı isteği doğrultusunda ana sayfadaki mini canlı harita kartı (`_HomeMiniMapPreview`) telefon ve tablet akışlarından tamamen kaldırıldı; ana ekran akışı "Bugün sana uygun" ve "Yakındakiler" ile sade ve hızlı tutuldu.
  - Keşfet haritasındaki seçili yer alt kartında yer alan "Haritada Göster" (`mapController.move` ile yumuşakça ortalama ve -90px ofset) ve "Detayları Gör" butonları korunarak çalışmaya devam ediyor.
  - 164/164 test eksiksiz geçti (`All tests passed!`), `flutter analyze` 0 hata ile doğrulandı.

- Yer Detayı "Bölge Havası" Kartı Kompaktlaştırma & Açılır/Kapanır 5 Günlük Tahmin:
  - Kartın başlangıç yüksekliği 400+ px'ten ~120 px'e indirilerek dikey alanda %70 tasarruf sağlandı.
  - Üst satırda yer adı, "ŞU AN" göstergesi ve kompakt "Doğaya Uygun / Tedbirli Ol" rozeti; ana satırda derece, açıklama, hissedilen sıcaklık, hızlı nem/rüzgâr çipleri ve hava durumu emojisi konumlandırıldı.
  - "5 Günlük Doğa & Kamp Tahmini ▾" butonuna dokunulduğunda kart genişler; detaylı 4'lü metrik (Nem, Rüzgâr, UV, Görüş) ve 5 günlük kamp tahmin şeridi açılır.
  - 164/164 test başarıyla geçti, `flutter analyze` 0 hata.

- Ana Sayfa "Bugün Sana Uygun" Kartlarının Yan Yana Eşit Hizalanması:
  - Telefondaki 240 px sabit kart genişliğinden ötürü 2. kartın yarıda kesilmesi sorunu çözüldü.
  - Önerilen 2 kart `Row` + `Expanded` yapısıyla ekran genişliğini %50 - %50 eşit paylaşacak şekilde tam sığdırıldı; ikisi de taşmadan eksiksiz ve dengeli görünüyor.
  - 164/164 test başarıyla geçti, `flutter analyze` 0 hata.

- Arama Ekranları Temizliği & İlgililik Sıralaması (Harita ve Ana Ekran):
  - Harita Arama Delegesi: Başlangıçta tüm verilerin alt alta dökülmesi engellendi; alan boşaltıldı, yönlendirici rehber ikon ve mesaj eklendi. Aranan kelimeye göre eşleşmeler ve isim öncelikli sıralama getirildi.
  - Ana Ekran Arama: Kelime girilmediği sürece yer kartlarının alt alta yığılması engellendi. Seçili kategori filtresine göre dinamik arama ipucu, son arama geçmişi ve arama yapıldığında en alakalı sonuçları öne çıkaran puanlama uygulandı.
  - 163/163 test başarıyla geçti, `flutter analyze` 0 hata.

- Mobil Servis, Yol Yardım ve Hizmet Sağlayıcı Sistemi (Görsel Referanslı Mimari):
  - Haritada Yüzen Buton: Keşfet haritasının sağ alt köşesinde sarı/amber kenarlıklı `Servis 🛠️` hap butonu eklendi.
  - "Mobil Servis" Hub Ekranı: 3 kolonlu ızgarada 10 ana hizmet kategorisi (Çekici/Yol Yardım, Yıllık Bakım, Gaz, Isıtma/Soğutma, Elektrik, Su/Tesisat, Nem/Gövde, Şasi/Fren, Montaj/Parça, Muayene).
  - Firma Ekleme Kartı ve Formu: "Servis veren firma mısınız?" kartı ile işletme adı, telefon, çalışma saatleri ve hizmet alanı içeren `_AddServiceFirmSheet` eklendi (`AppAuthGuard.requireAuth` korumalı).
  - Doğrudan İletişim: Telefon numarası olan servis noktalarında hem yer detayında hem alt barda yeşil "Hemen Ara" butonu (`launchUrl('tel:...')`) ve çalışma saatleri gösterimi.
  - 162/162 test başarıyla geçti, `flutter analyze` 0 hata.

- Değerlendirme Düzeltme, Hatalı Görsel Yönetimi, Olanak Düzeltme, Kaynak Temizliği & Sosyal Medya Hesapları:
  - Değerlendirme Düzenleme / Silme: Yapılan değerlendirmeler düzenlenebilir veya tamamen kaldırılabilir hale getirildi (`UserReviewsController.deleteReview`).
  - Hatalı Yüklenen Görseli Silme: Fotoğraf ekleme modalında ve tam ekran galeride topluluk fotoğrafları için anında silme/onay aksiyonu sunuldu (`CommunityPlacePhotosController.removePhoto`).
  - Olanak Durumu Düzeltme: Olanak kartında gerçeği yansıtmayan durumlar için "Yanlış / Hatalı Bilgiyi Düzelt" seçeneği eklendi.
  - Veri Kaynağı ve Fotoğraf Atıflarının Temizlenmesi: Yer detayındaki veri kaynağı, kayıt türü, dış bağlantı linkleri ve fotoğraf atıf satırları temizlendi.
  - Profil Sosyal Medya Hesapları: Profil kartı ve ayarlar menüsünden Instagram, Facebook, YouTube hesapları girilebilir/düzenlenebilir hale getirildi (`UserSocialAccountsController`); herkese açık profilde rozetler halinde sunuldu.
  - 160/160 test başarıyla geçti, `flutter analyze` 0 hata.

- Doğadayım Tablet Uyum Yol Haritası (9 Adım):
  - Ekran sistemi: Telefon (`0-599 dp`), Tablet dikey (`600-839 dp`), Tablet yatay (`840+ dp`, max 1440 dp).
  - Harita: Yatay modda %68 harita, %32 interaktif sidebar keşif paneli; dikey modda tam ekran harita + alttan responsive sheet.
  - Ana Sayfa: Yatay modda çift kolon (%55 keşif kartları, %45 yakın yerler ve canlı harita); dikey modda iki sütunlu öneriler.
  - Yer Detay: Yatay modda sol %46 galeri/hava durumu, sağ %54 olanaklar/aksiyonlar/güven; dikey modda 420 dp kapak + merkezlenmiş bloklar.
  - Profil & Katkılar: Yatay modda sol avatar/hesap/ayarlar, sağ onaylı katkılar/bildirimler; dikey modda iki kolonlu kartlar.
  - İyilik Harekâtı: Yatay modda sol %58 interaktif Türkiye haritası, sağ %42 iyilik ekle/seçili il kartı/sıralama; dikey modda 320 dp harita + çift kolon.
  - Topluluk Sohbetleri: Yatay modda master-detail düzen (sol 340 dp odalar listesi, sağ aktif sohbet penceresi); dikey modda merkezlenmiş akış.
  - Yer Ekleme: Yatay modda sol %54 form adımları, sağ %46 interaktif harita pini/fotoğraf galerisi/özet kartı/kaydet; dikey modda 720 dp merkezli akış.
  - Kalite Kontrolü: 6 hedef cihaz boyutunda (360x800, 430x932, 600x960, 834x1194, 1194x834, 1280x800) test edildi, sıfır taşma, tüm 157 test %100 başarılı.
  - Mobil Önizleme Sabitlemesi: Web/Masaüstü geliştirme ortamında yapay web sitesi yayılması engellendi; uygulama 430 px saf telefon çerçevesine sabitlendi.

- Obruk Temizliği, Profil Avatarı, Olanak Güncelleme, Mekâna Fotoğraf & Haritada İşletmeler:
  - Sokak, cadde, kümeevleri, cami ve kadastro sınırları (`isNonNatureCandidateName`) ile temizlendi; gerçek karstik obruklar korundu.
  - Profil ekranında kullanıcı avatarı özelleştirme (`UserProfileAvatarController`, doğa şablonları, özel URL) eklendi.
  - Yer detayında olanaklar kartı reaktif hale getirildi; "Var", "Yok" veya "Bilmiyorum" seçenekleriyle topluluk geri bildirimi (`CommunityFacilityUpdatesController`) sağlandı.
  - Mekân detayına fotoğraf ekleme (`_openAddPhotoModal`, `CommunityPlacePhotosController`) entegre edildi.
  - Fotoğraflarda ekleyen ismi gösterimi ve sadece açık katkıları (fotoğraf ve eklediği yerler) gösteren güvenli `PublicUserProfileScreen` oluşturuldu.
  - Haritada `🏪 İşletmeler` filtresi ve Yer Ekleme'de `İşletme / Hizmet` kategorisi (kaynakçı, fırın, oto tamir, hamam vb.) kullanıma sunuldu.
  - 141/141 test ve `flutter analyze` 0 hata ile doğrulandı.

- Misafir Profil Koruması, Sohbet Odaları Özelleştirmesi & GPS Konum Güncellemesi:
  - Misafir kullanıcıların profil sekmesine veya profil kartına dokunduklarında otomatik giriş modalı (`AppAuthGuard.requireAuth`) ile karşılanması sağlandı; yetkisiz profil açılışı engellendi.
  - Topluluk sohbet odalarındaki tekdüze sorular kaldırıldı; 8 ana kategori için bölge rehberleri ve uzman rollerden oluşan gerçekçi soru-cevap akışı ve kategoriye özel prompt butonları eklendi.
  - Üst bardaki konum metni gerçek idari isimleri (örn. Pozantı, Adana; Yenimahalle, Ankara; Konya) gösterecek şekilde çevrim içi (BigDataCloud, OSM Nominatim) ve çevrim dışı (81 il + ilçe koordinat haritası) ters jeokodlama (`LocationReverseGeocoder`) ile güçlendirildi.
  - Konum SharedPreferences ile kalıcı kaydedildi; üst bardan açılan `LocationUpdateSheet` ve "Konumu Güncelle" butonu eklendi, konuma dışarıdan elle müdahaleye izin verilmedi.
  - 133/133 test ve `flutter analyze` 0 hata ile doğrulandı.
- Haritada Seçili Yer Vurgusu & "Haritada Göster" Butonu:
  - Seçili marker artık etraftaki yeşil/mavi doğa pinlerinden net biçimde ayrılan canlı gün batımı turuncusu (`AppColors.accentOrangeOf(context)` - `#FF6D00`), ışıltılı hale halkası, beyaz çerçeveli simge rozeti ve turuncu çerçeveli kalın başlık rozetiyle vurgulanıyor.
  - Haritada seçilen yerin alt sekmesine (`_MapDiscoverySheet`) her yer için doğrudan **"Haritada Göster"** butonu (`Icons.my_location_rounded`) ve **"Detayları Gör"** butonu eklendi.
  - "Haritada Göster"e basıldığında harita kamerasını seçili yere yumuşakça ortalayıp (`mapController.move`), kartın arkasında kalmaması için dikey ofset (`-90px`) ile tam görünür konuma getirir; dar ekranlar (320px) için taşmasız (`overflow-free`) esnek yapı sağlandı.
  - 130/130 test eksiksiz geçti (`All tests passed!`), `flutter analyze` 0 hata ile doğrulandı.
- Misafir Kullanıcı Yetkilendirme ve Kısıtlama Sistemi (Guest Mode Security Wall):
  - `AppAuthGuard` merkezi yetkilendirme kalkanı (`isAuthenticated`, `isGuest`, `requireAuth(...)`, `@visibleForTesting debugOverrideAuthenticated`) ve Apple-stili buzlu cam tasarımlı `_GuestAuthWallSheet` alt modalı devreye alındı.
  - Katkı kanalları kilitlendi: Ana bar `+` Yer Ekleme butonu, `AddPlaceScreen.savePlace()` formu, Yer Detay ekranı yorum/puanlama modalı (`openReviewRecommendSheet`), İyilik Harekâtı iyilik ekleme (`_openAddDeed`).
  - İletişim & Güvenlik koruması: Topluluk Sohbetinde misafire özel kilit uyarısı ve gönderim engeli (`addPreviewMessage`), Acil Yardım çağrısı oluşturma (`EmergencyHelpRequestSheet.show`) ve çağrı kabul etme (`acceptRequest`) yetkilendirme kalkanıyla korundu.
  - Profil ekranı (`favorites_profile.dart`) misafir moduna uyarlandı ("Doğa Kaşifi (Misafir)" başlığı, "Giriş Yap / Kayıt Ol" aksiyonu).
  - 130/130 test eksiksiz geçti (`All tests passed!`), `flutter analyze` 0 hata ile doğrulandı.
- Doğadayım Premium Tasarım Sistemi, UX & Güvenlik Master Planı (Faz 1 - Faz 7):
  - Faz 1: Acil yardım çağrılarında ~300m yaklaşık koordinat (fuzzing), gizli iletişim koruması, 112 yönlendirme banner'ı, bildirim okundu RPC'si (`mark_notification_as_read`), oturum kapatmada yerel hassas veri tasfiye koruması.
  - Faz 2: Anlamsal renk sistemi (`AppColors.communityWarm` kehribar/altın token'ı eklendi), taksonomiye `IconData` standardı getirildi; `community_chat` ve harita filtrelerindeki emojiler yerini tutarlı `IconData` çizgi ikonlarına bıraktı.
  - Faz 3: Harita ekranı kontrolleri sadeleştirildi; kümeler (`_MapClusterMarker`) baskın kategori ikonu + sayı (`🌲 12`) ile görselleştirildi; seçili pine ışıltılı halka efekti verildi; harita boşluğuna dokunulduğunda alt önizleme kartının kapanması (`onTap` dismiss) sağlandı.
  - Faz 4: Ana sayfa hiyerarşisi netleştirildi, tepe konum başlığı "Bulunduğu alan" yapıldı; öneri motorunda fotoğraflı mekanlar önceliklendirildi (`photoWeight: 15`); ana sayfa altına topluluk önerileri bölümü eklendi; temiz placeholder korundu.
  - Faz 5: İyilik Harekâtı ekranındaki güven kırıcı "örnek veri" ibareleri temizlendi, eylem butonu "İyilik Ekle" yapıldı, katkı sonrası kutlama SnackBar'ı eklendi; il haritası legend ve rozet etkileşimi iyileştirildi.
  - Faz 6: Topluluk sohbet kartlarına "Aktif" rozeti eklendi; boş sohbet durumunda yönlendirici soru çipleri sunuldu; kullanıcı profilinde e-posta adresleri varsayılan olarak maskelendi (`j***@domain.com`); acil yardım kartı normalde sakin/muted, acil çağrıda kırmızı hale getirildi.
  - Faz 7: Onboarding 3 adıma indirgendi, ilk slayttan itibaren "Misafir olarak keşfet" butonu yerleştirildi; alt navigasyon barında içerik kesilmesini önleyen 100px güvenli alt boşluklar doğrulandı.
  - 126/126 test eksiksiz geçti (`All tests passed!`), `flutter analyze` 0 hata ile doğrulandı.
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
