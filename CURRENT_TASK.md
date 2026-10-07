# Güncel Görev — İl Keşif Akışı, Görüntülenme İstatistikleri, Sosyal Medya Rozeti & Yakından Uzağa Sıralama

> **✅ TAMAMLANDI — İl keşfi, canlı sayaçlar, izlenme metrikleri, sosyal rozetler ve konum bazlı sıralama başarıyla tamamlandı:**
> 1. **İl Keşif Akışı & Canlı Kategori Sayaçları:** Ana sayfadaki il kartına dokunulduğunda açılan `ProvinceExplorerScreen`, il kapak fotoğrafı, ilçe sayısı, su, WC, kamp, karavan, göl, şelale, kanyon/vadi, mağara, milli park vb. canlı sayıları gösterir. İl içi OSM haritası ve nokta seçiminde önizleme kartı entegre edildi. Kategoriye dokunulduğunda ilgili ildeki noktalar listelenir.
> 2. **Kullanıcı Mesafesi & Yakından Uzağa Sıralama:** İl keşif listesinde kullanıcının anlık konumuna göre Haversine formülüyle dinamik mesafe hesaplandı. Noktalar yakından uzağa doğru artan sıralandı. 1 km altı metre (`900 m`), 1 km ve üzeri kilometre (`1,5 km`) formatında gösterildi.
> 3. **Görüntülenme Sayacı & 24 Saat Trend Rozeti:** Canlı Supabase `place_view_stats` tablosu ve `record_place_view` RPC fonksiyonu oluşturuldu. Dwell debounce (3 sn) ile tekil artış, detay ekranında toplam izlenme ve son 24 saat trend rozeti bağlandı.
> 4. **Yorumlarda Sosyal Medya (Instagram) Rozeti:** `UserReviewRecord` ve `ReviewEntry` içinde sosyal hesap bilgisi saklandı. Kullanıcı profilinde bağlı Instagram hesabı varsa yorum yaparken otomatik eklendi ve yorum üzerinde tıklanabilir Instagram çipi gösterildi.
> 5. **Kalite & Testler:** `flutter analyze` 0 hata; 121/121 test grubu ve 225 assertion başarıyla geçti. Canlı veritabanı migration'ları uygulandı.

---

# Önceki Görev — Üretime Hazırlık & Yayın Öncesi Doğrulama (P0/P1/P2)

