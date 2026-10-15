---
name: dogadayim-design-system
description: Doğadayım Flutter uygulamasında premium, doğa odaklı ve erişilebilir mobil arayüzler tasarlamak veya gözden geçirmek için kullanılır. Supabase, harita ve ürün davranışını değiştirmeden tema ve ortak bileşenleri uygular.
---

# Doğadayım tasarım sistemi

Doğadayım; doğa noktalarını keşfetmeye odaklanan, beyaz yüzeyli ve koyu orman yeşili vurgulu bir Flutter mobil uygulamasıdır. Amaç varsayılan Material görünümü değil; sakin, güvenilir, okunaklı ve gerçek cihazda doğal hissettiren bir ürün deneyimidir.

## Başlamadan önce

1. Önce ilgili ekranı, `lib/src/core/app_core.dart`, `lib/src/app/app.dart` ve `lib/src/widgets/design_system_widgets.dart` içindeki mevcut yapıyı incele.
2. Var olan ortak bileşeni genişletmek mümkünse yeni benzer widget oluşturma.
3. Veri kaynağı, Supabase şeması/RLS, önbellek, konum izinleri, harita davranışı, filtreleme veya navigasyon yalnızca kullanıcı açıkça isterse değiştirilir.
4. Kapsamı ekranla sınırlı tut; tasarım isteği tüm uygulamayı yeniden yazma izni değildir.

## Marka ve görsel kimlik

- Arka plan ve temel yüzeyler beyazdır: `AppColors.background` / `surface` (`#FFFFFF`).
- Birincil vurgu koyu orman yeşilidir: `AppColors.primary` (`#173F32`).
- İkincil yüzey `surfaceMuted` (`#F5F6F4`), ayırıcı `border` (`#E5E7E5`), ana metin `textPrimary` (`#202420`), ikincil metin `textSecondary` (`#747A75`) kullanılır.
- Koyu modda yalnızca tema-duyarlı yardımcıları (`surfaceOf`, `textPrimaryOf`, `borderOf` vb.) kullan; açık mod sabitlerini kopyalama.
- Varsayılan Material mavisini görünür yüzeylere, odaklara veya seçili durumlara sızdırma. İstisna yalnızca resmi marka öğeleridir (ör. Google logosu).
- `Fraunces` yalnız marka/karakter gereken sınırlı alanlarda; `Outfit` arayüz metinlerinde kullanılır. Yeni metin stillerini `AppTypography` üzerinden türet.
- Gereksiz cam efekti, degrade, gölge ve iç içe kart ekleme. Gölge sadece gerçekten yükseltilmiş harita kontrolü, panel veya modalda hafifçe kullanılır.

## Token ve bileşen kullanımı

- Renk için `AppColors`, tipografi için `AppTypography`/`AppFontSizes`, boşluk için `AppSpacing`, köşeler için `AppRadii`, ikon boyutları için `AppIconSizes`, dokunma ölçüleri için `AppControlSizes`, çizgiler için `AppBorders` kullan.
- Tekrarlanan ham `Color`, `TextStyle`, boşluk, radius veya border değerini ekran içine yayma. Yeni tekrar eden değer gerekirse önce uygun merkezi token var mı kontrol et.
- Kart ve giriş alanlarında çoğunlukla `AppRadii.small` (8) veya `medium` (12); sürüklenebilir alt panel ve büyük sheetlerde `hero` (20) kullan. Her şeyi pill veya büyük yuvarlak kart yapma.
- Bölümleri `AppSectionDivider` ile 1 px ayır. Uzun listelerde kalın çerçeve yerine ayırıcıyı tercih et.
- Birincil eylem için `AppPrimaryButton`, ikincil eylem için `AppSecondaryButton`, metin eylemi için `AppTextButton`; arama için `AppSearchField`, kategori için `AppCategoryChip` kullan.
- Yer görselleri, listeler ve rozetlerde sırasıyla `AppPlaceThumbnail`, `AppPlaceHeroCard`/`AppCompactPlaceCard`, `AppPlaceTrustBadge` veya `AppPlaceTrustSummary` kullan.
- Veri beklerken `AppLoadingCard`; boşluk, bağlantı, konum veya filtre hatasında açıklayıcı `AppFeedbackCard` ve yalnız gerçek bir yeniden deneme eylemi kullan.

