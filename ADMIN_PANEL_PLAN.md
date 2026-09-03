# Doğadayım Yönetici Paneli

## İlk sürüm

- Supabase Auth ile yönetici girişi
- Bekleyen, düzeltme bekleyen, onaylanan ve reddedilen başvuru listeleri
- Başvuru detayında fotoğraf, koordinat, kategori, açıklama ve duplicate kontrolü
- Onayla, reddet ve düzeltme iste işlemleri
- Her moderasyon işlemi için değiştirilemeyen işlem geçmişi

## Güvenlik

- Mobil/web istemcilerde service-role anahtarı bulunmayacak.
- Normal kullanıcı yalnızca kendi başvurularını okuyabilecek.
- Yönetici ve moderatör rolü veritabanı RLS politikalarıyla doğrulanacak.
- Herkese açık `places` sorgusu yalnızca aktif ve onaylı kayıtları okuyacak.
- Başvuru fotoğrafları özel Storage bucket içinde tutulacak.

## Uygulama sırası

1. Moderasyon migration dosyasını Supabase'e uygula.
2. İlk gerçek Supabase Auth kullanıcısını oluştur.
3. Bu kullanıcıya `admin` rolü ver.
4. Flutter girişini gerçek Supabase Auth ile bağla.
5. Yer Ekle formunu `place_submissions` ve özel fotoğraf bucket'ına bağla.
6. İlk başvuruyu Supabase Dashboard üzerinden onayla.
7. Ayrı web yönetici arayüzünü oluştur.
