# Play Store Yayına Hazırlık Planı

## Hedef

Doğadayım'ı önce güvenli bir internal teste, ardından kapalı Play Store testine
göndermek; politika, veri gizliliği ve gerçek cihaz doğrulaması eksiklerini
tamamlamak.

## Aşama 1 — Kullanıcı içeriği güvenliği

- [x] Sohbet mimarisini doğrula: mevcut sohbet, başka kullanıcılara açık olmayan cihaz-içi önizlemedir; canlı sohbet moderasyonu bu sürüm için gerekli değildir.
- [x] Kullanıcının gönderdiği yer/fotoğraf katkıları için mevcut moderasyon akışını doğrula: başvurular yönetim panelinde gönderen bilgisiyle inceleniyor; onay, ret ve düzeltme istenebiliyor.
- [x] Yer/fotoğraf oluşturulmadan önce kullanım koşulu kabulünün kullanıcı metaverisinde tarih ve sürümle kalıcı olarak kaydedilmesini sağla.
- [ ] Birim ve widget testleriyle misafir, engellenen kullanıcı ve şikâyet senaryolarını doğrula.

## Aşama 2 — Gizlilik ve hesap silme

- [x] Hesap silme talebi için ayrı, herkese açık web sayfası oluşturuldu ve erişimi doğrulandı.
- [x] Kullanım Koşulları sayfası canlıya alındı ve uygulamadaki bağlantıyla eşleşti.
- [x] Uygulama içindeki hesap silme akışının Supabase silme işlevine bağlı olduğu doğrulandı.
- [x] Gizlilik politikasını gerçek veri akışlarına göre güncelle: Supabase, konum,
  kullanıcı içeriği, sohbet, acil yardım, harita/hava/görsel servisleri.
- [x] Acil yardım ekranının 112'ye yönlendiren güvenlik açıklamasını doğrula.

## Aşama 3 — Yayın güvenliği ve teknik bakım

- [x] İmzalama anahtarını/parolasını güvenli biçimde yenile; eski anahtarı yedekle ve yeni anahtarı yerel release yapılandırmasına bağla.
- [ ] Gradle, Android Gradle Plugin ve Kotlin'i desteklenen sürümlere taşı. (Flutter Gradle eklentisiyle uyumluluk doğrulanarak ayrı yapılacak.)
- [ ] Hata izleme ve kullanıcı geri bildirim kanalını yayın öncesi kullanılabilir hâle getir.
- [x] Sürüm numarasını 1.0.1 / build 2 yap.
- [x] Yeni imzalama anahtarıyla Android App Bundle üretimini doğrula (63,3 MB).
- [x] Yayın adayı için `flutter analyze` ve tam otomatik test paketini çalıştır (178 test geçti).

## Aşama 4 — İçerik ve gerçek cihaz kalite testi

- [ ] İlk test sürümünde güvenilir içerik yoğunluğu olan pilot illeri belirle.
- [ ] Düşük kaliteli, yinelenen veya yanıltıcı yer kayıtlarını yayın akışından ayır.
- [ ] En az iki gerçek Android cihazda giriş, konum, harita, fotoğraf, sohbet,
  acil yardım ve hesap silme akışlarını dene.
- [ ] Play Console pre-launch raporunu incele ve bulguları kapat.

## Aşama 5 — Play Console teslimi

- [ ] Mağaza adı, kısa/açıklayıcı metin, ekran görüntüleri, 512×512 ikon ve
  1024×500 tanıtım görselini hazırla.
- [ ] Gizlilik URL'si, Data Safety, reklam, içerik derecelendirmesi, hedef kitle
  ve uygulama erişim bilgilerini doldur.
- [ ] Internal test grubuna yükle.
- [ ] Kapalı test için en az 12 katılımcıyı 14 gün boyunca aktif tut.

## Çıkış ölçütü

Kapalı teste geçiş ancak Aşama 1–3 tamamlandığında; üretime geçiş ise Aşama 4–5
tamamlandığında yapılır.