## Mobil deneyim ve erişilebilirlik

- 320, 375 ve 430 px genişliklerde taşma, kırpılma ve yatay kaydırma kontrolü yap. Geniş ekran iyileştirmesi telefonu telefon çerçevesine sıkıştırmamalıdır.
- Etkileşimli öğeler en az `AppControlSizes.minimumTouchTarget` (48) yüksekliğe veya eşdeğer erişilebilir dokunma alanına sahip olmalı; komşu hedeflerde en az 8 px boşluk bırak.
- Güvenli alan, klavye `viewInsets`, sabit alt navigasyon/CTA ve büyük metin ölçeklerinde içeriğin gizlenmediğini kontrol et.
- İkonlar Material/SVG vektör olmalı; emoji yapısal ikon değildir. Yalnız ikonlu kontrolün tooltip'i ve anlamlı semantik etiketi olmalıdır.
- Kontrast yalnız renk ile anlam taşımamalı; seçili, hata ve devre dışı durumlarda metin/ikon veya semantik durum da bulunmalıdır.
- Basma geri bildirimi ölçülü olmalı. `AppPressable` ve tema kontrollerinin mevcut geri bildirimini koru; `MediaQuery.disableAnimationsOf(context)` açıkken hareketi azalt.

## Harita, konum ve doğa içeriği

- Harita pinleri, kümeler, seçili nokta ve harita paneli aynı yeşil/açık yüzey dilini izler; marker ve liste arasında seçili durum tutarlı kalır.
- Harita yüklenirken veya konum bulunamazken açık bir durum göster; sahte şehir, uzaklık veya başarı bilgisi üretme.
- Yer fotoğrafının yükleme/boş/hata hali alanı korumalı ve ürün diliyle uyumlu olmalıdır.
- Çeşme ve dolum noktaları yararlı kategorilerdir ama ana sayfadaki şelale, pınar, dere, göl, piknik alanı ve diğer gerçek doğa noktalarını baskılamamalıdır.
- Veri kaynağı, doğrulama ve mesafe yalnız doğrulanabilir veri varsa gösterilir.

## Yer Ekle örnek denetimi

Bu ekran, kuralların küçük kapsamda uygulanması için referanstır. Konum kartı, harita, koordinat girişi ve fotoğraf eylemlerinde:

- Açık/koyu yüzey ve kenarlıklar tema token'larından gelir.
- Konum yeniden seçilebilir; koordinat girişi klavye açıldığında kaydırılabilir kalır.
- Konum, fotoğraf ve gönderim eylemleri geniş dokunma alanı ve görünür etiket taşır.
- Seçilmemiş konum veya fotoğraf için hata/yardım metni, gerçek form durumunu anlatır; yalnız renge dayanmaz.
- Bu örneğin görsel iyileştirmesi başvuru verisini, harita koordinatını veya Supabase gönderim hattını değiştirmez.

## Teslim öncesi kontrol

1. İlgili widget veya ekranın açık ve koyu temada doğru token kullandığını kontrol et.
2. Telefon genişliklerinde, büyük metin ve klavye açıkken taşma olmadığını doğrula.
3. Yükleniyor, boş ve hata durumlarında kullanıcıya net sonraki adım verildiğini kontrol et.
4. Dokunma alanlarını, semantik etiketleri, sabit öğelerin güvenli alanını ve azaltılmış hareket tercihini denetle.
5. Değişen Flutter kodu için `flutter analyze` ve ilgili widget testlerini çalıştır; hata varsa nedenini açıkça raporla.
