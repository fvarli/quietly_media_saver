// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get brandName => 'Quietly';

  @override
  String get onboardingValueTitle =>
      'Save public photos & videos to your gallery';

  @override
  String get onboardingValueBody =>
      'Paste a link — Quietly checks it’s public, then saves it. Calm and private.';

  @override
  String get onboardingHowTitle => 'How it works';

  @override
  String get onboardingTrustTitle => 'Private by design';

  @override
  String get onboardingTrustBody =>
      'Quietly saves public, permitted media only. Your saves and settings stay on your device.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get stepPasteShort => 'Paste';

  @override
  String get stepPasteLabel => 'Paste link';

  @override
  String get stepPasteDesc => 'Copy a public media link, then paste it.';

  @override
  String get stepAnalyzeShort => 'Analyze';

  @override
  String get stepAnalyzeLabel => 'Analyze media';

  @override
  String get stepAnalyzeDesc => 'Quietly checks it’s public and readable.';

  @override
  String get stepSaveShort => 'Save';

  @override
  String get stepSaveLabel => 'Save to gallery';

  @override
  String get stepSaveDesc => 'The media is saved to your gallery.';

  @override
  String get stepHistoryShort => 'History';

  @override
  String get stepHistoryLabel => 'View history';

  @override
  String get stepHistoryDesc => 'Find everything you’ve saved, anytime.';

  @override
  String get trustNoAds => 'No ads';

  @override
  String get trustNoAccount => 'No account';

  @override
  String get trustNoTracking => 'No tracking';

  @override
  String get trustRowSemantic => 'No ads, no account, no tracking';

  @override
  String get homeHeadline => 'Save public media to your gallery';

  @override
  String get homeSubtitle =>
      'Paste a public link and Quietly checks it, then saves the photo or video to your gallery.';

  @override
  String get homeClipboardLabel => 'FROM YOUR CLIPBOARD';

  @override
  String homeClipboardSemantic(Object url) {
    return 'Use link from your clipboard: $url';
  }

  @override
  String get homeRecentSaves => 'Recent saves';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homePasteCta => 'Paste link';

  @override
  String get homeZeroState =>
      'Nothing saved yet — your saves will appear here.';

  @override
  String get homeOffline => 'You’re offline — saved media still works.';

  @override
  String get homeHistoryTooltip => 'History';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get rightsHome =>
      'Save only content you have the rights to. Private or protected media isn’t supported.';

  @override
  String get rightsSave =>
      'By saving, you confirm you have the right to keep this content.';

  @override
  String get rightsStatement =>
      'Quietly saves only publicly accessible media. You’re responsible for ensuring you have the rights to save and use any content. Private, login-only, and DRM-protected media isn’t supported.';

  @override
  String get rightsRefusal =>
      'Quietly respects platform rules and creators’ rights. Some media simply can’t be saved.';

  @override
  String get analyzingTitle => 'Reading this link';

  @override
  String get analyzingSubtitle =>
      'Finding media that’s publicly available for you to save.';

  @override
  String get analyzingStep1 => 'Reaching the page';

  @override
  String get analyzingStep2 => 'Checking it’s public';

  @override
  String get analyzingStep3 => 'Listing available media';

  @override
  String get publicChip => 'Public';

  @override
  String get resultTitle => 'Available media';

  @override
  String get shareTooltip => 'Share';

  @override
  String resultVideoSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Public post · $count videos',
      one: 'Public post · 1 video',
    );
    return '$_temp0';
  }

  @override
  String resultImageSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Public post · $count images',
      one: 'Public post · 1 image',
    );
    return '$_temp0';
  }

  @override
  String get resultFormatVideo => 'Landscape · MP4';

  @override
  String get resultFormatImage => 'JPG';

  @override
  String resultSizeSuffix(Object size) {
    return ' · ≈ $size';
  }

  @override
  String get resultExplain =>
      'This media is publicly accessible. Choose a quality below, then save it to your gallery.';

  @override
  String resultQualityRow(Object label, Object tag) {
    return '$label · $tag';
  }

  @override
  String resultQualitySub(Object size) {
    return '≈ $size · tap to change quality';
  }

  @override
  String get resultSaveCta => 'Save to gallery';

  @override
  String get previewVideo => 'Video preview';

  @override
  String get previewImage => 'Image preview';

  @override
  String get labelVideo => 'video';

  @override
  String get labelImage => 'image';

  @override
  String get carouselSelectAll => 'Select all';

  @override
  String get carouselClear => 'Clear';

  @override
  String get carouselTag => 'Carousel';

  @override
  String carouselItemsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items found',
      one: '1 item found',
    );
    return '$_temp0';
  }

  @override
  String carouselSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get carouselVideoTitle => 'Video clip';

  @override
  String carouselImageTitle(int index) {
    return 'Image $index';
  }

  @override
  String get carouselSelectToSave => 'Select items to save';

  @override
  String carouselSaveCta(int count, Object size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count items · ≈ $size MB',
      one: 'Save 1 item · ≈ $size MB',
    );
    return '$_temp0';
  }

  @override
  String get downloadingTitleMulti => 'Saving items';

  @override
  String downloadingSavingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saving $count items',
      one: 'Saving 1 item',
    );
    return '$_temp0';
  }

  @override
  String downloadingProgressDetail(int done, int remaining) {
    return '$done done · $remaining remaining';
  }

  @override
  String get downloadingSavingVideo => 'Saving video…';

  @override
  String downloadingSingleDetail(Object current) {
    return '$current MB of 24 MB · 3.2 MB/s';
  }

  @override
  String get downloadingPause => 'Pause';

  @override
  String get downloadingResume => 'Resume';

  @override
  String get downloadingCancel => 'Cancel';

  @override
  String get statusDone => 'done';

  @override
  String get statusFailed => 'failed';

  @override
  String get statusPaused => 'paused';

  @override
  String get statusCanceled => 'canceled';

  @override
  String get successTitleSingle => 'Saved to gallery';

  @override
  String successTitleMulti(int count) {
    return '$count items saved';
  }

  @override
  String get successBodySingle =>
      'Your media is in your gallery, ready offline.';

  @override
  String get successBodyMulti => 'They’re in your gallery, ready offline.';

  @override
  String get successAddedHistory => 'Added to your history';

  @override
  String get successOpenGallery => 'Open in gallery';

  @override
  String get successViewHistory => 'View history';

  @override
  String get successSaveAnother => 'Save another link';

  @override
  String get successGalleryPlaceholder =>
      'Saved to your gallery. Opening it arrives with gallery access.';

  @override
  String get closeTooltip => 'Close';

  @override
  String get historyTitle => 'History';

  @override
  String get historyToday => 'Today';

  @override
  String get historyYesterday => 'Yesterday';

  @override
  String get historyEarlier => 'Earlier';

  @override
  String historyStorageSummary(int count) {
    return '$count saves · 248 MB used';
  }

  @override
  String get historyStoredInGallery => 'Stored in your gallery';

  @override
  String get historyEmptyTitle => 'No saves yet';

  @override
  String get historyEmptyBody =>
      'Media you save will appear here, grouped by day. Here’s how it works:';

  @override
  String get historyEmptyCta => 'Paste a link';

  @override
  String get historyVideoTitle => 'Video clip';

  @override
  String get historyImageTitle => 'Image';

  @override
  String get historySearchComingSoon => 'Search is coming soon.';

  @override
  String get actionOpen => 'Open';

  @override
  String get actionShare => 'Share';

  @override
  String get actionRemove => 'Remove';

  @override
  String get backTooltip => 'Back';

  @override
  String get searchTooltip => 'Search';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsGroupDownloads => 'Downloads';

  @override
  String get settingsGroupPermissions => 'Permissions';

  @override
  String get settingsGroupStorage => 'Storage';

  @override
  String get settingsGroupAppearance => 'Appearance';

  @override
  String get settingsGroupAboutLegal => 'About & legal';

  @override
  String get settingDefaultQuality => 'Default quality';

  @override
  String get settingAskQuality => 'Ask quality every time';

  @override
  String get settingWifiOnly => 'Save on Wi-Fi only';

  @override
  String get settingSaveToGallery => 'Save to gallery';

  @override
  String get settingOpenSystemSettings => 'Open system settings';

  @override
  String get settingNotifications => 'Download notifications';

  @override
  String get settingSaveLocation => 'Save location';

  @override
  String get settingSaveLocationValue => 'Gallery';

  @override
  String get settingClearHistory => 'Clear history';

  @override
  String get settingTheme => 'Theme';

  @override
  String get settingThemeValue => 'Light';

  @override
  String get settingHowItWorks => 'How Quietly works';

  @override
  String get settingAcceptableUse => 'Acceptable use & your rights';

  @override
  String get settingPrivacy => 'Privacy policy';

  @override
  String get settingTerms => 'Terms of service';

  @override
  String get settingsVersion => 'Quietly · version 1.0.0';

  @override
  String get permAllowed => 'Allowed';

  @override
  String get permNotAllowed => 'Not allowed';

  @override
  String get permBlocked => 'Blocked';

  @override
  String get snackSaveLocationFixed => 'Save location is fixed for now.';

  @override
  String get snackHistoryCleared => 'History cleared.';

  @override
  String get snackDarkTheme => 'Dark theme is coming.';

  @override
  String get snackComingSoon => 'Coming soon.';

  @override
  String get permSheetTitle => 'Allow saving to your gallery';

  @override
  String get permSheetBody =>
      'Quietly needs permission to save media to your device’s gallery. We only write the files you choose — nothing else.';

  @override
  String get permSheetAllow => 'Allow access';

  @override
  String get permSheetNotNow => 'Not now';

  @override
  String get qualityTitle => 'Choose quality';

  @override
  String get qualitySubtitle =>
      'Higher quality looks sharper but uses more storage.';

  @override
  String get qualityRecommended => 'Recommended';

  @override
  String get qualityDone => 'Done';

  @override
  String qualitySubRow(Object tag, Object size) {
    return '$tag · ≈ $size';
  }

  @override
  String get qualityLabelAudio => 'Audio only';

  @override
  String get qualityTagHigh => 'High · landscape';

  @override
  String get qualityTagStandard => 'Standard';

  @override
  String get qualityTagDataSaver => 'Data saver';

  @override
  String get qualityTagAudio => 'M4A';

  @override
  String get errTipsHeader => 'You can try';

  @override
  String get errProtectedTitle => 'This content is protected';

  @override
  String get errProtectedBody =>
      'It looks private, login-only, or rights-protected. Quietly can only save media that’s publicly available and permitted.';

  @override
  String get errProtectedCta => 'Try another link';

  @override
  String get errProtectedTip1 => 'A public version of the same post';

  @override
  String get errProtectedTip2 => 'A direct link you have rights to';

  @override
  String get errInvalidTitle => 'That doesn’t look like a link';

  @override
  String get errInvalidBody =>
      'Make sure you’ve copied a full web address — it should start with https:// and point to a public post or page.';

  @override
  String get errInvalidCta => 'Paste again';

  @override
  String get errNetworkTitle => 'Couldn’t reach this link';

  @override
  String get errNetworkBody =>
      'We weren’t able to connect. Check your connection and try again — your link is still here.';

  @override
  String get errNetworkCta => 'Retry';

  @override
  String get errNetworkSecondary => 'Edit link';

  @override
  String get errUnsupportedTitle => 'We can’t read this source yet';

  @override
  String get errUnsupportedBody =>
      'This site isn’t supported for media analysis. We only work with public sources that allow saving.';

  @override
  String get errUnsupportedCta => 'Try another link';

  @override
  String get errStorageTitle => 'Not enough space';

  @override
  String get errStorageBody =>
      'Your device is low on storage. Free up some space, or choose a smaller quality, then try again.';

  @override
  String get errStorageCta => 'Choose smaller quality';

  @override
  String get errStorageSecondary => 'Manage storage';

  @override
  String get errExistsTitle => 'Already in your gallery';

  @override
  String get errExistsBody =>
      'You’ve already saved this exact media. You can open it, or save it again as a copy.';

  @override
  String get errExistsCta => 'Open in gallery';

  @override
  String get errExistsSecondary => 'Save a copy';

  @override
  String get errPermTitle => 'Gallery access is off';

  @override
  String get errPermBody =>
      'Quietly needs permission to save to your gallery. It’s currently turned off in your system settings — turn it back on to keep saving.';

  @override
  String get errPermCta => 'Open settings';

  @override
  String get errPermSecondary => 'Not now';

  @override
  String get errQueueTitle => 'A file didn’t save';

  @override
  String get errQueueBody =>
      'Something interrupted this item. Your other saves are safe — you can try this one again.';

  @override
  String get errQueueCta => 'Retry';

  @override
  String get errQueueSecondary => 'Skip it';
}