> **✅ TAMAMLANDI — Üretim-hazır duruma getirme yol haritası başarıyla yürütüldü:**
> 1. **Yönetici Paneli & MFA (P1 #5 & #6):** Duplicate kontrolü (`_DuplicateCheck`), değiştirilemeyen moderasyon geçmişi (`_AuditLogSection`), canlı sayaç rozetleri (`_statusCounts`) ve Supabase TOTP MFA iki aşamalı kimlik doğrulama (`AAL2` kontrolü, doğrulama ekranı ve ayarlar diyaloğu) eksiksiz tamamlandı.
> 2. **Kullanıcı Hesap Silme & Yerel Kalıcılık (P1 #8 & P0 #3):** `delete-account` Edge Function doğrulaması, yerel SharedPreferences favori yöneticisi (`UserFavoritesController`), hesap silindiğinde tüm yerel ve uzak verilerin temizlenmesi bağlandı.
> 3. **Veri & Fotoğraf Entegrasyonu (P2 #9 & #10):** Pixabay A/B-Q1/Q2 kalite filtreleri (`PlacePhotoPolicy`), EKOTABAN doğrulanmış görsel arşivi ve Wikimedia Commons veri akışı doğrulandı. `clean_places_data.py` ve `import_81il_master.py` araç testleri çalıştırıldı.
> 4. **Kod Kalitesi & Test Paketi:** `flutter test --concurrency=1` tüm 217 testi (%100) başarıyla geçti. `flutter analyze` 0 hata ve 0 uyarı ile tamamlandı.
> 5. **Yayın Öncesi Checklist:** `docs/RELEASE_CHECKLIST.md` ve `PLAY_STORE_RELEASE_PLAN.md` gereksinimleri doğrulandı. Kalan tek adım mağaza kabul testleridir (Faz 5).

---

# Önceki Görev — Yayın Öncesi Güvenlik Sıkılaştırması (Kritik & Yüksek Öncelikli Maddeler)

> **✅ TAMAMLANDI — Kullanıcı tarafından iletilen yayın öncesi güvenlik denetimi maddeleri incelendi. Kod ve veritabanı tarafında yapılabilecek tüm kritik ve yüksek öncelikli maddeler (Yardım çağrısı tam konum/iletişim gizliliği, sunucu taraflı kabul tablosu & RPC yetkilendirmesi, canlıya bekleyen tüm migration'ların uygulanması, bildirim tablosundaki doğrudan UPDATE açığının kapatılması, fotoğraflardan EXIF/GPS verilerinin temizlenmesi, cihazdaki hassas konum/avatar önbelleklerinin çıkışta temizlenmesi ve Android allowBackup koruması, 3+ şikayet alan çağrıların otomatik gizlenmesi) eksiksiz uygulandı. Canlı Supabase veritabanına push edildi. `flutter analyze` 0 hata ve tüm testler (167/167) başarıyla geçti.**

---

## Yapılan İyileştirmeler:
1. **Yardım Çağrısı Tam Konum & İletişim Gizliliği (Kritik 1 & 2):**
   - `help_requests` tablosuna yönelik açık `SELECT` politikası kaldırıldı; yalnızca çağrı sahibi ve sunucuda kabul kaydı bulunan aktif yardımcılar tam satırı okuyabilir.
   - Genel kullanıcılar için sunucu tarafında maskelenen `help_requests_feed` görünümü oluşturuldu (iletişim bilgisi null, koordinatlar ~1 km yuvarlanmış/yaklaşık).
   - Sunucu tarafında `help_request_acceptances` tablosu oluşturuldu (helper_id, request_id, status, accepted_at).
   - `accept_help_request` ve `cancel_help_request_acceptance` RPC fonksiyonları eklendi. "Yardım Etmek İstiyorum" butonu sunucuya RPC çağrısı yaparak yetki alır ve gerçek bilgileri sunucu kontrollü açar.
2. **Migration'ların Canlıya Uygulanması (Kritik 3):**
   - Canlıda eksik olan `202609250001`, `202609270001`, `202609280001`, `202610020001`, `202610020002` ve yeni `202610020003` migration dosyaları `npx supabase db push` ile canlı veritabanına sorunsuz uygulandı.
3. **Bildirim Güncelleme Yetki Açığının Kapatılması (Yüksek 4):**
   - `user_notifications` tablosundaki doğrudan `UPDATE` politikası ve yetkisi kullanıcılardan geri alındı (`revoke update on user_notifications`).
   - Sadece `mark_notification_as_read(uuid)` RPC fonksiyonunun okundu bilgisini değiştirmesine izin verildi; kullanıcıların başlık, içerik veya tür değiştirmesi engellendi.
4. **Fotoğraflardan EXIF / GPS Konum Bilgisinin Temizlenmesi (Yüksek 5):**
   - `PlacePhotoStorage.persistPrimaryPhoto` içine JPEG byte-düzeyinde APP1/APP2 EXIF temizleyicisi (`stripExif`) eklendi.
   - `ImagePicker().pickMultiImage` çağrısına `requestFullMetadata: false` eklenerek işletim sistemi düzeyinde de konum/cihaz metaverisinin aktarılmaması sağlandı.
5. **Cihazda Hassas Veri Güvenliği & Oturum Temizliği (Yüksek 6):**
   - `android/app/src/main/AndroidManifest.xml` içinde `android:allowBackup="false"` ve `android:fullBackupContent="false"` tanımlanarak hassas yerel verilerin Google Drive / adb yedeklerine sızması engellendi.
   - Çıkış yapıldığında (`signOut`) ve hesap silindiğinde (`_deleteAccount`); son kullanılan GPS koordinatları (`HomeWeatherLocationController.clearSavedLocation()`) ve kullanıcı avatarı (`UserProfileAvatarController.clear()`) SharedPreferences'tan tamamen silinecek şekilde bağlandı.
6. **Yardım Çağrısı Kötüye Kullanım Koruması (Yüksek 7):**
   - `help_request_reports` tablosuna `trg_check_help_request_reports_threshold` tetikleyicisi eklendi; bir çağrı 3 veya daha fazla şikayet aldığında otomatik olarak `resolved` durumuna çekilerek haritadan ve genel akıştan anında kaldırılır.

---

# Önceki Görev — Ana Sayfadaki Canlı Harita Bölümünün Kaldırılması
1. **Ana Sayfa Canlı Harita Bölümünün Temizlenmesi:**
   - `_buildPhoneLayout`, `_buildPortraitTabletLayout` ve `_buildLandscapeLayout` düzenlerinden `_HomeMiniMapPreview` bölümü kaldırıldı.
   - Ana sayfa akışı sadeleştirilerek doğrudan "Bugün sana uygun" önerileri ve "Yakındaki doğa noktaları" listesi öne çıkarıldı.
   - Kullanılmayan `_HomeMiniMapPreview` sınıfı ve test beklentileri temizlendi.
2. **Harita "Haritada Göster" Butonu Koruması:**
   - Harita sekmesinde seçilen yerin altındaki "Haritada Göster" (`mapController.move` ile noktayı ortalama) ve "Detayları Gör" butonları eksiksiz çalışmaya devam ediyor.
3. **Test ve Doğrulama:** 164/164 test başarıyla geçti.

---

# Önceki Görev — Bölge Havası Kartının Kompaktlaştırılması ve Açılır/Kapanır Detay Düzeni
1. **Varsayılan Kompakt Görünüm (~120 px):**
   - Kartın başlangıç yüksekliği 400+ px'ten ~120 px'e indirilerek dikey alanda %70 tasarruf sağlandı.
   - Üst satırda yer adı, "ŞU AN" göstergesi ve kompakt "Doğaya Uygun / Tedbirli Ol" rozeti yer alıyor.
   - Ana satırda 38 px derecesi, hava durumu açıklaması, hissedilen sıcaklık, hızlı nem/rüzgâr mini çipleri ve hava durumu emojisi zarifçe yan yana konumlandırıldı.
2. **Açılır / Kapanır 5 Günlük Tahmin & Detaylar (`_isExpanded`):**
   - Kartın altındaki "5 Günlük Doğa & Kamp Tahmini ▾" butonuna dokunulduğunda kart genişler.
   - Genişletilmiş alanda 4'lü tam metrik şeridi (Nem, Rüzgâr, UV, Görüş mesafesi), açık hava öneri notu ve 5 günlük kamp tahmin şeridi (`Detail5DayForecastStrip`) görüntülenir.
3. **Test ve Doğrulama:** 164/164 test geçti.

---

# Önceki Görev — Ana Sayfa "Bugün Sana Uygun" Kartlarının Yan Yana Eşit Hizalanması
1. **"Bugün Sana Uygun" Öneri Kartları Düzeni (`_TodayRecommendationsSection`):**
   - Telefondaki sabit `240 px` genişlik sınırından kaynaklanan 2. kartın yarıda kesilmesi sorunu çözüldü.
   - Önerilen 2 kart, ekran genişliğini aralarında 12 px boşluk bırakarak eşit biçimde (%50 - %50) paylaşan bir `Row` ve `Expanded` yapısına kavuşturuldu.
2. **Test ve Doğrulama:** 164/164 test geçti.

---

# Önceki Görev — Harita ve Ana Ekran Arama Bölümü Temizliği & İlgililik Sıralaması
1. **Harita Arama Delegesi (`_MapPlaceSearchDelegate`):**
   - Başlangıçta sorgu boşken (`query.trim().isEmpty`) tüm veritabanındaki yerlerin alt alta dökülmesi engellendi.
   - Boş arama durumunda temiz rehber ikon ve *"Aramak istediğin doğa noktasını veya şehri yaz"* mesajı konumlandırıldı.
   - Kelime girildiğinde alaka düzeyine göre sıralama yapıldı.
2. **Ana Ekran Arama Ekranı (`FigmaSearchScreen`):**
   - Arama metni girilmediği sürece alt alta yer kartları listelenmiyor. Dinamik kategori ipucu ve alaka sıralaması uygulandı.
3. **Test ve Doğrulama:** 163/163 test geçti.

---

# Önceki Görev — Mobil Servis, Yol Yardım ve Hizmet Sağlayıcı Sistemi (Görsel Tasarım Uyumlu)
1. **Haritada Yüzen "Servis 🛠️" Butonu (Ekran Görüntüsü 2):**
   - Keşfet haritasının sağ alt köşesinde sarı/amber kenarlıklı, gölgeli beyaz hap buton (`_buildServiceFloatingButton`) konumlandırıldı.
   - Dokunulduğunda "Mobil Servis" ekranı açılır; kategori seçildiğinde haritada filtrelenir ve servise odaklanılır.
2. **"Mobil Servis" Ana Hub Ekranı (Ekran Görüntüsü 1):**
   - `MobileServiceHubScreen`: Üst bar "Mobil Servis", başlık *"Hangi hizmete ihtiyacın var?"* ve açıklama.
   - 3 kolonlu ızgarada 10 ana hizmet kategorisi:
     1. 🚛 **Çekici / Yol Yardım**
     2. 🚐 **Yıllık Bakım**
     3. 🔥 **Gaz Tesisatı**
     4. 🌡️ **Isıtma & Soğutma**
     5. ⚡ **Elektrik & Enerji**
     6. 🚿 **Su & Tesisat**
     7. 💧 **Nem & Gövde**
     8. 🛞 **Şasi & Fren**
     9. ⚙️ **Montaj & Parça**
     10. 🔍 **Muayene**
   - 2 kolon genişliğinde yeşil kesikli çerçeveli **"Servis veren firma mısınız? / Firmanızı ekleyin, inceleyip listeleyelim"** kayıt kartı.
3. **Servis Veren Firma Ekleme Formu (`_AddServiceFirmSheet`):**
   - Firma adı, 10 hizmetten seçim, telefon numarası (direkt arama için), çalışma saatleri (7/24, mesai saatleri çipleri), konum ve detay açıklama alanları.
   - `AppAuthGuard.requireAuth` korumalı (misafir için güvenlik kalkanı devrede).
   - Kalıcı olarak yerel ve uzaktan kaydedilir.
4. **Yer Detayında Doğrudan Arama ve Çalışma Saatleri:**
   - İletişim telefonu bulunan işletmelerde hem alt barda hem de detay sayfasında yeşil **"Hemen Ara: [Telefon]"** butonu (`launchUrl('tel:...')`).
   - "Çalışma Saatleri: 7/24 Açık" bilgi rozeti.
5. **Türkiye Geneli Örnek Doğrulanmış Servisler:**
   - Antalya, Muğla, Bolu, İzmir, Kapadokya ve Ankara hatlarında gerçekçi başlangıç servis kayıtları (`SampleMobileServices`).
6. **Test ve Doğrulama:**
   - `test/guest_restriction_test.dart` içine yeni model ve ekran testleri eklendi.
   - `flutter analyze` 0 hata / 0 uyarı.
   - `flutter test` 162/162 test (%100) başarıyla geçti.

---



## Yapılan İyileştirmeler (6 Madde):
1. **Değerlendirme Düzeltme ve Silme:**
   - Daha önce değerlendirilmiş yerlerde buton "Değerlendirmeyi Düzenle" (`Icons.edit_note_rounded`) olarak görünür.
   - Değerlendirme modalında mevcut puan, yorum ve tavsiye nedenleri yüklenir, kaydet butonu "Değerlendirmeyi Güncelle" olur.
   - Modal içerisine "Değerlendirmeyi Sil" seçeneği ve `UserReviewsController.deleteReview` fonksiyonu eklendi.
2. **Fotoğraf Ekleme & Yanlış Yükleme Durumunda Silme:**
   - `CommunityPlacePhotosController.removePhoto(photoId)` eklendi.
   - Fotoğraf ekleme modalında (`_openAddPhotoModal`) o yere yüklenmiş topluluk fotoğrafları listelenir ve yanlış yüklenen fotoğraf tek dokunuşla silinebilir.
   - Tam ekran galeri dialogunda (`_PhotoGalleryDialog`) topluluk fotoğrafı görüntülenirken üst barda silme ikonu ve onay penceresi bulunur.
3. **Topluluk Katkısı — Olanak Durumu Düzeltme:**
   - Olanak durumu güncelleme modalında (`_openFacilityConditionDialog`) gerçeği yansıtmayan veya hatalı işaretlenmiş durumlar için açıkça "Yanlış / Hatalı Bilgiyi Düzelt" (`Icons.edit_off_rounded`) seçeneği eklendi.
4. **Veri Kaynağı Kısımlarının Kaldırılması:**
   - Hakkında bölümündeki "Veri Kaynağı: OpenStreetMap / Supabase" ve "Kayıt Türü" kartları kaldırıldı; koordinatlar ve son güncelleme tek satırda birleştirildi.
   - Dış kaynak link çipleri (`aboutSourcesSection`) gizlendi.
5. **Fotoğraf Kaynaklarının / Atıflarının Silinmesi:**
   - Yer detay sayfasındaki harici fotoğraf kaynak / atıf liste elemanları (`Fotoğraf: ... / Pixabay / Commons` satırları) tamamen kaldırıldı.
6. **Profilde Instagram, Facebook, YouTube Hesapları:**
   - `UserSocialAccounts` modeli ve `UserSocialAccountsController` ile kalıcı sosyal medya hesap yönetimi oluşturuldu.
   - Profil sayfasında hem profil kartına hem de ayarlar menüsüne "Sosyal Medya Hesapları" modalı eklendi.
   - Herkese açık profilde (`PublicUserProfileScreen`) sosyal medya hesapları renkli ve doğrudan açılabilir rozetler olarak görüntülendi.
7. **Test ve Doğrulama:**
   - `test/guest_restriction_test.dart` içine silme ve sosyal medya testleri eklendi.
   - `flutter analyze` 0 hata / 0 uyarı.
   - `flutter test` 160/160 test (%100) başarılı.

---



## Tablet Uyum İyileştirmeleri (9/9 Adım Tamamlandı):
1. **Temel Ekran Sistemi:**
   - `AppBreakpoints` & `AppResponsiveContext`: `phone` (0–599 dp), `tabletPortrait` (600–839 dp), `tabletLandscape` (840+ dp, max 1440 dp).
   - `AppResponsiveScaffoldBody` ve `context.centerContent(maxWidth: ...)` ortak genişlik merkezleme mimarisi kuruldu.
   - Telefonlardaki 430 dp genişlik sınırı yalnızca telefonlarda (`0-599 dp`) korundu.
2. **Harita:**
   - Tablet dikey: Tam genişlik harita, alttan açılan responsive bilgi paneli.
   - Tablet yatay: Sol %68 harita alanı, Sağ %32 arama, filtreler, seçili yer kartı ve yakındaki yerler listesi (sidebar keşif paneli).
3. **Ana Sayfa:**
   - Tablet dikey: İki sütunlu öneriler ve yakınındaki yerler, taşmasız `AppPlaceHeroCard`.
   - Tablet yatay: Sol %55 "Bugün sana uygun" ve keşif kartları, Sağ %45 yakın yerler ve interaktif canlı harita.
4. **Yer Detay Sayfası:**
   - Tablet dikey: 420 dp genişletilmiş kapak fotoğrafı, merkezlenmiş düzenli bilgi blokları.
   - Tablet yatay: Sol %46 fotoğraf galerisi, kapak ve canlı hava durumu; Sağ %54 yer adı, imkanlar/olanaklar, güven durumu ve navigasyon/aksiyonlar.
   - Sabit alt gezinme/aksiyon çubuğu unbounded constraint hatası `heightFactor: 1.0` ile çözüldü.
5. **Profil ve Katkılar:**
   - Tablet dikey: Üstte profil kartı, altta katkılar, acil yardım ve ayarlar iki kolonlu düzen.
   - Tablet yatay: Sol %38 avatar, hesap kartı, acil durum ve ayarlar; Sağ %62 katkı kartları tablosu, onay durumları ve bildirimler.
6. **İyilik Harekâtı:**
   - Tablet dikey: 320 dp yüksekliğe genişleyen fitted Türkiye haritası, istatistikler ve iyilik tablosu iki kolon.
   - Tablet yatay: Sol %58 büyük dokunulabilir Türkiye haritası ve rehber; Sağ %42 "İyilik Ekle" aksiyonu, istatistikler, seçili il detay kartı ve iyilik sıralaması.
7. **Topluluk Sohbetleri:**
   - Tablet dikey: Merkezlenmiş kategori listesi, oda seçilince tam sayfa sohbet.
   - Tablet yatay: Telegram/Discord tarzı master-detail düzen (Sol 340 dp kategoriler/odalar, Sağ aktif sohbet penceresi doğrudan entegre).
8. **Yer Ekleme ve Formlar:**
   - Tablet dikey: Tek akışta 720 dp genişletilmiş form alanları ve merkezlenmiş buton.
   - Tablet yatay: Sol %54 form adımları ve alanları; Sağ %46 doğrudan açık harita konumu pini, fotoğraf galerisi, gönderim özeti ve "Kaydet" aksiyonu.
9. **Test ve Kalite Kontrolü:**
   - `test/tablet_responsiveness_test.dart` ile 6 kritik çözünürlük doğrulandı:
     - Telefon: 360 × 800
     - Büyük telefon: 430 × 932
     - Küçük tablet dikey: 600 × 960
     - iPad dikey: 834 × 1194
     - iPad yatay: 1194 × 834
     - Android tablet yatay: 1280 × 800
   - Sıfır overflow/taşma, açık ve koyu temalarda kusursuz render, tüm 157 test %100 başarılı.
10. **Mobil Odaklı Geliştirme ve Önizleme Sabitlemesi:**
   - Web/Masaüstü ortamında (`mediaQuery.size.width > 430`) uygulamanın yapay bir web sitesine yayılması engellendi; uygulama `430 px` genişliğinde, ortalanmış, şık gölgeli saf cep telefonu çerçevesine sabitlendi.
   - `MediaQuery` genişliği 430 px olarak alt ağaca aktarıldığından alt gezinme barı, kartlar ve tüm sayfalar bilgisayarda test edilirken de tam olarak cep telefonundaki yerleşiminde ve oranında görüntülenir.

---

# Önceki Görev — Obruk Temizliği, Profil Avatarı, Olanak Güncelleme, Mekâna Fotoğraf & Haritada İşletmeler

## Yapılan İyileştirmeler:
1. **Obruk Yer Eklerinin Temizlenmesi:**
   - OSM ve idari kaynaklardan sızan kentsel sokak, cadde, kümeevleri, mahalle/köy sınırları ve camiler (`Yukarı Obruk Kümeevleri Sokağı`, `Yukarı Obruk Camii`, `Yukarı Obruk - Özlüce mahalle sınırı` vb.) `isNonNatureCandidateName` algoritması ile elendi.
   - Gerçek karstik jeolojik obruklar (`Kızören Obruğu`, `Çıralı Obruğu`, `Meyil Obruğu`, `Obruk Gölü Tabiat Parkı`, `Cennet Cehennem Obrukları`) eksiksiz korundu.
2. **Profilde Kullanıcı Fotoğrafı / Avatar Ekleme:**
   - `UserProfileAvatarController` ile kalıcı (`user_custom_avatar_v1`) profil avatarı desteği eklendi.
   - Profil ekranındaki avatara kamera düzenleme rozeti eklendi; modal içerisinden hazır doğa avatarları, özel URL veya varsayılan baş harfe dönüş imkânı sunuldu.
3. **Olanakları Tıklayıp Güncelleme (Topluluk Katkısı):**
   - Yer detayındaki olanaklar kartı (`_FieldConditionsCard`) `ValueListenableBuilder` ve `CommunityFacilityUpdatesController` ile reaktif kılındı.
   - Su, tuvalet, otopark ve piknik/kamp olanaklarına dokunulduğunda yetkilendirme (`AppAuthGuard.requireAuth`) sonrası "Var", "Yok" veya "Bilmiyorum / Sıfırla" seçenekleri sunan modal açılır ve anında yerel/topluluk hafızasına kaydedilir.
4. **Mekâna Fotoğraf Ekleme:**
   - Fotoğraf galerisi başlığına compact "+ Ekle" butonu entegre edildi (dar ekranlarda overflow korumalı).
   - Kullanıcılar geçerli URL veya doğa önizleme kareleri seçerek fotoğraf katkısında bulunabilir (`CommunityPlacePhotosController`).
5. **Ekleyen İsmi & Kamuya Açık Sade Profil:**
   - Fotoğraf galerisinde topluluk fotoğraflarının altında `Fotoğraf: [Kullanıcı] ›` bağlantısı gösterildi.
   - Dokunulduğunda açılan `PublicUserProfileScreen`, kullanıcının yalnızca herkese açık katkılarını (fotoğraf galerisi ve eklediği mekanlar) listeler. Ayarlar, şifre, hesap silme veya profil düzenleme gibi özel alanlar kesinlikle gösterilmez.
6. **Haritada İşletmeler / Hizmetler Bölümü:**
   - Harita filtre çipleri arasına `🏪 İşletmeler` (`local_service`) eklendi.
   - Yer Ekleme (`AddPlaceScreen`) ekranına "İşletme / Hizmet" kategorisi (kaynakçı, fırın, oto tamir, hamam, çamaşırhane vb.) dahil edildi.
   - Yerel hizmetlerin harita marker rengi, ikonu ve taksonomi eşleşmeleri tamamlandı.
7. **Test ve Doğrulama:**
   - `test/guest_restriction_test.dart` (13/13) ve tüm proje testleri (141/141) başarıyla geçti.
   - `flutter analyze` 0 hata ile doğrulandı.

---

## Önceki Görev — Haritada Seçili Yer Vurgusu & "Haritada Göster" Butonu

## Önceki Görev — Misafir Kullanıcı Yetkilendirme ve Kısıtlama Sistemi (Guest Mode Security Wall)

## Misafir Kullanıcı Kısıtlama Sistemi Özeti
Misafir olarak uygulamaya giren kullanıcılar haritayı, keşfet ekranını, yer detaylarını, iyilik hareketini ve topluluk mesajlarını sadece okuma/izleme modunda kullanabilir. Veri müdahalesinde (yer ekleme, yorum/puanlama, iyilik ekleme, mesaj gönderme, acil yardım açma/kabul etme) bulunamazlar; dokunduklarında şık cam tasarımlı `_GuestAuthWallSheet` modalı ile karşılanırlar.

### Tamamlanan Adımlar:
1. [x] **Merkezi Yetkilendirme Kalkanı (`AppAuthGuard` & `_GuestAuthWallSheet`):**
   - `AppAuthGuard.isAuthenticated`, `isGuest`, `requireAuth(...)` ve test desteği için `debugOverrideAuthenticated`.
   - `_GuestAuthWallSheet` cam tasarımlı alt modal ve çok dilli metinler eklendi.
2. [x] **Katkı Noktalarının Kilitlenmesi:**
   - Ana gezinme `+` (Yer Ekle) ve `AddPlaceScreen.savePlace()` korundu.
   - Yer Detay yorum/puanlama modalı (`openReviewRecommendSheet`) korundu.
   - İyilik Harekâtı iyilik ekleme akışı (`_openAddDeed`) korundu.
3. [x] **İletişim ve Acil Yardım Koruması:**
   - Topluluk Sohbetinde misafire kilitli mesaj uyarısı ve gönderim engeli (`addPreviewMessage`).
   - Acil Yardım çağrısı oluşturma ve çağrı kabul etme (`acceptRequest`) korundu.
4. [x] **Profil Ekranı Misafir Adaptasyonu:**
   - Profil kartında "Doğa Kaşifi (Misafir)" gösterimi ve hızlı giriş butonu.
   - Çıkış/Hesap Silme yerine "Giriş Yap / Kayıt Ol" aksiyonu.
5. [x] **Doğrulama ve Testler:**
   - `test/guest_restriction_test.dart` (4/4 geçti).
   - `test/widget_test.dart` ve projedeki tüm testler (130/130 geçti).
   - `flutter analyze` (0 issue).

---

## Önceki Görevler (Referans)
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
- [x] `search_map.dart` `_MapClusterMarker` (36px) ve `goodness_movement.dart` il rozetleri (44px) görsel tasarımları bozulmadan 48px (`AppControlSizes.minimumTouchTarget`) dokunma alanına genişletildi
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

**Plan Durumu:** ✅ **Doğadayım Premium Tasarım Sistemi, UX & Güvenlik Master Planı (Faz 1 – 7) %100 TAMAMLANDI! 🎉**  
- **Faz 1 (Güvenlik & RLS):** Yardım çağrısı ~300m koordinat fuzzing, gizli telefon/iletişim koruması, 112 banner'ı, bildirim okundu RPC'si, oturum kapatmada yerel veri temizliği.
- **Faz 2 (Renkler & İkonlar):** `AppColors.communityWarm` (sıcak kehribar/altın) token'ı, taksonomiye `IconData` standardı, emoji yerine tutarlı `IconData` çizgi ikonları.
- **Faz 3 (Harita Ekranı):** Baskın kategori ikonu + sayı gösteren harita kümeleri (`🌲 12`), seçili pin için hale efekti, boşluğa dokununca alt kartı kapatma.
- **Faz 4 (Ana Sayfa & Kartlar):** Konum başlığı `Bulunduğu alan`, fotoğraf ağırlıklı öneri algoritması, topluluk önerileri bölümü, temiz placeholder yapısı.
- **Faz 5 (İyilik Harekâtı):** "Örnek veri" etiketlerinin temizliği, "İyilik Ekle" butonu, kutlama SnackBar'ı, il haritası rozet iyileştirmesi.
- **Faz 6 (Topluluk & Profil):** Topluluk kartlarında "Aktif" rozeti, boş sohbet yönlendirici soruları, profilde maskeli e-posta (`j***@domain.com`), sakin/kırmızı acil durum kartı.
- **Faz 7 (Onboarding & Kalite):** Onboarding 3 adıma indirgendi, ilk slayttan itibaren "Misafir olarak keşfet" butonu, alt navigasyon güvenli boşlukları doğrulandı.

**Son Test Doğrulaması:**
- `flutter analyze` → 0 issues found!
- `flutter test` → **126/126 test geçti!** (%100 Başarı)

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
