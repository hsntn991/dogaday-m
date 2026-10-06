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
          '• Favoriler, değerlendirmeler, yardım talebi tercihleri ve uygulama içindeki kullanıcı tercihleri\n'
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
      "Doğadayım; hesap, veri ve dosya saklama için Supabase; harita ve coğrafi arama için OpenStreetMap, Nominatim ve Overpass; hava bilgisi için Open-Meteo; bazı örnek görseller için Unsplash hizmetlerinden yararlanabilir. Bu servisler, ilgili özelliği sunmak için gerekli teknik istekleri ve IP adresi gibi bağlantı verilerini kendi gizlilik politikalarına göre işleyebilir."
    ),
    (
      '6. Verilerin Güvenliği',
      'Kullanıcı bilgilerinin yetkisiz erişime, değiştirmeye veya açıklanmaya karşı korunması için makul teknik ve organizasyonel önlemler uygulanır.'
    ),
    (
      '7. Veri Saklama ve Silme',
      'Kişisel bilgiler yalnızca uygulamanın çalışması ve ilgili hizmetlerin sunulması için gerekli olduğu sürece veya yasal yükümlülüklerin gerektirdiği süre boyunca saklanır.\n\n'
          'Kullanıcılar hesaplarının ve hesaplarıyla ilişkili kişisel verilerin silinmesini uygulama içindeki Profil bölümünden başlatabilir. Uygulamaya erişemeyen kullanıcılar, hesap silme sayfasından silme talebi gönderebilir: dogadayim.github.io/dogadayim-privacy/delete-account.html'
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
    return _LegalDocumentScreen(
      title: 'Gizlilik Politikası',
      updatedAt: '7 Eylül 2026',
      introduction:
          "Doğadayım, kullanıcıların Türkiye'deki doğal alanları, su kaynaklarını, kamp alanlarını, yürüyüş rotalarını ve diğer doğa noktalarını keşfetmelerine yardımcı olmak amacıyla geliştirilen bir mobil uygulamadır.",
      sections: sections,
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const sections = <(String, String)>[
    (
      '1. Hizmetin kullanımı',
      'Doğadayım; doğal alanları, yürüyüş rotalarını, kamp alanlarını ve ilgili saha bilgilerini keşfetmeyi kolaylaştırır. Uygulamadaki bilgiler değişebilir; hava durumu, yol, su kaynağı, erişim ve güvenlik koşullarını ziyaret öncesinde resmî kaynaklardan ve yerel yetkililerden ayrıca doğrulamanız gerekir.',
    ),
    (
      '2. Güvenli doğa etkinliği',
      'Kendi güvenliğinizden siz sorumlusunuz. Hava koşulları, yangın yasakları, özel mülkiyet, korunan alan kuralları ve yerel talimatlara uyun. Tehlike veya acil durumlarda Doğadayım yerine bulunduğunuz bölgedeki yetkili acil yardım numarasını arayın.',
    ),
    (
      '3. Kullanıcı katkıları',
      'Yer, fotoğraf, açıklama, değerlendirme veya başka içerik gönderdiğinizde; içeriğin doğru, hukuka uygun, başkalarının haklarına saygılı ve paylaşmaya yetkili olduğunu kabul edersiniz. Başkalarının kişisel verisini, hassas konumunu, telif hakkıyla korunan içeriğini veya zararlı/yanıltıcı içerikleri izinsiz paylaşmayın.\n\nDoğadayım; topluluk güvenliği, hukuki yükümlülükler ve hizmet kalitesi için kullanıcı katkılarını inceleyebilir, görünürlüğünü kısıtlayabilir veya kaldırabilir.',
    ),
    (
      '4. Yasak davranışlar',
      '• Yanlış acil yardım çağrısı oluşturmak veya başkalarını yanıltmak\n'
          '• Tehdit, taciz, nefret söylemi ya da uygunsuz içerik paylaşmak\n'
          '• Sistemin güvenliğini aşmaya, hesaplara yetkisiz erişmeye veya hizmeti aksatmaya çalışmak\n'
          '• Başkalarının gizliliğini ihlal eden konum, iletişim bilgisi veya görsel paylaşmak',
    ),
    (
      '5. Hesap ve veri silme',
      'Hesabınızı uygulama içindeki Profil bölümünden silebilirsiniz. Uygulamaya erişemiyorsanız hesap silme sayfasından talep oluşturabilirsiniz. Ayrıntılar için Gizlilik Politikası’nı inceleyin.',
    ),
    (
      '6. Koşulların güncellenmesi',
      'Bu koşullar, uygulamanın özellikleri veya hukuki gereklilikler değiştiğinde güncellenebilir. Güncel metin bu sayfada yayımlanır.',
    ),
    (
      '7. İletişim',
      'Sorularınız ve bildirimleriniz için dogadayim.destek@gmail.com adresine ulaşabilirsiniz.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _LegalDocumentScreen(
      title: 'Kullanım Koşulları',
      updatedAt: '2 Ekim 2026',
      introduction:
          'Doğadayım, doğa noktalarını keşfetmeye yardımcı olur; resmî acil yardım, arama-kurtarma, sağlık veya navigasyon hizmeti değildir.',
      sections: sections,
    );
  }
}

class _LegalDocumentScreen extends StatelessWidget {
  const _LegalDocumentScreen({
    required this.title,
    required this.updatedAt,
    required this.introduction,
    required this.sections,
  });

  final String title;
  final String updatedAt;
  final String introduction;
  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                    Text(
                      'Doğadayım',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Son güncelleme: $updatedAt'),
                    const SizedBox(height: 24),
                    Text(
                      introduction,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                    for (final section in sections) ...[
                      const SizedBox(height: 28),
                      Semantics(
                        header: true,
                        child: Text(
                          section.$1,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        section.$2,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                      ),
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
