# Proje Bağlamı

**Doğada Gezi**, Android, iOS ve web için Flutter tabanlı doğa keşif uygulamasıdır.

## Teknolojiler

- Flutter/Dart; Fraunces ve Outfit yazı tipleri
- Supabase (`places` verisini okuma)
- OpenStreetMap / Overpass, Open-Meteo, cihaz konumu
- `SharedPreferences` ile kullanıcı yerleri; uygulama dizininde yerel fotoğraf saklama

## Ana özellikler

- Ana sayfa, arama, OSM harita, yer detayı, favoriler/profil ve yer ekleme akışı
- Konum ve hava durumuna göre kural tabanlı öneriler
- Kullanıcının eklediği yerler, fotoğrafları, duplicate kontrolü ve doğrulama durumu

## Tamamlanan mimari kararlar

- Yakın yerler local-first, cache ve arka plan yenileme yaklaşımıyla çalışır.
- Harita sekmesi lazy-load edilir.
- Yer kaynakları `osm`, `user`, `curated`; doğrulama durumları `verified`, `community`, `unverified` olarak modellenir.
- Kullanıcı fotoğrafları kalıcı yerel yola (webde veri URL'sine) kaydedilir; ortak `PlaceImage` bileşeniyle gösterilir.

## Güncel tamamlanan işler

- Supabase kimlik doğrulama, kullanıcı başvuru kuyruğu, fotoğraf yükleme ve rol korumalı yönetici moderasyonu bulunur.
- Silinen, reddedilen veya onaylanan başvuruların eski local kopyaları sunucu durumuyla uzlaştırılır.
- Marmara zenginleştirmesi `about_text`, `about_sources`, `app_amenities` ve açık lisanslı fotoğraflarla yer detayına bağlanır.
- Pixabay otomatik seçimi A/B kimlik; kapakta Q1, galeride Q1/Q2 koşuluna bağlıdır.

## Devam/Bekleyen

- Gerçek cihaz uçtan uca testleri, yönetici MFA, canlı RLS smoke testi ve 81-il zenginleştirme yayılımı bekliyor.
- Sunucu tabanlı yorum/favori sistemi henüz tamamlanmış değildir.
