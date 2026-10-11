# Ürün Kalitesi Planı

Bu plan, mevcut iş mantığını ve canlı veri akışını değiştirmeden uygulamanın
“premium üretim uygulaması” hissini kademeli olarak güçlendirmek içindir.

## Faz 0 — Güvenli başlangıç

- [x] Mevcut, commit edilmemiş çalışmaların envanterini al.
- [x] Önceki işlerin testlerini ve analizini tekrar doğrula.
- [x] Canlı sohbet için gereken Realtime geçişini, yalnızca önizleme sonrası canlıya uygula.

## Faz 1 — Kullanıcı geri bildirimi (ilk paket)

- [x] Ana sayfa veri yüklerken yerleşimi koruyan hafif iskelet durumları ekle.
- [x] Ana sayfa, detay ve haritada anlaşılır boş/hata durumları ve görünür “tekrar dene” aksiyonu kullan.
- [x] Haritadaki “yakındaki yerleri aç” aksiyonunu kullanıcının konumuna odaklayarak doğrula.
- [x] Kırık/eksik fotoğraflar için tutarlı bir görsel yedek ekle.

## Faz 2 — Ortak tasarım sistemi

- [x] Birincil, ikincil, metin ve yükleme durumlu butonların tek bileşen ailesini tamamla.
- [x] Arama alanı, filtre çipleri ve bölüm ayırıcılarının renk/boşluk kurallarını ortak sabitlerden yönet.
- [x] Tipografi ve açık/koyu mod kontrastını, özellikle ikincil metinler ve ayırıcılar için denetle.

## Faz 3 — Akış ve etkileşim cilası

- [x] Favori, filtre ve kart etkileşimlerine ölçülü geri bildirim ekle.
- [x] Giriş/kayıt akışında tüm metinleri seçilen dile bağla; hata ve alan doğrulamalarını yerinde göster.
- [x] Konum izni, harita yüklenememesi ve çevrimdışı durumları için güvenli geri dönüş ekranlarını tamamla.

## Faz 4 — Yayın kalitesi doğrulaması

- [x] 320, 375 ve 430 px; portre/yatay ekranları kontrol et.
- [x] Açık/koyu mod, büyük yazı ve erişilebilir dokunma alanlarını kontrol et.
- [x] İlgili widget testleri, tam test paketi ve statik analizi çalıştır.

Her davranış değişikliği, önce başarısız olan bir testle kanıtlanacak; ardından
en küçük güvenli değişiklik uygulanacaktır.
