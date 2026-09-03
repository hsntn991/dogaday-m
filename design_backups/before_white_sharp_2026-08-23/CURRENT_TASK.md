# Güncel Çalışma Durumu

Onboarding akışı düzenleniyor:

- İlk kurulumda onboarding gösterilir; tamamlandıktan sonra `SharedPreferences` içinde saklanır.
- Sonraki uygulama açılışlarında onboarding yerine giriş ekranı açılır.
- Tanıtım ekranları kaydırılarak veya alt göstergelerine dokunularak seçilebilir.
- Giriş ekranında marka alt metni güncellendi; karşılama başlığı kaldırıldı.
- Supabase'den okunan koordinatlı yerler harita işaretçilerine ve harita aramasına dahil edildi; kategori şeridi fareyle de kaydırılabilir ve kullanıcı konumu haritada gösterilir.
- Yer detayında yol mesafesi ve araçla tahmini süre gerçek koordinatlardan rota servisiyle hesaplanır; sabit mesafe, süre, zorluk ve yükselti değerleri kaldırıldı.
- Detay ekranındaki Yakındaki Yerler sabit örneklerden değil, açılan yerin 25 km çevresindeki Supabase, kullanıcı ve OpenStreetMap kayıtlarından mesafeye göre oluşturulur.
- Ana sayfadaki Yakınımdaki Yerler kullanıcı konumuna; detaydaki Buraya Yakın Yerler açılan noktanın koordinatına göre ayrı ayrı yakından uzağa sıralanır.

Bir sonraki görev kullanıcı isteğiyle belirlenmelidir.
