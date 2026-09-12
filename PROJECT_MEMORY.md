# Doğadayım — Kalıcı Hafıza

Son güncelleme: 2026-09-03
Son doğrulanan commit: `3e252f4fc8590d04a7342c3e14da5f699994f121`

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

## Açık riskler

- Android/iOS gerçek cihaz konum, fotoğraf, çevrimdışı ve arka plan senaryoları uçtan uca test edilmelidir.
- Yönetici hesabına güçlü parola ve mümkünse MFA eklenmelidir.
- OSM public tile kullanımı üretim trafiği için ayrıca değerlendirilmelidir.
- Supabase RLS/RPC smoke testleri her migration sonrasında çalıştırılmalıdır.

## Komutlar

- `başlıyoruz`: hafıza, görev ve yol haritasını oku; Git'i kontrol et; sonra işe başla.
- `tamam bu kadar` / `bugünlük bu kadar`: doğrula, belgeleri güncelle, commit et ve push et.
