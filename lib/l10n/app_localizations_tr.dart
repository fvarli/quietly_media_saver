// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get brandName => 'Quietly';

  @override
  String get onboardingValueTitle =>
      'Herkese açık fotoğraf ve videoları galerinize kaydedin';

  @override
  String get onboardingValueBody =>
      'Bir bağlantı yapıştırın — Quietly herkese açık olduğunu kontrol eder ve kaydeder. Sakin ve gizli.';

  @override
  String get onboardingHowTitle => 'Nasıl çalışır';

  @override
  String get onboardingTrustTitle => 'Tasarımı gereği gizli';

  @override
  String get onboardingTrustBody =>
      'Quietly yalnızca herkese açık, izinli medyayı kaydeder. Kayıtlarınız ve ayarlarınız cihazınızda kalır.';

  @override
  String get onboardingContinue => 'Devam et';

  @override
  String get onboardingGetStarted => 'Başla';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get stepPasteShort => 'Yapıştır';

  @override
  String get stepPasteLabel => 'Bağlantı yapıştır';

  @override
  String get stepPasteDesc =>
      'Herkese açık bir medya bağlantısı kopyalayıp yapıştırın.';

  @override
  String get stepAnalyzeShort => 'Analiz';

  @override
  String get stepAnalyzeLabel => 'Medyayı analiz et';

  @override
  String get stepAnalyzeDesc =>
      'Quietly herkese açık ve okunabilir olduğunu kontrol eder.';

  @override
  String get stepSaveShort => 'Kaydet';

  @override
  String get stepSaveLabel => 'Galeriye kaydet';

  @override
  String get stepSaveDesc => 'Medya galerinize kaydedilir.';

  @override
  String get stepHistoryShort => 'Geçmiş';

  @override
  String get stepHistoryLabel => 'Geçmişi gör';

  @override
  String get stepHistoryDesc =>
      'Kaydettiğiniz her şeyi istediğiniz zaman bulun.';

  @override
  String get trustNoAds => 'Reklam yok';

  @override
  String get trustNoAccount => 'Hesap yok';

  @override
  String get trustNoTracking => 'Takip yok';

  @override
  String get trustRowSemantic => 'Reklam yok, hesap yok, takip yok';

  @override
  String get homeHeadline => 'Herkese açık medyayı galerinize kaydedin';

  @override
  String get homeSubtitle =>
      'Herkese açık bir bağlantı yapıştırın; Quietly kontrol edip fotoğrafı veya videoyu galerinize kaydeder.';

  @override
  String get homeClipboardLabel => 'PANONUZDAN';

  @override
  String homeClipboardSemantic(Object url) {
    return 'Panonuzdaki bağlantıyı kullan: $url';
  }

  @override
  String get homeRecentSaves => 'Son kayıtlar';

  @override
  String get homeSeeAll => 'Tümünü gör';

  @override
  String get homePasteCta => 'Bağlantı yapıştır';

  @override
  String get homeZeroState =>
      'Henüz kayıt yok — kayıtlarınız burada görünecek.';

  @override
  String get homeOffline => 'Çevrimdışısınız — kayıtlı medya yine çalışır.';

  @override
  String get homeHistoryTooltip => 'Geçmiş';

  @override
  String get homeSettingsTooltip => 'Ayarlar';

  @override
  String get rightsHome =>
      'Yalnızca hakkına sahip olduğunuz içerikleri kaydedin. Özel veya korumalı medya desteklenmez.';

  @override
  String get rightsSave =>
      'Kaydederek bu içeriği saklama hakkına sahip olduğunuzu onaylarsınız.';

  @override
  String get rightsStatement =>
      'Quietly yalnızca herkese açık medyayı kaydeder. Herhangi bir içeriği kaydetme ve kullanma hakkına sahip olduğunuzdan emin olmak sizin sorumluluğunuzdadır. Özel, yalnızca girişle erişilen ve DRM korumalı medya desteklenmez.';

  @override
  String get rightsRefusal =>
      'Quietly platform kurallarına ve içerik üreticilerinin haklarına saygı gösterir. Bazı medyalar kaydedilemez.';

  @override
  String get analyzingTitle => 'Bu bağlantı okunuyor';

  @override
  String get analyzingSubtitle =>
      'Kaydedebileceğiniz herkese açık medya aranıyor.';

  @override
  String get analyzingStep1 => 'Sayfaya ulaşılıyor';

  @override
  String get analyzingStep2 => 'Herkese açık olduğu kontrol ediliyor';

  @override
  String get analyzingStep3 => 'Mevcut medya listeleniyor';

  @override
  String get publicChip => 'Herkese açık';

  @override
  String get resultTitle => 'Mevcut medya';

  @override
  String get shareTooltip => 'Paylaş';

  @override
  String resultVideoSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Herkese açık gönderi · $count video',
      one: 'Herkese açık gönderi · 1 video',
    );
    return '$_temp0';
  }

  @override
  String resultImageSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Herkese açık gönderi · $count görsel',
      one: 'Herkese açık gönderi · 1 görsel',
    );
    return '$_temp0';
  }

  @override
  String get resultFormatVideo => 'Yatay · MP4';

  @override
  String get resultFormatImage => 'JPG';

  @override
  String resultSizeSuffix(Object size) {
    return ' · ≈ $size';
  }

  @override
  String get resultExplain =>
      'Bu medya herkese açık. Aşağıdan bir kalite seçin, sonra galerinize kaydedin.';

  @override
  String resultQualityRow(Object label, Object tag) {
    return '$label · $tag';
  }

  @override
  String resultQualitySub(Object size) {
    return '≈ $size · kaliteyi değiştirmek için dokunun';
  }

  @override
  String get resultSaveCta => 'Galeriye kaydet';

  @override
  String get previewVideo => 'Video önizleme';

  @override
  String get previewImage => 'Görsel önizleme';

  @override
  String get labelVideo => 'video';

  @override
  String get labelImage => 'görsel';

  @override
  String get carouselSelectAll => 'Tümünü seç';

  @override
  String get carouselClear => 'Temizle';

  @override
  String get carouselTag => 'Karusel';

  @override
  String carouselItemsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe bulundu',
      one: '1 öğe bulundu',
    );
    return '$_temp0';
  }

  @override
  String carouselSelectedCount(int count) {
    return '$count seçildi';
  }

  @override
  String get carouselVideoTitle => 'Video klip';

  @override
  String carouselImageTitle(int index) {
    return 'Görsel $index';
  }

  @override
  String get carouselSelectToSave => 'Kaydedilecek öğeleri seçin';

  @override
  String carouselSaveCta(int count, Object size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğeyi kaydet · ≈ $size MB',
      one: '1 öğeyi kaydet · ≈ $size MB',
    );
    return '$_temp0';
  }

  @override
  String get downloadingTitleMulti => 'Öğeler kaydediliyor';

  @override
  String downloadingSavingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe kaydediliyor',
      one: '1 öğe kaydediliyor',
    );
    return '$_temp0';
  }

  @override
  String downloadingProgressDetail(int done, int remaining) {
    return '$done tamamlandı · $remaining kaldı';
  }

  @override
  String get downloadingSavingVideo => 'Video kaydediliyor…';

  @override
  String downloadingSingleDetail(Object current) {
    return '24 MB’nin $current MB’si · 3.2 MB/sn';
  }

  @override
  String get downloadingPause => 'Duraklat';

  @override
  String get downloadingResume => 'Sürdür';

  @override
  String get downloadingCancel => 'İptal';

  @override
  String get statusDone => 'tamamlandı';

  @override
  String get statusFailed => 'başarısız';

  @override
  String get statusPaused => 'duraklatıldı';

  @override
  String get statusCanceled => 'iptal edildi';

  @override
  String get successTitleSingle => 'Galeriye kaydedildi';

  @override
  String successTitleMulti(int count) {
    return '$count öğe kaydedildi';
  }

  @override
  String get successBodySingle => 'Medyanız galerinizde, çevrimdışı hazır.';

  @override
  String get successBodyMulti => 'Galerinizde, çevrimdışı hazır.';

  @override
  String get successAddedHistory => 'Geçmişinize eklendi';

  @override
  String get successOpenGallery => 'Galeride aç';

  @override
  String get successViewHistory => 'Geçmişi gör';

  @override
  String get successSaveAnother => 'Başka bağlantı kaydet';

  @override
  String get successGalleryPlaceholder =>
      'Galerinize kaydedildi. Açma özelliği galeri erişimiyle gelecek.';

  @override
  String get closeTooltip => 'Kapat';

  @override
  String get historyTitle => 'Geçmiş';

  @override
  String get historyToday => 'Bugün';

  @override
  String get historyYesterday => 'Dün';

  @override
  String get historyEarlier => 'Daha önce';

  @override
  String historyStorageSummary(int count) {
    return '$count kayıt · 248 MB kullanıldı';
  }

  @override
  String get historyStoredInGallery => 'Galerinizde saklanıyor';

  @override
  String get historyEmptyTitle => 'Henüz kayıt yok';

  @override
  String get historyEmptyBody =>
      'Kaydettiğiniz medya burada, güne göre gruplanarak görünür. İşte nasıl çalıştığı:';

  @override
  String get historyEmptyCta => 'Bağlantı yapıştır';

  @override
  String get historyVideoTitle => 'Video klip';

  @override
  String get historyImageTitle => 'Görsel';

  @override
  String get historySearchComingSoon => 'Arama yakında geliyor.';

  @override
  String get actionOpen => 'Aç';

  @override
  String get actionShare => 'Paylaş';

  @override
  String get actionRemove => 'Kaldır';

  @override
  String get backTooltip => 'Geri';

  @override
  String get searchTooltip => 'Ara';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsGroupDownloads => 'Kaydetme';

  @override
  String get settingsGroupPermissions => 'İzinler';

  @override
  String get settingsGroupStorage => 'Depolama';

  @override
  String get settingsGroupAppearance => 'Görünüm';

  @override
  String get settingsGroupAboutLegal => 'Hakkında ve yasal';

  @override
  String get settingDefaultQuality => 'Varsayılan kalite';

  @override
  String get settingAskQuality => 'Her seferinde kalite sor';

  @override
  String get settingWifiOnly => 'Yalnızca Wi-Fi’de kaydet';

  @override
  String get settingSaveToGallery => 'Galeriye kaydet';

  @override
  String get settingOpenSystemSettings => 'Sistem ayarlarını aç';

  @override
  String get settingNotifications => 'Kayıt bildirimleri';

  @override
  String get settingSaveLocation => 'Kayıt konumu';

  @override
  String get settingSaveLocationValue => 'Galeri';

  @override
  String get settingClearHistory => 'Geçmişi temizle';

  @override
  String get settingTheme => 'Tema';

  @override
  String get settingThemeValue => 'Açık';

  @override
  String get settingLanguage => 'Dil';

  @override
  String get languageSystem => 'Sistem dili';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageSpanish => 'İspanyolca';

  @override
  String get languageDone => 'Tamam';

  @override
  String get settingHowItWorks => 'Quietly nasıl çalışır';

  @override
  String get settingAcceptableUse => 'Kabul edilebilir kullanım ve haklarınız';

  @override
  String get settingPrivacy => 'Gizlilik politikası';

  @override
  String get settingTerms => 'Hizmet şartları';

  @override
  String get settingsVersion => 'Quietly · sürüm 1.0.0';

  @override
  String get permAllowed => 'İzin verildi';

  @override
  String get permNotAllowed => 'İzin yok';

  @override
  String get permBlocked => 'Engellendi';

  @override
  String get snackSaveLocationFixed => 'Kayıt konumu şimdilik sabit.';

  @override
  String get snackHistoryCleared => 'Geçmiş temizlendi.';

  @override
  String get snackDarkTheme => 'Koyu tema yakında geliyor.';

  @override
  String get snackComingSoon => 'Yakında.';

  @override
  String get permSheetTitle => 'Galeriye kaydetmeye izin verin';

  @override
  String get permSheetBody =>
      'Quietly, medyayı cihazınızın galerisine kaydetmek için izne ihtiyaç duyar. Yalnızca seçtiğiniz dosyaları yazarız — başka hiçbir şeyi değil.';

  @override
  String get permSheetAllow => 'Erişime izin ver';

  @override
  String get permSheetNotNow => 'Şimdi değil';

  @override
  String get qualityTitle => 'Kalite seçin';

  @override
  String get qualitySubtitle =>
      'Daha yüksek kalite daha net görünür ama daha fazla depolama kullanır.';

  @override
  String get qualityRecommended => 'Önerilen';

  @override
  String get qualityDone => 'Tamam';

  @override
  String qualitySubRow(Object tag, Object size) {
    return '$tag · ≈ $size';
  }

  @override
  String get qualityLabelAudio => 'Yalnızca ses';

  @override
  String get qualityTagHigh => 'Yüksek · yatay';

  @override
  String get qualityTagStandard => 'Standart';

  @override
  String get qualityTagDataSaver => 'Veri tasarrufu';

  @override
  String get qualityTagAudio => 'M4A';

  @override
  String get errTipsHeader => 'Şunları deneyebilirsiniz';

  @override
  String get errProtectedTitle => 'Bu içerik korumalı';

  @override
  String get errProtectedBody =>
      'Özel, yalnızca girişle erişilen veya hak korumalı görünüyor. Quietly yalnızca herkese açık ve izinli medyayı kaydedebilir.';

  @override
  String get errProtectedCta => 'Başka bağlantı dene';

  @override
  String get errProtectedTip1 => 'Aynı gönderinin herkese açık bir sürümü';

  @override
  String get errProtectedTip2 =>
      'Hakkına sahip olduğunuz doğrudan bir bağlantı';

  @override
  String get errInvalidTitle => 'Bu bir bağlantıya benzemiyor';

  @override
  String get errInvalidBody =>
      'Tam bir web adresi kopyaladığınızdan emin olun — https:// ile başlamalı ve herkese açık bir gönderiye ya da sayfaya gitmeli.';

  @override
  String get errInvalidCta => 'Tekrar yapıştır';

  @override
  String get errNetworkTitle => 'Bu bağlantıya ulaşılamadı';

  @override
  String get errNetworkBody =>
      'Bağlanamadık. Bağlantınızı kontrol edip tekrar deneyin — bağlantınız hâlâ burada.';

  @override
  String get errNetworkCta => 'Tekrar dene';

  @override
  String get errNetworkSecondary => 'Bağlantıyı düzenle';

  @override
  String get errUnsupportedTitle => 'Bu kaynağı henüz okuyamıyoruz';

  @override
  String get errUnsupportedBody =>
      'Bu site medya analizi için desteklenmiyor. Yalnızca kaydetmeye izin veren herkese açık kaynaklarla çalışırız.';

  @override
  String get errUnsupportedCta => 'Başka bağlantı dene';

  @override
  String get errStorageTitle => 'Yeterli alan yok';

  @override
  String get errStorageBody =>
      'Cihazınızın depolaması az. Biraz yer açın ya da daha küçük bir kalite seçip tekrar deneyin.';

  @override
  String get errStorageCta => 'Daha küçük kalite seç';

  @override
  String get errStorageSecondary => 'Depolamayı yönet';

  @override
  String get errExistsTitle => 'Zaten galerinizde';

  @override
  String get errExistsBody =>
      'Bu medyayı zaten kaydetmişsiniz. Açabilir ya da kopya olarak tekrar kaydedebilirsiniz.';

  @override
  String get errExistsCta => 'Galeride aç';

  @override
  String get errExistsSecondary => 'Kopya kaydet';

  @override
  String get errPermTitle => 'Galeri erişimi kapalı';

  @override
  String get errPermBody =>
      'Quietly, galerinize kaydetmek için izne ihtiyaç duyar. Şu anda sistem ayarlarınızda kapalı — kaydetmeye devam etmek için tekrar açın.';

  @override
  String get errPermCta => 'Ayarları aç';

  @override
  String get errPermSecondary => 'Şimdi değil';

  @override
  String get errQueueTitle => 'Bir dosya kaydedilemedi';

  @override
  String get errQueueBody =>
      'Bu öğe kesintiye uğradı. Diğer kayıtlarınız güvende — bunu tekrar deneyebilirsiniz.';

  @override
  String get errQueueCta => 'Tekrar dene';

  @override
  String get errQueueSecondary => 'Atla';
}
