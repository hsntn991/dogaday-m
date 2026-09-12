# Doğadayım — Fazlar ve Checklist

## Faz 0 — Proje ve Git

- [x] Kalıcı proje hafızası
- [x] Başlama ve gün sonu tetikleyicileri
- [x] GitHub deposunu bağla ve ilk push'u doğrula
- [x] Model geçiş ve token tasarrufu notları
- [ ] Secret ve `.gitignore` kontrolünü her sürümde uygula

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
- [ ] Gerçek cihaz performans ölçümü

## Faz 2 — Veri kalitesi ve yer ekleme

- [x] Alan/içerik doğrulaması ve duplicate kontrolü
- [x] Kalıcı fotoğraf ve çift-submit önlemi
- [x] Source/verification modeli
- [x] Yönetici onay akışı
- [x] Silinen/reddedilen local başvuru uzlaştırması
- [ ] Fotoğraf gönderimini gerçek cihazda uçtan uca doğrula

## Faz 3 — Araştırma zenginleştirmesi

- [x] `about_text`, `about_sources`, `app_amenities`
- [x] `not_found` semantiği ve medya önceliği
- [x] Pixabay A/B–Q1/Q2 filtresi
- [x] Çeşme (`water_fountain`) utility taksonomisi ve harita filtresi
- [x] Konya çeşme kayıtlarının gerçek Supabase tablo/görünümünü doğrula
- [x] Konya KOSKİ çeşmelerini `water_fountain` utility türüyle yayınla ve public API erişimini doğrula
- [ ] 81 il için kompakt veri üretimi
- [ ] Gerçek Pixabay sonuçlarını kontrollü içe aktar

## Faz 4 — Güvenlik ve üretim

- [x] Admin rol kontrolü ve temel RLS
- [x] Başvuru hız sınırı ve güvenli RPC
- [ ] Yönetici MFA
- [ ] Canlı RLS/RPC güvenlik testi
- [ ] Secret/release yapılandırması denetimi
- [ ] Hata izleme, yedekleme ve kötüye kullanım planı

## Faz 5 — Yayınlama

- [ ] Android kabul testi
- [ ] iOS kabul testi
- [ ] Web responsive ve erişilebilirlik testi
- [ ] Gizlilik, şartlar ve lisans atıfları
- [ ] Test dağıtımı ve sürüm checklist'i
