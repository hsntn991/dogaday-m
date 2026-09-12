# Çalışma Kuralları

- Minimum context ve minimum token kullan.
- Gereksiz dosya okuma veya proje genelinde tarama yapma.
- Yalnızca mevcut görev için gerekli dosyaları ve büyük dosyaların ilgili bölümlerini incele.
- Çalışan kodu gereksiz yere yeniden yazma; kullanıcı istemedikçe refactor yapma.
- Kullanıcı istemedikçe yeni paket ekleme.
- Mevcut Flutter mimarisini ve Supabase yapısını koru; Supabase tablo veya kolonlarını tahmin etme.
- Eksik bilgi varsa tahmin etmek yerine yalnızca gerekli bilgiyi iste.
- Hata çözümünde yalnızca ilgili bölgeye müdahale et.
- Gereksiz web araştırması ve araç kullanımı yapma.
- Aynı bilgiyi tekrar tekrar açıklama.
- Kullanıcının mevcut isteğini geçmiş konuşmalardan daha öncelikli kabul et.
- Kullanıcı özellikle sormadıkça agent bilgisini yanıtta belirtme. Varsayılan ana agent: `/root`.

## Model ve token dengesi

- Varsayılan çalışma modu: kredi tasarruflu, hedef odaklı, minimum değişiklik.
- Basit metin/UI düzeltmeleri, tek dosya hataları ve küçük kontroller için `gpt-5.6-luna` tercih edilebilir.
- Normal Flutter/Supabase geliştirme, birkaç dosyalı işler ve orta seviye hata çözümü için `gpt-5.6-terra` önerilir.
- Kritik güvenlik, veri modeli, RLS, performans, kapsamlı hata ayıklama veya riskli mimari kararlar için `gpt-5.6-sol` kullanılmalıdır.
- Büyük göreve başlamadan önce işi küçük fazlara böl; her fazda en düşük yeterli modeli kullan.
- Model yükseltme gerekiyorsa önce nedenini kısa bildir; gereksiz yere yüksek modele geçme.
- Token tasarrufu için önce hafıza dosyalarını ve dar hedef dosyaları oku; tüm proje taramasını son seçenek yap.

## Kalıcı proje takibi

- Her görevde yalnız gerektiğinde `PROJECT_MEMORY.md`, `CURRENT_TASK.md` ve `ROADMAP.md` dosyalarını güncelle.
- Kullanıcı `başlıyoruz` dediğinde önce `PROJECT_MEMORY.md`, `CURRENT_TASK.md`, `ROADMAP.md` ve gerekiyorsa `PROJECT_CONTEXT.md` dosyalarını oku; ardından Git çalışma ağacını, mevcut dalı ve son commit'i kontrol et.
- `başlıyoruz` sırasında mevcut görev için önerilen modeli kullanıcıya hatırlat.
- Hafızadaki son doğrulanan commit mevcut `HEAD` ile uyuşmuyorsa veya uzak depo ilerideyse önce farkı incele. Kullanıcıdan habersiz merge, rebase veya reset yapma.
- Kullanıcı `tamam bu kadar` veya `bugünlük bu kadar` dediğinde değişiklikleri doğrula, hafıza/checklist dosyalarını güncelle, yalnız güvenli proje dosyalarını commit et ve mevcut dala push et.
- Secret, API anahtarı, yerel ortam dosyası, build çıktısı ve kullanıcıya ait özel dosyaları commit etme.
- Zorla push yapma. Commit veya push başarısızsa nedeni açıkça bildir.
- Belirsiz ürün, veri modeli veya Git kararlarında tahmin yürütme; yalnız gerekli soruyu sor.
