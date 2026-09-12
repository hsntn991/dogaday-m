# Güncel Görev

## Amaç

Araştırma motoru verisini uygulamanın gerçek Supabase ve harita akışına güvenli biçimde bağlamak.

## Tamamlanan

- `PROJECT_MEMORY.md` ve `ROADMAP.md` oluşturuldu.
- `AGENTS.md` içine `başlıyoruz`, `tamam bu kadar` ve `bugünlük bu kadar` iş akışı eklendi.
- `.gitignore` build/cache/secret dosyalarına karşı güçlendirildi.
- GitHub hesabı ve özel `hsntn991/dogaday-m` deposu doğrulandı; depo boş.
- `AGENTS.md`, `PROJECT_MEMORY.md` ve `ROADMAP.md` içine model seçim rehberi eklendi.
- Token tasarrufu için basit/orta/kritik iş ayrımı kayda geçirildi.
- Uygulama `water_fountain`/Çeşme utility türünü, ayrı harita filtresini ve güvenli sınıflandırma migration'ını aldı.
- Konya'da 3.617 KOSKİ tarihî çeşme kaydı doğrulandı. Bunların hepsi koordinatlıydı ancak `spring`, doğrulanmamış ve yayın dışı durumda oldukları için haritadan gizleniyordu.
- 3.617 kayıt `water_fountain`, `verified` ve `publish` durumuna alındı. Anon/public API doğrulamasında tamamı uygulamanın okuyabildiği görüldü.

## Tamamlanan Git adımı

- Proje `main` dalında başlatıldı.
- Commit öncesi dosya, büyük dosya ve secret kontrolü yapıldı.
- İlk commit `d6eec40` olarak `origin/main` dalına gönderildi ve uzak commit ile eşleştiği doğrulandı.
- Hafıza/checklist commit'i `3e252f4` olarak `origin/main` dalına gönderildi.

## Sonraki görev

Uygulamayı yenileyerek Konya'daki Çeşme filtresinin 3.617 KOSKİ kaydını gösterdiğini görsel olarak doğrulamak; ardından araştırma motoru çıktılarından gelen yeni utility verileri için kontrollü içe aktarma akışını hazırlamak.

## Model hatırlatma

- Basit görev: `gpt-5.6-luna`
- Normal geliştirme: `gpt-5.6-terra`
- Kritik güvenlik/veri/performance: `gpt-5.6-sol`

## Son doğrulama

- 2026-09-05: Araştırma motorundan 61 yer için 146 fotoğraf bağlantısı `assets/data/research_photos.json` paketine aktarıldı. Yazar, lisans ve kaynak bilgileri korundu. Yer adı ve 750 metre konum eşleşmesiyle kart/kapak/galeriye bağlandı; detay ekranına atıf listesi eklendi. Eski fotoğraf listesi yerine bu seçilmiş paket kullanılıyor. Troas haritası ve gerekli doğrulama alanları olmayan kayıtlar aktarılmadı. Bu adım Supabase Storage'a ikili fotoğraf yüklemesi değildir; Commons bağlantıları uygulama paketine eklenmiştir.

- 2026-09-05: Çeşmelerin eski `Su Kaynağı` kategori adıyla görünmesi ortak Place modelinde düzeltildi. `water_fountain` türü kart etiketinde öncelikli; utility için ana kategori boş korunuyor. widget_test.dart içindeki 41 test geçti. Kullanıcının çalışan uygulamasına yeni derlemenin ulaştığı henüz doğrulanmadı.

- Yeni çeşme taksonomisi testi geçti.
- Tam test paketi 38 testi geçti; mevcut ortamda `rapid save taps create only one local place` testi Flutter SkSL gölgelendirici varlık hatasıyla başarısız oldu. Bu, çeşme değişikliğinden bağımsızdır.
