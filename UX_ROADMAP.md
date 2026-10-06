# Doğadayım — UX İyileştirme Yol Haritası

Bu plan, uygulamanın temel vaadini güçlendirir: Kullanıcıya yalnızca bir yerin
nerede olduğunu değil, oraya gitmeye değip değmeyeceğini ve sahada neyle
karşılaşacağını söyler.

## Sürüm 1 — İlk 30 Saniye: Keşfe Başlama

- [x] Konum iznini ilk açılışta zorunlu isteme; yalnızca bağlam içinde iste.
- [x] Ana sayfadaki ana hiyerarşiyi “Bugün nereye gidebilirim?” kararına göre kur.
  Öneri kartları artık gerçek öneri nedenini ve uygunluk durumunu gösteriyor.
- [x] Öneri kartlarında gerçek fotoğraf, mesafe ve güven bilgisini öncele;
  doğrulanmış/topluluk kaynaklarını kart üzerinde açıkça ayır.
- [x] İlk kullanıcı akışındaki yer ekleme, arama ve ana sayfa kategori simgelerini
  emoji yerine vektör ikonlarla değiştir.

Başarı ölçütü: Kullanıcı konum izni vermeden de ilk iki öneriyi ve haritayı
görebilir; konum talebinin neden istendiğini anlar.

## Sürüm 2 — Harita: Keşfet ve Planla

- [x] Haritayı serbest gezinme ve seçili yer planlama durumlarıyla netleştir.
  Boş harita dokunuşu seçimi kapatıyor; seçili nokta kartı, ileri/geri geçişi
  ve tek ayrıntı aksiyonunu gösteriyor.
- [x] Küme işaretlerinde yalnızca sayıyı değil baskın kategori simgesini göster.
- [x] Seçili noktayı belirginleştir; kartta tek birincil aksiyon kullan.
- [x] Filtreleri yüksek seviye, anlaşılır doğa amaçlarıyla grupla.

Başarı ölçütü: Kullanıcı haritadaki işaretin neyi temsil ettiğini bir bakışta
anlar ve seçtiği noktada ne yapacağını bilir.

## Sürüm 3 — Yer Detayı ve Katkı

- [x] Yer detayının ilk ekranında neden gitmeli, erişim, tesisler, güncellik ve
  güven bilgisini özetle.
- [x] Yer eklemeyi kategori → ad/açıklama → konum → fotoğraf ve isteğe bağlı
  saha bilgisi sırasıyla sadeleştir; taslak desteğini görünür yap.
- [x] Saha güncellemelerini tarih ve doğrulama kaynağıyla göster.

Başarı ölçütü: Kullanıcı 10 saniye içinde “gidebilir miyim?” sorusuna cevap
alır; yeni yer ekleme yaklaşık bir dakikada tamamlanır.

## Sürüm 4 — Topluluk, İyilik ve Güven

- [x] Sohbeti gerçek zamanlı veri gelene kadar açıkça rehber/örnek olarak etiketle.
- [x] İyilik Harekâtı'nda başlangıç puanı ile cihazdaki, henüz doğrulanmamış
  katkıyı açıkça ayır.
- [x] Kullanıcı profilindeki katkı durumu, yardım ve bildirim alanlarını tek
  hiyerarşide tut.
- [x] Aktif değilken yardım iste kartını sakin, aktif çağrıda öncelikli göster.

Başarı ölçütü: Uygulama gerçek topluluk verisi ile örnek veriyi karıştırmaz;
kullanıcı katkısının etkisini görebilir.

## Sürüm 5 — Yayın Kalitesi

- [x] Açık/koyu tema kontrastı, ekran okuyucu ve küçük telefon testleri.
- [x] Telefon, tablet dikey/yatay ve web önizlemesinde tutarlı hiyerarşi.
- [x] Görsel performans: fotoğraf yükleme, boş durumlar ve harita hareketinde
  akıcılık için paylaşılan kartlar, sessiz görsel yedekleri ve tembel harita
  açılışıyla koruma.

Başarı ölçütü: Kritik akışlarda taşma, beyaz ekran ve belirsiz yüklenme durumu
olmaz.
