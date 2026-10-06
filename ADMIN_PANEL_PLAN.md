# Doğadayım Yönetici Paneli

## İlk sürüm

- [x] Supabase Auth ile yönetici girişi
- [x] Bekleyen, düzeltme bekleyen, onaylanan ve reddedilen başvuru listeleri
- [x] Başvuru detayında fotoğraf, koordinat, kategori, açıklama ve duplicate kontrolü
- [x] Onayla, reddet ve düzeltme iste işlemleri
- [x] Her moderasyon işlemi için değiştirilemeyen işlem geçmişi
- [x] Fotoğraf katkıları moderasyonu (ayrı sekme)
- [x] Dashboard istatistikleri (statü bazlı başvuru sayıları)

## Güvenlik

- [x] Mobil/web istemcilerde service-role anahtarı bulunmayacak.
- [x] Normal kullanıcı yalnızca kendi başvurularını okuyabilecek.
- [x] Yönetici ve moderatör rolü veritabanı RLS politikalarıyla doğrulanacak.
- [x] Herkese açık `places` sorgusu yalnızca aktif ve onaylı kayıtları okuyacak.
- [x] Başvuru fotoğrafları özel Storage bucket içinde tutulacak.

## Uygulama sırası

1. [x] Moderasyon migration dosyasını Supabase'e uygula.
2. [x] İlk gerçek Supabase Auth kullanıcısını oluştur.
3. [x] Bu kullanıcıya `admin` rolü ver.
4. [x] Flutter girişini gerçek Supabase Auth ile bağla.
5. [x] Yer Ekle formunu `place_submissions` ve özel fotoğraf bucket'ına bağla.
6. [x] İlk başvuruyu Supabase Dashboard üzerinden onayla.
7. [ ] Ayrı web yönetici arayüzünü oluştur (Flutter web olarak mevcut; bağımsız web arayüzü isteğe bağlı).

