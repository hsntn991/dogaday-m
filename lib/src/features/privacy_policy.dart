part of '../../main.dart';

// Snapshot of the existing public policy dated 7 September 2026.
// Keep this text and the external policy in sync when the policy changes.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const sections = <(String, String)>[
    (
      '1. Toplanan Bilgiler',
      'Doğadayım, uygulamanın özelliklerini sunabilmek için aşağıdaki bilgileri işleyebilir:\n\n'
          '• Hesap ve oturum bilgileri\n'
          '• Kullanıcının izin vermesi halinde konum bilgisi\n'
          '• Kullanıcı tarafından uygulamaya eklenen yerler ve içerikler\n'
          '• Kullanıcı tarafından yüklenen fotoğraflar\n'
          '• Favoriler, değerlendirmeler ve uygulama içindeki kullanıcı tercihleri\n'
          '• Uygulamanın çalışması için gerekli teknik veriler'
    ),
    (
      '2. Konum Bilgisi',
      'Doğadayım, kullanıcının yakınındaki doğa noktalarını göstermek, harita özelliklerini sağlamak ve mesafe hesaplamak amacıyla cihazın konumuna erişim isteyebilir.\n\n'
          'Konum erişimi yalnızca kullanıcının izniyle sağlanır. Kullanıcı cihaz ayarlarından konum iznini istediği zaman değiştirebilir veya kaldırabilir. Doğadayım arka planda konum izni talep etmez.'
    ),
    (
      '3. Fotoğraflar ve Kullanıcı İçerikleri',
      "Kullanıcılar Doğadayım'a yeni yerler, açıklamalar ve fotoğraflar ekleyebilir. Kullanıcının gönderdiği içerikler, uygulamadaki diğer kullanıcılara ilgili doğa noktasını göstermek amacıyla kullanılabilir."
    ),
    (
      '4. Hesap Bilgileri',
      "Doğadayım'da kullanıcı hesabı oluşturulabilir ve desteklenen üçüncü taraf oturum açma yöntemleri kullanılabilir. Hesap bilgileri kimlik doğrulama ve uygulamanın kullanıcıya özel özelliklerini sunmak amacıyla işlenebilir."
    ),
    (
      '5. Üçüncü Taraf Hizmetler',
      "Doğadayım'ın çalışması için harita, kimlik doğrulama, veri saklama ve diğer teknik hizmetler sağlayan üçüncü taraf servislerden yararlanılabilir. Bu hizmetler kendi gizlilik politikalarına tabi olabilir."
    ),
    (
      '6. Verilerin Güvenliği',
      'Kullanıcı bilgilerinin yetkisiz erişime, değiştirmeye veya açıklanmaya karşı korunması için makul teknik ve organizasyonel önlemler uygulanır.'
    ),
    (
      '7. Veri Saklama ve Silme',
      'Kişisel bilgiler yalnızca uygulamanın çalışması ve ilgili hizmetlerin sunulması için gerekli olduğu sürece veya yasal yükümlülüklerin gerektirdiği süre boyunca saklanır.\n\n'
          'Kullanıcılar hesaplarının ve hesaplarıyla ilişkili kişisel verilerin silinmesini talep edebilir. Hesap silme özelliği ve ilgili başvuru yöntemleri Doğadayım üzerinden kullanıcılara sunulur.'
    ),
    (
      '8. Çocukların Gizliliği',
      'Doğadayım, çocukların kişisel bilgilerinin korunmasına önem verir. Uygulamanın kullanımı ve hedef yaş grubuyla ilgili gereklilikler, uygulanabilir mevzuat ve mağaza politikalarına uygun şekilde yönetilir.'
    ),
    (
      '9. Gizlilik Politikasındaki Değişiklikler',
      'Bu Gizlilik Politikası, uygulamadaki özelliklerin veya yasal gerekliliklerin değişmesi halinde güncellenebilir. Güncel sürüm her zaman bu sayfada yayımlanacaktır.'
    ),
    (
      '10. İletişim',
      'Gizlilik, kişisel veriler veya hesap silme talepleriyle ilgili bizimle iletişime geçebilirsiniz:\n\nE-posta: dogadayim.destek@gmail.com'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik Politikası')),
      body: SafeArea(
        child: SelectionArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Doğadayım',
                        style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Son güncelleme: 7 Eylül 2026'),
                    const SizedBox(height: 24),
                    Text(
                        "Doğadayım, kullanıcıların Türkiye'deki doğal alanları, su kaynaklarını, kamp alanlarını, yürüyüş rotalarını ve diğer doğa noktalarını keşfetmelerine yardımcı olmak amacıyla geliştirilen bir mobil uygulamadır.",
                        style:
                            theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
                    for (final section in sections) ...[
                      const SizedBox(height: 28),
                      Semantics(
                          header: true,
                          child: Text(section.$1,
                              style: theme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600))),
                      const SizedBox(height: 12),
                      Text(section.$2,
                          style:
                              theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
