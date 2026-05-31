// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get brandName => 'Quietly';

  @override
  String get onboardingValueTitle =>
      'Guarda fotos y videos públicos en tu galería';

  @override
  String get onboardingValueBody =>
      'Pega un enlace — Quietly comprueba que es público y lo guarda. Tranquilo y privado.';

  @override
  String get onboardingHowTitle => 'Cómo funciona';

  @override
  String get onboardingTrustTitle => 'Privado por diseño';

  @override
  String get onboardingTrustBody =>
      'Quietly solo guarda medios públicos y permitidos. Tus guardados y ajustes se quedan en tu dispositivo.';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingGetStarted => 'Empezar';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get stepPasteShort => 'Pegar';

  @override
  String get stepPasteLabel => 'Pegar enlace';

  @override
  String get stepPasteDesc => 'Copia un enlace de medios público y pégalo.';

  @override
  String get stepAnalyzeShort => 'Analizar';

  @override
  String get stepAnalyzeLabel => 'Analizar medios';

  @override
  String get stepAnalyzeDesc => 'Quietly comprueba que es público y legible.';

  @override
  String get stepSaveShort => 'Guardar';

  @override
  String get stepSaveLabel => 'Guardar en galería';

  @override
  String get stepSaveDesc => 'El medio se guarda en tu galería.';

  @override
  String get stepHistoryShort => 'Historial';

  @override
  String get stepHistoryLabel => 'Ver historial';

  @override
  String get stepHistoryDesc =>
      'Encuentra todo lo que has guardado, cuando quieras.';

  @override
  String get trustNoAds => 'Sin anuncios';

  @override
  String get trustNoAccount => 'Sin cuenta';

  @override
  String get trustNoTracking => 'Sin rastreo';

  @override
  String get trustRowSemantic => 'Sin anuncios, sin cuenta, sin rastreo';

  @override
  String get homeHeadline => 'Guarda medios públicos en tu galería';

  @override
  String get homeSubtitle =>
      'Pega un enlace público y Quietly lo comprueba, luego guarda la foto o el video en tu galería.';

  @override
  String get homeClipboardLabel => 'DE TU PORTAPAPELES';

  @override
  String homeClipboardSemantic(Object url) {
    return 'Usar enlace de tu portapapeles: $url';
  }

  @override
  String get homeRecentSaves => 'Guardados recientes';

  @override
  String get homeSeeAll => 'Ver todo';

  @override
  String get homePasteCta => 'Pegar enlace';

  @override
  String get homeZeroState =>
      'Aún no hay guardados — tus guardados aparecerán aquí.';

  @override
  String get homeOffline =>
      'Estás sin conexión — los medios guardados siguen funcionando.';

  @override
  String get homeHistoryTooltip => 'Historial';

  @override
  String get homeSettingsTooltip => 'Ajustes';

  @override
  String get rightsHome =>
      'Guarda solo contenido sobre el que tengas derechos. Los medios privados o protegidos no se admiten.';

  @override
  String get rightsSave =>
      'Al guardar, confirmas que tienes derecho a conservar este contenido.';

  @override
  String get rightsStatement =>
      'Quietly solo guarda medios de acceso público. Eres responsable de asegurarte de que tienes los derechos para guardar y usar cualquier contenido. Los medios privados, con inicio de sesión y protegidos por DRM no se admiten.';

  @override
  String get rightsRefusal =>
      'Quietly respeta las reglas de las plataformas y los derechos de los creadores. Algunos medios simplemente no se pueden guardar.';

  @override
  String get analyzingTitle => 'Leyendo este enlace';

  @override
  String get analyzingSubtitle =>
      'Buscando medios de acceso público para que los guardes.';

  @override
  String get analyzingStep1 => 'Accediendo a la página';

  @override
  String get analyzingStep2 => 'Comprobando que es público';

  @override
  String get analyzingStep3 => 'Listando medios disponibles';

  @override
  String get publicChip => 'Público';

  @override
  String get resultTitle => 'Medios disponibles';

  @override
  String get shareTooltip => 'Compartir';

  @override
  String resultVideoSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Publicación pública · $count videos',
      one: 'Publicación pública · 1 video',
    );
    return '$_temp0';
  }

  @override
  String resultImageSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Publicación pública · $count imágenes',
      one: 'Publicación pública · 1 imagen',
    );
    return '$_temp0';
  }

  @override
  String get resultFormatVideo => 'Horizontal · MP4';

  @override
  String get resultFormatImage => 'JPG';

  @override
  String resultSizeSuffix(Object size) {
    return ' · ≈ $size';
  }

  @override
  String get resultExplain =>
      'Este medio es de acceso público. Elige una calidad abajo y guárdalo en tu galería.';

  @override
  String resultQualityRow(Object label, Object tag) {
    return '$label · $tag';
  }

  @override
  String resultQualitySub(Object size) {
    return '≈ $size · toca para cambiar la calidad';
  }

  @override
  String get resultSaveCta => 'Guardar en galería';

  @override
  String get previewVideo => 'Vista previa de video';

  @override
  String get previewImage => 'Vista previa de imagen';

  @override
  String get labelVideo => 'video';

  @override
  String get labelImage => 'imagen';

  @override
  String get carouselSelectAll => 'Seleccionar todo';

  @override
  String get carouselClear => 'Borrar';

  @override
  String get carouselTag => 'Carrusel';

  @override
  String carouselItemsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos encontrados',
      one: '1 elemento encontrado',
    );
    return '$_temp0';
  }

  @override
  String carouselSelectedCount(int count) {
    return '$count seleccionados';
  }

  @override
  String get carouselVideoTitle => 'Videoclip';

  @override
  String carouselImageTitle(int index) {
    return 'Imagen $index';
  }

  @override
  String get carouselSelectToSave => 'Selecciona elementos para guardar';

  @override
  String carouselSaveCta(int count, Object size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardar $count elementos · ≈ $size MB',
      one: 'Guardar 1 elemento · ≈ $size MB',
    );
    return '$_temp0';
  }

  @override
  String get downloadingTitleMulti => 'Guardando elementos';

  @override
  String downloadingSavingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Guardando $count elementos',
      one: 'Guardando 1 elemento',
    );
    return '$_temp0';
  }

  @override
  String downloadingProgressDetail(int done, int remaining) {
    return '$done listos · $remaining restantes';
  }

  @override
  String get downloadingSavingVideo => 'Guardando video…';

  @override
  String downloadingSingleDetail(Object current) {
    return '$current MB de 24 MB · 3.2 MB/s';
  }

  @override
  String get downloadingPause => 'Pausar';

  @override
  String get downloadingResume => 'Reanudar';

  @override
  String get downloadingCancel => 'Cancelar';

  @override
  String get statusDone => 'listo';

  @override
  String get statusFailed => 'falló';

  @override
  String get statusPaused => 'en pausa';

  @override
  String get statusCanceled => 'cancelado';

  @override
  String get successTitleSingle => 'Guardado en la galería';

  @override
  String successTitleMulti(int count) {
    return '$count elementos guardados';
  }

  @override
  String get successBodySingle =>
      'Tu medio está en tu galería, listo sin conexión.';

  @override
  String get successBodyMulti => 'Están en tu galería, listos sin conexión.';

  @override
  String get successAddedHistory => 'Añadido a tu historial';

  @override
  String get successOpenGallery => 'Abrir en galería';

  @override
  String get successViewHistory => 'Ver historial';

  @override
  String get successSaveAnother => 'Guardar otro enlace';

  @override
  String get successGalleryPlaceholder =>
      'Guardado en tu galería. Abrirlo llegará con el acceso a la galería.';

  @override
  String get closeTooltip => 'Cerrar';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyToday => 'Hoy';

  @override
  String get historyYesterday => 'Ayer';

  @override
  String get historyEarlier => 'Antes';

  @override
  String historyStorageSummary(int count) {
    return '$count guardados · 248 MB usados';
  }

  @override
  String get historyStoredInGallery => 'Almacenado en tu galería';

  @override
  String get historyEmptyTitle => 'Aún no hay guardados';

  @override
  String get historyEmptyBody =>
      'Los medios que guardes aparecerán aquí, agrupados por día. Así funciona:';

  @override
  String get historyEmptyCta => 'Pegar enlace';

  @override
  String get historyVideoTitle => 'Videoclip';

  @override
  String get historyImageTitle => 'Imagen';

  @override
  String get historySearchComingSoon => 'La búsqueda llegará pronto.';

  @override
  String get actionOpen => 'Abrir';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionRemove => 'Quitar';

  @override
  String get backTooltip => 'Atrás';

  @override
  String get searchTooltip => 'Buscar';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsGroupDownloads => 'Guardado';

  @override
  String get settingsGroupPermissions => 'Permisos';

  @override
  String get settingsGroupStorage => 'Almacenamiento';

  @override
  String get settingsGroupAppearance => 'Apariencia';

  @override
  String get settingsGroupAboutLegal => 'Acerca de y legal';

  @override
  String get settingDefaultQuality => 'Calidad predeterminada';

  @override
  String get settingAskQuality => 'Preguntar calidad cada vez';

  @override
  String get settingWifiOnly => 'Guardar solo con Wi-Fi';

  @override
  String get settingSaveToGallery => 'Guardar en galería';

  @override
  String get settingOpenSystemSettings => 'Abrir ajustes del sistema';

  @override
  String get settingNotifications => 'Notificaciones de guardado';

  @override
  String get settingSaveLocation => 'Ubicación de guardado';

  @override
  String get settingSaveLocationValue => 'Galería';

  @override
  String get settingClearHistory => 'Borrar historial';

  @override
  String get settingTheme => 'Tema';

  @override
  String get settingThemeValue => 'Claro';

  @override
  String get settingLanguage => 'Idioma';

  @override
  String get languageSystem => 'Idioma del sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageTurkish => 'Turco';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageDone => 'Listo';

  @override
  String get settingHowItWorks => 'Cómo funciona Quietly';

  @override
  String get settingAcceptableUse => 'Uso aceptable y tus derechos';

  @override
  String get settingPrivacy => 'Política de privacidad';

  @override
  String get settingTerms => 'Términos del servicio';

  @override
  String get settingsVersion => 'Quietly · versión 1.0.0';

  @override
  String get permAllowed => 'Permitido';

  @override
  String get permNotAllowed => 'No permitido';

  @override
  String get permBlocked => 'Bloqueado';

  @override
  String get snackSaveLocationFixed =>
      'La ubicación de guardado es fija por ahora.';

  @override
  String get snackHistoryCleared => 'Historial borrado.';

  @override
  String get snackDarkTheme => 'El tema oscuro llegará pronto.';

  @override
  String get snackComingSoon => 'Próximamente.';

  @override
  String get permSheetTitle => 'Permite guardar en tu galería';

  @override
  String get permSheetBody =>
      'Quietly necesita permiso para guardar medios en la galería de tu dispositivo. Solo escribimos los archivos que eliges — nada más.';

  @override
  String get permSheetAllow => 'Permitir acceso';

  @override
  String get permSheetNotNow => 'Ahora no';

  @override
  String get qualityTitle => 'Elegir calidad';

  @override
  String get qualitySubtitle =>
      'Mayor calidad se ve más nítida pero usa más almacenamiento.';

  @override
  String get qualityRecommended => 'Recomendado';

  @override
  String get qualityDone => 'Listo';

  @override
  String qualitySubRow(Object tag, Object size) {
    return '$tag · ≈ $size';
  }

  @override
  String get qualityLabelAudio => 'Solo audio';

  @override
  String get qualityTagHigh => 'Alta · horizontal';

  @override
  String get qualityTagStandard => 'Estándar';

  @override
  String get qualityTagDataSaver => 'Ahorro de datos';

  @override
  String get qualityTagAudio => 'M4A';

  @override
  String get errTipsHeader => 'Puedes probar';

  @override
  String get errProtectedTitle => 'Este contenido está protegido';

  @override
  String get errProtectedBody =>
      'Parece privado, de solo inicio de sesión o protegido por derechos. Quietly solo puede guardar medios de acceso público y permitidos.';

  @override
  String get errProtectedCta => 'Probar otro enlace';

  @override
  String get errProtectedTip1 => 'Una versión pública de la misma publicación';

  @override
  String get errProtectedTip2 =>
      'Un enlace directo sobre el que tengas derechos';

  @override
  String get errInvalidTitle => 'Eso no parece un enlace';

  @override
  String get errInvalidBody =>
      'Asegúrate de copiar una dirección web completa — debe empezar por https:// y apuntar a una publicación o página pública.';

  @override
  String get errInvalidCta => 'Pegar de nuevo';

  @override
  String get errNetworkTitle => 'No se pudo acceder a este enlace';

  @override
  String get errNetworkBody =>
      'No pudimos conectar. Revisa tu conexión e inténtalo de nuevo — tu enlace sigue aquí.';

  @override
  String get errNetworkCta => 'Reintentar';

  @override
  String get errNetworkSecondary => 'Editar enlace';

  @override
  String get errUnsupportedTitle => 'Aún no podemos leer esta fuente';

  @override
  String get errUnsupportedBody =>
      'Este sitio no es compatible con el análisis de medios. Solo trabajamos con fuentes públicas que permiten guardar.';

  @override
  String get errUnsupportedCta => 'Probar otro enlace';

  @override
  String get errStorageTitle => 'No hay espacio suficiente';

  @override
  String get errStorageBody =>
      'Tu dispositivo tiene poco almacenamiento. Libera espacio o elige una calidad menor e inténtalo de nuevo.';

  @override
  String get errStorageCta => 'Elegir calidad menor';

  @override
  String get errStorageSecondary => 'Gestionar almacenamiento';

  @override
  String get errExistsTitle => 'Ya está en tu galería';

  @override
  String get errExistsBody =>
      'Ya has guardado exactamente este medio. Puedes abrirlo o guardarlo de nuevo como copia.';

  @override
  String get errExistsCta => 'Abrir en galería';

  @override
  String get errExistsSecondary => 'Guardar una copia';

  @override
  String get errPermTitle => 'El acceso a la galería está desactivado';

  @override
  String get errPermBody =>
      'Quietly necesita permiso para guardar en tu galería. Ahora está desactivado en los ajustes del sistema — actívalo de nuevo para seguir guardando.';

  @override
  String get errPermCta => 'Abrir ajustes';

  @override
  String get errPermSecondary => 'Ahora no';

  @override
  String get errQueueTitle => 'Un archivo no se guardó';

  @override
  String get errQueueBody =>
      'Algo interrumpió este elemento. Tus otros guardados están a salvo — puedes intentarlo de nuevo.';

  @override
  String get errQueueCta => 'Reintentar';

  @override
  String get errQueueSecondary => 'Omitir';
}
