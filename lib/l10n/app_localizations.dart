import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('tr'),
  ];

  /// No description provided for @brandName.
  ///
  /// In en, this message translates to:
  /// **'Quietly'**
  String get brandName;

  /// No description provided for @onboardingValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Save public photos & videos to your gallery'**
  String get onboardingValueTitle;

  /// No description provided for @onboardingValueBody.
  ///
  /// In en, this message translates to:
  /// **'Paste a link — Quietly checks it’s public, then saves it. Calm and private.'**
  String get onboardingValueBody;

  /// No description provided for @onboardingHowTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get onboardingHowTitle;

  /// No description provided for @onboardingTrustTitle.
  ///
  /// In en, this message translates to:
  /// **'Private by design'**
  String get onboardingTrustTitle;

  /// No description provided for @onboardingTrustBody.
  ///
  /// In en, this message translates to:
  /// **'Quietly saves public, permitted media only. Your saves and settings stay on your device.'**
  String get onboardingTrustBody;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @stepPasteShort.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get stepPasteShort;

  /// No description provided for @stepPasteLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste link'**
  String get stepPasteLabel;

  /// No description provided for @stepPasteDesc.
  ///
  /// In en, this message translates to:
  /// **'Copy a public media link, then paste it.'**
  String get stepPasteDesc;

  /// No description provided for @stepAnalyzeShort.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get stepAnalyzeShort;

  /// No description provided for @stepAnalyzeLabel.
  ///
  /// In en, this message translates to:
  /// **'Analyze media'**
  String get stepAnalyzeLabel;

  /// No description provided for @stepAnalyzeDesc.
  ///
  /// In en, this message translates to:
  /// **'Quietly checks it’s public and readable.'**
  String get stepAnalyzeDesc;

  /// No description provided for @stepSaveShort.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get stepSaveShort;

  /// No description provided for @stepSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get stepSaveLabel;

  /// No description provided for @stepSaveDesc.
  ///
  /// In en, this message translates to:
  /// **'The media is saved to your gallery.'**
  String get stepSaveDesc;

  /// No description provided for @stepHistoryShort.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get stepHistoryShort;

  /// No description provided for @stepHistoryLabel.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get stepHistoryLabel;

  /// No description provided for @stepHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Find everything you’ve saved, anytime.'**
  String get stepHistoryDesc;

  /// No description provided for @trustNoAds.
  ///
  /// In en, this message translates to:
  /// **'No ads'**
  String get trustNoAds;

  /// No description provided for @trustNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get trustNoAccount;

  /// No description provided for @trustNoTracking.
  ///
  /// In en, this message translates to:
  /// **'No tracking'**
  String get trustNoTracking;

  /// No description provided for @trustRowSemantic.
  ///
  /// In en, this message translates to:
  /// **'No ads, no account, no tracking'**
  String get trustRowSemantic;

  /// No description provided for @homeHeadline.
  ///
  /// In en, this message translates to:
  /// **'Save public media to your gallery'**
  String get homeHeadline;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste a public link and Quietly checks it, then saves the photo or video to your gallery.'**
  String get homeSubtitle;

  /// No description provided for @homeClipboardLabel.
  ///
  /// In en, this message translates to:
  /// **'FROM YOUR CLIPBOARD'**
  String get homeClipboardLabel;

  /// No description provided for @homeClipboardSemantic.
  ///
  /// In en, this message translates to:
  /// **'Use link from your clipboard: {url}'**
  String homeClipboardSemantic(Object url);

  /// No description provided for @homeRecentSaves.
  ///
  /// In en, this message translates to:
  /// **'Recent saves'**
  String get homeRecentSaves;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homePasteCta.
  ///
  /// In en, this message translates to:
  /// **'Paste link'**
  String get homePasteCta;

  /// No description provided for @homeZeroState.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet — your saves will appear here.'**
  String get homeZeroState;

  /// No description provided for @homeOffline.
  ///
  /// In en, this message translates to:
  /// **'You’re offline — saved media still works.'**
  String get homeOffline;

  /// No description provided for @homeHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get homeHistoryTooltip;

  /// No description provided for @homeSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get homeSettingsTooltip;

  /// No description provided for @rightsHome.
  ///
  /// In en, this message translates to:
  /// **'Save only content you have the rights to. Private or protected media isn’t supported.'**
  String get rightsHome;

  /// No description provided for @rightsSave.
  ///
  /// In en, this message translates to:
  /// **'By saving, you confirm you have the right to keep this content.'**
  String get rightsSave;

  /// No description provided for @rightsStatement.
  ///
  /// In en, this message translates to:
  /// **'Quietly saves only publicly accessible media. You’re responsible for ensuring you have the rights to save and use any content. Private, login-only, and DRM-protected media isn’t supported.'**
  String get rightsStatement;

  /// No description provided for @rightsRefusal.
  ///
  /// In en, this message translates to:
  /// **'Quietly respects platform rules and creators’ rights. Some media simply can’t be saved.'**
  String get rightsRefusal;

  /// No description provided for @analyzingTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading this link'**
  String get analyzingTitle;

  /// No description provided for @analyzingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Finding media that’s publicly available for you to save.'**
  String get analyzingSubtitle;

  /// No description provided for @analyzingStep1.
  ///
  /// In en, this message translates to:
  /// **'Reaching the page'**
  String get analyzingStep1;

  /// No description provided for @analyzingStep2.
  ///
  /// In en, this message translates to:
  /// **'Checking it’s public'**
  String get analyzingStep2;

  /// No description provided for @analyzingStep3.
  ///
  /// In en, this message translates to:
  /// **'Listing available media'**
  String get analyzingStep3;

  /// No description provided for @publicChip.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicChip;

  /// No description provided for @resultTitle.
  ///
  /// In en, this message translates to:
  /// **'Available media'**
  String get resultTitle;

  /// No description provided for @shareTooltip.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareTooltip;

  /// No description provided for @resultVideoSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Public post · 1 video} other{Public post · {count} videos}}'**
  String resultVideoSummary(int count);

  /// No description provided for @resultImageSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Public post · 1 image} other{Public post · {count} images}}'**
  String resultImageSummary(int count);

  /// No description provided for @resultFormatVideo.
  ///
  /// In en, this message translates to:
  /// **'Landscape · MP4'**
  String get resultFormatVideo;

  /// No description provided for @resultFormatImage.
  ///
  /// In en, this message translates to:
  /// **'JPG'**
  String get resultFormatImage;

  /// No description provided for @resultSizeSuffix.
  ///
  /// In en, this message translates to:
  /// **' · ≈ {size}'**
  String resultSizeSuffix(Object size);

  /// No description provided for @resultExplain.
  ///
  /// In en, this message translates to:
  /// **'This media is publicly accessible. Choose a quality below, then save it to your gallery.'**
  String get resultExplain;

  /// No description provided for @resultQualityRow.
  ///
  /// In en, this message translates to:
  /// **'{label} · {tag}'**
  String resultQualityRow(Object label, Object tag);

  /// No description provided for @resultQualitySub.
  ///
  /// In en, this message translates to:
  /// **'≈ {size} · tap to change quality'**
  String resultQualitySub(Object size);

  /// No description provided for @resultSaveCta.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get resultSaveCta;

  /// No description provided for @previewVideo.
  ///
  /// In en, this message translates to:
  /// **'Video preview'**
  String get previewVideo;

  /// No description provided for @previewImage.
  ///
  /// In en, this message translates to:
  /// **'Image preview'**
  String get previewImage;

  /// No description provided for @labelVideo.
  ///
  /// In en, this message translates to:
  /// **'video'**
  String get labelVideo;

  /// No description provided for @labelImage.
  ///
  /// In en, this message translates to:
  /// **'image'**
  String get labelImage;

  /// No description provided for @carouselSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get carouselSelectAll;

  /// No description provided for @carouselClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get carouselClear;

  /// No description provided for @carouselTag.
  ///
  /// In en, this message translates to:
  /// **'Carousel'**
  String get carouselTag;

  /// No description provided for @carouselItemsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item found} other{{count} items found}}'**
  String carouselItemsFound(int count);

  /// No description provided for @carouselSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String carouselSelectedCount(int count);

  /// No description provided for @carouselVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video clip'**
  String get carouselVideoTitle;

  /// No description provided for @carouselImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Image {index}'**
  String carouselImageTitle(int index);

  /// No description provided for @carouselSelectToSave.
  ///
  /// In en, this message translates to:
  /// **'Select items to save'**
  String get carouselSelectToSave;

  /// No description provided for @carouselSaveCta.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Save 1 item · ≈ {size} MB} other{Save {count} items · ≈ {size} MB}}'**
  String carouselSaveCta(int count, Object size);

  /// No description provided for @downloadingTitleMulti.
  ///
  /// In en, this message translates to:
  /// **'Saving items'**
  String get downloadingTitleMulti;

  /// No description provided for @downloadingSavingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saving 1 item} other{Saving {count} items}}'**
  String downloadingSavingCount(int count);

  /// No description provided for @downloadingProgressDetail.
  ///
  /// In en, this message translates to:
  /// **'{done} done · {remaining} remaining'**
  String downloadingProgressDetail(int done, int remaining);

  /// No description provided for @downloadingSavingVideo.
  ///
  /// In en, this message translates to:
  /// **'Saving video…'**
  String get downloadingSavingVideo;

  /// No description provided for @downloadingSingleDetail.
  ///
  /// In en, this message translates to:
  /// **'{current} MB of 24 MB · 3.2 MB/s'**
  String downloadingSingleDetail(Object current);

  /// No description provided for @downloadingPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get downloadingPause;

  /// No description provided for @downloadingResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get downloadingResume;

  /// No description provided for @downloadingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get downloadingCancel;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get statusDone;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get statusFailed;

  /// No description provided for @statusPaused.
  ///
  /// In en, this message translates to:
  /// **'paused'**
  String get statusPaused;

  /// No description provided for @statusCanceled.
  ///
  /// In en, this message translates to:
  /// **'canceled'**
  String get statusCanceled;

  /// No description provided for @successTitleSingle.
  ///
  /// In en, this message translates to:
  /// **'Saved to gallery'**
  String get successTitleSingle;

  /// No description provided for @successTitleMulti.
  ///
  /// In en, this message translates to:
  /// **'{count} items saved'**
  String successTitleMulti(int count);

  /// No description provided for @successBodySingle.
  ///
  /// In en, this message translates to:
  /// **'Your media is in your gallery, ready offline.'**
  String get successBodySingle;

  /// No description provided for @successBodyMulti.
  ///
  /// In en, this message translates to:
  /// **'They’re in your gallery, ready offline.'**
  String get successBodyMulti;

  /// No description provided for @successAddedHistory.
  ///
  /// In en, this message translates to:
  /// **'Added to your history'**
  String get successAddedHistory;

  /// No description provided for @successOpenGallery.
  ///
  /// In en, this message translates to:
  /// **'Open in gallery'**
  String get successOpenGallery;

  /// No description provided for @successViewHistory.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get successViewHistory;

  /// No description provided for @successSaveAnother.
  ///
  /// In en, this message translates to:
  /// **'Save another link'**
  String get successSaveAnother;

  /// No description provided for @successGalleryPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Saved to your gallery. Opening it arrives with gallery access.'**
  String get successGalleryPlaceholder;

  /// No description provided for @closeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTooltip;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get historyToday;

  /// No description provided for @historyYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get historyYesterday;

  /// No description provided for @historyEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get historyEarlier;

  /// No description provided for @historyStorageSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} saves · 248 MB used'**
  String historyStorageSummary(int count);

  /// No description provided for @historyStoredInGallery.
  ///
  /// In en, this message translates to:
  /// **'Stored in your gallery'**
  String get historyStoredInGallery;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saves yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Media you save will appear here, grouped by day. Here’s how it works:'**
  String get historyEmptyBody;

  /// No description provided for @historyEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Paste a link'**
  String get historyEmptyCta;

  /// No description provided for @historyVideoTitle.
  ///
  /// In en, this message translates to:
  /// **'Video clip'**
  String get historyVideoTitle;

  /// No description provided for @historyImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get historyImageTitle;

  /// No description provided for @historySearchComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Search is coming soon.'**
  String get historySearchComingSoon;

  /// No description provided for @actionOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get actionOpen;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @backTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backTooltip;

  /// No description provided for @searchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTooltip;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGroupDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get settingsGroupDownloads;

  /// No description provided for @settingsGroupPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get settingsGroupPermissions;

  /// No description provided for @settingsGroupStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get settingsGroupStorage;

  /// No description provided for @settingsGroupAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsGroupAppearance;

  /// No description provided for @settingsGroupAboutLegal.
  ///
  /// In en, this message translates to:
  /// **'About & legal'**
  String get settingsGroupAboutLegal;

  /// No description provided for @settingDefaultQuality.
  ///
  /// In en, this message translates to:
  /// **'Default quality'**
  String get settingDefaultQuality;

  /// No description provided for @settingAskQuality.
  ///
  /// In en, this message translates to:
  /// **'Ask quality every time'**
  String get settingAskQuality;

  /// No description provided for @settingWifiOnly.
  ///
  /// In en, this message translates to:
  /// **'Save on Wi-Fi only'**
  String get settingWifiOnly;

  /// No description provided for @settingSaveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get settingSaveToGallery;

  /// No description provided for @settingOpenSystemSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get settingOpenSystemSettings;

  /// No description provided for @settingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Download notifications'**
  String get settingNotifications;

  /// No description provided for @settingSaveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save location'**
  String get settingSaveLocation;

  /// No description provided for @settingSaveLocationValue.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get settingSaveLocationValue;

  /// No description provided for @settingClearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get settingClearHistory;

  /// No description provided for @settingTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingTheme;

  /// No description provided for @settingThemeValue.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingThemeValue;

  /// No description provided for @settingHowItWorks.
  ///
  /// In en, this message translates to:
  /// **'How Quietly works'**
  String get settingHowItWorks;

  /// No description provided for @settingAcceptableUse.
  ///
  /// In en, this message translates to:
  /// **'Acceptable use & your rights'**
  String get settingAcceptableUse;

  /// No description provided for @settingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingPrivacy;

  /// No description provided for @settingTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get settingTerms;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Quietly · version 1.0.0'**
  String get settingsVersion;

  /// No description provided for @permAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permAllowed;

  /// No description provided for @permNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get permNotAllowed;

  /// No description provided for @permBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get permBlocked;

  /// No description provided for @snackSaveLocationFixed.
  ///
  /// In en, this message translates to:
  /// **'Save location is fixed for now.'**
  String get snackSaveLocationFixed;

  /// No description provided for @snackHistoryCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared.'**
  String get snackHistoryCleared;

  /// No description provided for @snackDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark theme is coming.'**
  String get snackDarkTheme;

  /// No description provided for @snackComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get snackComingSoon;

  /// No description provided for @permSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Allow saving to your gallery'**
  String get permSheetTitle;

  /// No description provided for @permSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Quietly needs permission to save media to your device’s gallery. We only write the files you choose — nothing else.'**
  String get permSheetBody;

  /// No description provided for @permSheetAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow access'**
  String get permSheetAllow;

  /// No description provided for @permSheetNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get permSheetNotNow;

  /// No description provided for @qualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose quality'**
  String get qualityTitle;

  /// No description provided for @qualitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Higher quality looks sharper but uses more storage.'**
  String get qualitySubtitle;

  /// No description provided for @qualityRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get qualityRecommended;

  /// No description provided for @qualityDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get qualityDone;

  /// No description provided for @qualitySubRow.
  ///
  /// In en, this message translates to:
  /// **'{tag} · ≈ {size}'**
  String qualitySubRow(Object tag, Object size);

  /// No description provided for @qualityLabelAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio only'**
  String get qualityLabelAudio;

  /// No description provided for @qualityTagHigh.
  ///
  /// In en, this message translates to:
  /// **'High · landscape'**
  String get qualityTagHigh;

  /// No description provided for @qualityTagStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get qualityTagStandard;

  /// No description provided for @qualityTagDataSaver.
  ///
  /// In en, this message translates to:
  /// **'Data saver'**
  String get qualityTagDataSaver;

  /// No description provided for @qualityTagAudio.
  ///
  /// In en, this message translates to:
  /// **'M4A'**
  String get qualityTagAudio;

  /// No description provided for @errTipsHeader.
  ///
  /// In en, this message translates to:
  /// **'You can try'**
  String get errTipsHeader;

  /// No description provided for @errProtectedTitle.
  ///
  /// In en, this message translates to:
  /// **'This content is protected'**
  String get errProtectedTitle;

  /// No description provided for @errProtectedBody.
  ///
  /// In en, this message translates to:
  /// **'It looks private, login-only, or rights-protected. Quietly can only save media that’s publicly available and permitted.'**
  String get errProtectedBody;

  /// No description provided for @errProtectedCta.
  ///
  /// In en, this message translates to:
  /// **'Try another link'**
  String get errProtectedCta;

  /// No description provided for @errProtectedTip1.
  ///
  /// In en, this message translates to:
  /// **'A public version of the same post'**
  String get errProtectedTip1;

  /// No description provided for @errProtectedTip2.
  ///
  /// In en, this message translates to:
  /// **'A direct link you have rights to'**
  String get errProtectedTip2;

  /// No description provided for @errInvalidTitle.
  ///
  /// In en, this message translates to:
  /// **'That doesn’t look like a link'**
  String get errInvalidTitle;

  /// No description provided for @errInvalidBody.
  ///
  /// In en, this message translates to:
  /// **'Make sure you’ve copied a full web address — it should start with https:// and point to a public post or page.'**
  String get errInvalidBody;

  /// No description provided for @errInvalidCta.
  ///
  /// In en, this message translates to:
  /// **'Paste again'**
  String get errInvalidCta;

  /// No description provided for @errNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t reach this link'**
  String get errNetworkTitle;

  /// No description provided for @errNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'We weren’t able to connect. Check your connection and try again — your link is still here.'**
  String get errNetworkBody;

  /// No description provided for @errNetworkCta.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errNetworkCta;

  /// No description provided for @errNetworkSecondary.
  ///
  /// In en, this message translates to:
  /// **'Edit link'**
  String get errNetworkSecondary;

  /// No description provided for @errUnsupportedTitle.
  ///
  /// In en, this message translates to:
  /// **'We can’t read this source yet'**
  String get errUnsupportedTitle;

  /// No description provided for @errUnsupportedBody.
  ///
  /// In en, this message translates to:
  /// **'This site isn’t supported for media analysis. We only work with public sources that allow saving.'**
  String get errUnsupportedBody;

  /// No description provided for @errUnsupportedCta.
  ///
  /// In en, this message translates to:
  /// **'Try another link'**
  String get errUnsupportedCta;

  /// No description provided for @errStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'Not enough space'**
  String get errStorageTitle;

  /// No description provided for @errStorageBody.
  ///
  /// In en, this message translates to:
  /// **'Your device is low on storage. Free up some space, or choose a smaller quality, then try again.'**
  String get errStorageBody;

  /// No description provided for @errStorageCta.
  ///
  /// In en, this message translates to:
  /// **'Choose smaller quality'**
  String get errStorageCta;

  /// No description provided for @errStorageSecondary.
  ///
  /// In en, this message translates to:
  /// **'Manage storage'**
  String get errStorageSecondary;

  /// No description provided for @errExistsTitle.
  ///
  /// In en, this message translates to:
  /// **'Already in your gallery'**
  String get errExistsTitle;

  /// No description provided for @errExistsBody.
  ///
  /// In en, this message translates to:
  /// **'You’ve already saved this exact media. You can open it, or save it again as a copy.'**
  String get errExistsBody;

  /// No description provided for @errExistsCta.
  ///
  /// In en, this message translates to:
  /// **'Open in gallery'**
  String get errExistsCta;

  /// No description provided for @errExistsSecondary.
  ///
  /// In en, this message translates to:
  /// **'Save a copy'**
  String get errExistsSecondary;

  /// No description provided for @errPermTitle.
  ///
  /// In en, this message translates to:
  /// **'Gallery access is off'**
  String get errPermTitle;

  /// No description provided for @errPermBody.
  ///
  /// In en, this message translates to:
  /// **'Quietly needs permission to save to your gallery. It’s currently turned off in your system settings — turn it back on to keep saving.'**
  String get errPermBody;

  /// No description provided for @errPermCta.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get errPermCta;

  /// No description provided for @errPermSecondary.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get errPermSecondary;

  /// No description provided for @errQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'A file didn’t save'**
  String get errQueueTitle;

  /// No description provided for @errQueueBody.
  ///
  /// In en, this message translates to:
  /// **'Something interrupted this item. Your other saves are safe — you can try this one again.'**
  String get errQueueBody;

  /// No description provided for @errQueueCta.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get errQueueCta;

  /// No description provided for @errQueueSecondary.
  ///
  /// In en, this message translates to:
  /// **'Skip it'**
  String get errQueueSecondary;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
