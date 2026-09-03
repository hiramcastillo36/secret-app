// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Racha';

  @override
  String get commonEmail => 'Correo';

  @override
  String get commonPassword => 'Contraseña';

  @override
  String get commonDisplayName => 'Tu nombre';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get a11yBack => 'Atrás';

  @override
  String get a11yCalendar => 'Abrir calendario';

  @override
  String get a11yNotifications => 'Notificaciones';

  @override
  String a11yNotificationsUnread(int count) {
    return 'Notificaciones, $count sin leer';
  }

  @override
  String get a11yClearSearch => 'Limpiar búsqueda';

  @override
  String get a11yPreviousMonth => 'Mes anterior';

  @override
  String get a11yNextMonth => 'Mes siguiente';

  @override
  String get a11yMoreOptions => 'Más opciones';

  @override
  String get a11yWeekStrip => 'Racha de las últimas 12 semanas';

  @override
  String a11yRatingStars(int rating) {
    return '$rating de 5 estrellas';
  }

  @override
  String a11yCategoryShare(String category, String percent) {
    return '$category: $percent%';
  }

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSomethingWentWrong => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get commonNoConnection =>
      'Sin conexión. Revisa tu red e inténtalo de nuevo.';

  @override
  String get onboardingTitle1 => 'Salgan juntos';

  @override
  String get onboardingBody1 =>
      'Planeen una cita cada semana y hagan que el tiempo cuente.';

  @override
  String get onboardingTitle2 => 'Registren a dónde fueron';

  @override
  String get onboardingBody2 =>
      'Guarda el lugar, una calificación y un recuerdo de cada cita.';

  @override
  String get onboardingTitle3 => 'Mantengan la racha';

  @override
  String get onboardingBody3 =>
      'Una cita a la semana mantiene su racha creciendo.';

  @override
  String get onboardingCreateAccount => 'Crear cuenta';

  @override
  String get onboardingSignIn => 'Ya tengo una cuenta';

  @override
  String get loginTitle => 'Qué bueno verte';

  @override
  String get loginSubmit => 'Iniciar sesión';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginNoAccount => '¿No tienes cuenta? Regístrate';

  @override
  String get loginInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String loginPasswordNotSet(String provider) {
    return 'Esta cuenta se creó con $provider. Entra con ese proveedor.';
  }

  @override
  String get registerTitle => 'Crea tu cuenta';

  @override
  String get registerSubmit => 'Crear cuenta';

  @override
  String get registerHaveAccount => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get registerPasswordHint => 'Al menos 8 caracteres';

  @override
  String get registerEmailTaken => 'Ese correo ya está registrado.';

  @override
  String get validationEmailRequired => 'Escribe tu correo';

  @override
  String get validationEmailInvalid => 'Escribe un correo válido';

  @override
  String get validationPasswordRequired => 'Escribe tu contraseña';

  @override
  String get validationPasswordTooShort => 'Usa al menos 8 caracteres';

  @override
  String get validationNameRequired => 'Escribe tu nombre';

  @override
  String get splashTagline => 'Una cita a la semana.';

  @override
  String get coupleSetupTitle => 'Tú y tu persona';

  @override
  String get coupleSetupBody =>
      'Una racha necesita dos. Crea tu pareja o únete con el código que te compartieron.';

  @override
  String get coupleSetupCreate => 'Crear nuestra pareja';

  @override
  String get coupleSetupJoin => 'Tengo un código';

  @override
  String get coupleCreateTitle => 'Crear tu pareja';

  @override
  String get coupleCreateNameLabel => 'Nombre de la pareja';

  @override
  String get coupleCreateNameHint => 'Cómo se dicen entre ustedes';

  @override
  String get coupleCreateTimezoneLabel => 'Zona horaria';

  @override
  String get coupleCreateTimezoneHelp =>
      'La zona horaria define cuándo cierra cada semana de la racha. Puedes cambiarla después.';

  @override
  String get coupleCreateSubmit => 'Crear pareja';

  @override
  String get coupleJoinTitle => 'Unirse con un código';

  @override
  String get coupleJoinLabel => 'Código de invitación';

  @override
  String get coupleJoinHelp => 'Seis caracteres, en mayúsculas.';

  @override
  String get coupleJoinSubmit => 'Unirme';

  @override
  String coupleJoinWelcome(String name) {
    return '¡Ya estás dentro! Bienvenida, $name.';
  }

  @override
  String get coupleJoinErrorInvalid => 'Ese código no es válido.';

  @override
  String get coupleJoinErrorExpired =>
      'El código caducó. Pídele a tu pareja que genere uno nuevo.';

  @override
  String get coupleJoinErrorFull => 'Esa pareja ya está completa.';

  @override
  String get coupleJoinErrorAlreadyMember => 'Ya eres parte de esta pareja.';

  @override
  String get coupleJoinErrorAlreadyInCouple => 'Ya perteneces a una pareja.';

  @override
  String get coupleWaitingTitle => 'Esperando a tu pareja';

  @override
  String get coupleWaitingBody =>
      'Comparte este código. Cuando entre, esta pantalla avanza sola.';

  @override
  String get coupleWaitingShare => 'Compartir';

  @override
  String get coupleWaitingCopied => 'Código copiado';

  @override
  String coupleWaitingShareText(String code) {
    return 'Únete a nuestra pareja en Racha con este código: $code';
  }

  @override
  String homeWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '1 semana',
      zero: 'Aún sin semanas',
    );
    return '$_temp0';
  }

  @override
  String get homeStreakLabel => 'racha actual';

  @override
  String get homeWeekCovered => 'Esta semana está cubierta.';

  @override
  String get homeWeekOpen => 'Esta semana aún no registran una cita.';

  @override
  String homeWeekAtRisk(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'quedan $days días',
      one: 'queda 1 día',
    );
    return 'Racha en riesgo — $_temp0 esta semana.';
  }

  @override
  String get homeRecentTitle => 'Citas recientes';

  @override
  String get homeSeeAll => 'Ver todas';

  @override
  String get homeEmptyTitle => 'Su primera semana empieza ahora';

  @override
  String get homeEmptyBody =>
      'Registren una cita a la que fueron juntos y vean la racha empezar.';

  @override
  String get homeLogDate => 'Registrar una cita';

  @override
  String get homeVerifyEmailBanner =>
      'Confirma tu correo para asegurar tu cuenta.';

  @override
  String get dateNewPlaceTitle => '¿A dónde fueron?';

  @override
  String get dateNewSearchHint => 'Busca un lugar';

  @override
  String get dateNewUseNoPlace => 'Sin lugar / en casa';

  @override
  String get dateNewRecent => 'Lugares donde han estado';

  @override
  String get dateNewNext => 'Siguiente';

  @override
  String get dateNewOffline => 'Sin conexión — la búsqueda necesita red.';

  @override
  String get dateDetailsTitle => 'Detalles de la cita';

  @override
  String get dateFieldTitle => 'Título';

  @override
  String get dateFieldWhen => 'Cuándo';

  @override
  String get dateFieldRating => 'Calificación';

  @override
  String get dateFieldNotes => 'Notas';

  @override
  String get dateFieldCost => 'Gasto';

  @override
  String get dateTagBoth => 'Los dos';

  @override
  String get dateTagWarning =>
      'Si quitas a tu pareja, esta cita no cuenta para la racha.';

  @override
  String get dateSave => 'Guardar cita';

  @override
  String get dateSavedStreakUp => '¡La racha avanzó!';

  @override
  String get dateErrorFuture => 'No puedes registrar una cita en el futuro.';

  @override
  String get timelineTitle => 'Nuestras citas';

  @override
  String get timelineEmpty => 'Aún no hay citas. Registra la primera.';

  @override
  String get timelineDoesntCount => 'No cuenta para la racha';

  @override
  String get timelineLoadMore => 'Cargar más';

  @override
  String get dateDetailEdit => 'Editar';

  @override
  String get dateDetailDelete => 'Borrar';

  @override
  String get dateDetailDeleteTitle => '¿Borrar esta cita?';

  @override
  String get dateDetailDeleteBody => 'No se puede deshacer.';

  @override
  String dateDetailDeleteWarnsStreak(int count) {
    return 'Esta cita cuenta para su racha de $count. Borrarla podría bajarla.';
  }

  @override
  String get dateDetailDeleted => 'Cita borrada.';

  @override
  String get dateDetailStreakDropped => 'La racha bajó.';

  @override
  String get dateEditTitle => 'Editar cita';

  @override
  String get dateEditSave => 'Guardar cambios';

  @override
  String get summaryTitle => 'A dónde hemos ido';

  @override
  String get summaryEmpty =>
      'Registren un par de citas y sus lugares aparecerán aquí.';

  @override
  String get summaryDistinctPlaces => 'lugares';

  @override
  String get summaryTotalVisits => 'visitas';

  @override
  String get summaryTotalCost => 'gastado';

  @override
  String summaryFavorite(String name) {
    return 'Favorito: $name';
  }

  @override
  String get summaryByCategory => 'Por categoría';

  @override
  String get summaryOpenMap => 'Abrir mapa';

  @override
  String summaryVisitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visitas',
      one: '1 visita',
    );
    return '$_temp0';
  }

  @override
  String get mapTitle => 'Mapa de lugares';

  @override
  String get mapAttribution => '© colaboradores de OpenStreetMap';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileStreak => 'Racha';

  @override
  String get profileLongest => 'Máxima';

  @override
  String get profileTotalDates => 'Citas';

  @override
  String get profileDaysTogether => 'Días juntos';

  @override
  String get profileDatesByMonth => 'Citas por mes';

  @override
  String get profileMyAccount => 'Mi cuenta';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String get forgotTitle => 'Recupera tu contraseña';

  @override
  String get forgotBody =>
      'Escribe tu correo y te enviamos un enlace para elegir una nueva.';

  @override
  String get forgotSubmit => 'Enviar enlace';

  @override
  String get forgotDone =>
      'Si ese correo tiene cuenta, el enlace va en camino.';

  @override
  String get resetTitle => 'Nueva contraseña';

  @override
  String get resetTokenLabel => 'Código del correo';

  @override
  String get resetNewPassword => 'Nueva contraseña';

  @override
  String get resetSubmit => 'Guardar contraseña';

  @override
  String get resetDone => 'Contraseña actualizada. Inicia sesión con la nueva.';

  @override
  String get resetInvalidToken => 'Ese enlace no es válido o ya se usó.';

  @override
  String get verifyTitle => 'Confirma tu correo';

  @override
  String verifyBody(String email) {
    return 'Enviamos un enlace a $email. Ábrelo para confirmar, o reenvíalo abajo.';
  }

  @override
  String get verifyResend => 'Reenviar';

  @override
  String verifyResendIn(int seconds) {
    return 'Reenviar en ${seconds}s';
  }

  @override
  String get verifySent => 'Enviado. Revisa tu bandeja.';

  @override
  String get verifyDone => 'Correo confirmado.';

  @override
  String get verifyManual => 'Pega el código del correo';

  @override
  String get verifyConfirm => 'Confirmar';

  @override
  String get accountTitle => 'Mi cuenta';

  @override
  String get accountEmail => 'Correo';

  @override
  String get accountVerified => 'Verificado';

  @override
  String get accountUnverified => 'Sin verificar';

  @override
  String get accountVerifyNow => 'Confirmar ahora';

  @override
  String get accountNotifications => 'Notificaciones';

  @override
  String get accountDeleteTitle => 'Borrar cuenta';

  @override
  String get accountDeleteBody =>
      'Tu cuenta está programada para borrarse en 30 días. La app sigue funcionando; puedes cancelar cuando quieras.';

  @override
  String get accountDeleteExplain =>
      'Esto termina la pareja después de 30 días. La racha y las citas de tu pareja se conservan. Escribe tu correo para confirmar.';

  @override
  String get accountDeletePassword =>
      'Contraseña (si iniciaste sesión hace rato)';

  @override
  String get accountDeleteConfirmLabel => 'Escribe tu correo';

  @override
  String get accountDeleteConfirm => 'Programar borrado';

  @override
  String accountDeleteScheduled(String date) {
    return 'Borrado programado para el $date.';
  }

  @override
  String get accountCancelDeletion => 'Cancelar borrado';

  @override
  String get accountDeletionCancelled => 'Borrado cancelado.';

  @override
  String get homeDeletionBanner => 'Tu cuenta está programada para borrarse.';

  @override
  String homeDeletionBannerOn(String date) {
    return 'Tu cuenta se borrará el $date.';
  }

  @override
  String get homeCancelDeletion => 'Cancelar';

  @override
  String get notifTitle => 'Notificaciones';

  @override
  String get notifStreakReminder => 'Recordatorio de racha';

  @override
  String get notifStreakReminderEx =>
      'Sáb y dom: «Su racha sigue viva — una salida este fin de semana y siguen».';

  @override
  String get notifStreakAdvanced => 'La racha avanzó';

  @override
  String get notifTagPending => 'Cita por confirmar';

  @override
  String get notifPartnerActivity => 'Actividad de tu pareja';

  @override
  String get notifWeeklyRecap => 'Resumen semanal';

  @override
  String get notifReminderHour => 'Hora del recordatorio';

  @override
  String get notifQuietHours => 'Horas de silencio';

  @override
  String get notifQuietFrom => 'Desde';

  @override
  String get notifQuietTo => 'Hasta';

  @override
  String get notifPermissionDenied =>
      'Las notificaciones están apagadas en los ajustes del sistema.';

  @override
  String get notifOpenSettings => 'Abrir ajustes';

  @override
  String get notifSaved => 'Guardado.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageAutomatic => 'Automático';

  @override
  String get languageAutomaticHint => 'Sigue el idioma del dispositivo';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get activityTitle => 'Actividad';

  @override
  String get activityEmpty =>
      'Nada por ahora. Aquí verás los recordatorios y la actividad de tu pareja.';

  @override
  String get activityMarkAllRead => 'Marcar todo como leído';

  @override
  String get activityLoadMore => 'Cargar más';

  @override
  String get commonSave => 'Guardar';

  @override
  String get calendarTitle => 'Calendario';

  @override
  String get calendarTabMonth => 'Calendario';

  @override
  String get calendarTabIdeas => 'Ideas';

  @override
  String get calendarNoIdeas =>
      'Aún no hay ideas. Apunta algo que les gustaría hacer.';

  @override
  String get calendarDayEmpty => 'Nada planeado este día.';

  @override
  String get calendarPlanHere => 'Planear algo';

  @override
  String get calendarWeekCovered => 'Esta semana está cubierta';

  @override
  String get calendarWeekPlanned => 'Hay algo planeado esta semana';

  @override
  String get planNewTitle => 'Planear una cita';

  @override
  String get planFieldTitle => '¿Qué van a hacer?';

  @override
  String get planFieldTitleHint => 'p. ej. Cenar, cine, caminar';

  @override
  String get planFieldPlace => 'Lugar (opcional)';

  @override
  String get planFieldPlaceChoose => 'Elegir un lugar';

  @override
  String get planFieldWhen => 'Cuándo (opcional)';

  @override
  String get planFieldPickDate => 'Elegir fecha';

  @override
  String get planFieldAddTime => 'Añadir hora';

  @override
  String get planNoDateHint =>
      '¿Sin fecha? Se guarda como idea hasta que tenga una.';

  @override
  String get planSaveIdea => 'Guardar idea';

  @override
  String get planPropose => 'Proponer plan';

  @override
  String get planSavedProposed => 'Enviado a tu pareja.';

  @override
  String get planSavedIdea => 'Guardado como idea.';

  @override
  String get planErrorPast => 'Esa fecha ya pasó: mejor regístrala como cita.';

  @override
  String get planDetailTitle => 'Plan';

  @override
  String get planStatusIdea => 'Idea';

  @override
  String get planStatusProposed => 'Esperando respuesta';

  @override
  String get planStatusConfirmed => 'Confirmado';

  @override
  String get planStatusDeclined => 'Ahora no';

  @override
  String get planStatusCancelled => 'Cancelado';

  @override
  String get planStatusMissed => 'No fue';

  @override
  String get planStatusCompleted => 'Registrado como cita';

  @override
  String get planProposedByYou => 'Tú lo propusiste';

  @override
  String get planProposedByPartner => 'Tu pareja lo propuso';

  @override
  String get planJoinIn => 'Me apunto';

  @override
  String get planNotNow => 'Ahora no';

  @override
  String get planNotNowHint => '¿Quieres proponer otro día?';

  @override
  String get planDidYouGo => '¿Salieron?';

  @override
  String get planLogAsDate => 'Registrar como cita';

  @override
  String get planEdit => 'Editar';

  @override
  String get planCancel => 'Cancelar plan';

  @override
  String get planCancelConfirm => '¿Cancelar este plan?';

  @override
  String get planCancelBody =>
      'Se queda en el historial para las estadísticas, pero sale del calendario.';

  @override
  String get planResponseConfirmed => 'Confirmado.';

  @override
  String get planResponseDeclined => 'Marcado como ahora no.';

  @override
  String get planViewDate => 'Abrir la cita';

  @override
  String get homeNextPlan => 'Próximo plan';

  @override
  String get homePlanRespond => 'Responder';

  @override
  String homePlansPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planes por responder',
      one: '1 plan por responder',
    );
    return '$_temp0';
  }

  @override
  String get protectTitle => 'Proteger la racha';

  @override
  String get protectSeasonBest => 'Mejor de la temporada';

  @override
  String get protectRecord => 'Mejor histórica';

  @override
  String get protectSeasonMonthly => 'Temporada mensual';

  @override
  String get protectSeasonQuarterly => 'Temporada trimestral';

  @override
  String get protectSeasonInfinite => 'Sin reinicio de temporada';

  @override
  String get protectFreezeQuotaAvailable => 'Queda 1 pausa gratis este mes';

  @override
  String get protectFreezeQuotaUsed => 'Ya usaron la pausa de este mes';

  @override
  String protectActiveFreezeFrom(Object start, Object end) {
    return 'Congelada del $start al $end';
  }

  @override
  String get protectDeclarePause => 'Declarar una pausa';

  @override
  String get protectSaveLastWeek => 'Salvar la semana pasada';

  @override
  String protectPendingMine(Object week) {
    return 'Esperando que tu pareja confirme ($week)';
  }

  @override
  String protectPendingYours(Object week) {
    return 'Tu pareja quiere salvar $week';
  }

  @override
  String get protectCancelFreeze => 'Cancelar pausa';

  @override
  String get protectNothing =>
      'Nada que proteger por ahora — la racha va bien.';

  @override
  String get freezeNewTitle => 'Declarar una pausa';

  @override
  String get freezeReason => 'Motivo';

  @override
  String get freezeReasonTravel => 'Viaje';

  @override
  String get freezeReasonIllness => 'Enfermedad';

  @override
  String get freezeReasonOther => 'Otro';

  @override
  String get freezeFrom => 'Primera semana';

  @override
  String get freezeTo => 'Última semana';

  @override
  String get freezeSubmit => 'Congelar estas semanas';

  @override
  String get freezeErrorQuota => 'Ya usaron la pausa gratis de este mes.';

  @override
  String get freezeErrorWeekComplete =>
      'Una de esas semanas ya tiene una cita.';

  @override
  String get freezeErrorPast => 'Una pausa sólo protege semanas futuras.';

  @override
  String get freezeDone => 'Racha congelada esas semanas.';

  @override
  String get freezeCancelled => 'Pausa cancelada.';

  @override
  String get repairNewTitle => 'Salvar la semana';

  @override
  String get repairBody =>
      'Registra una cita de la semana pasada para salvar la racha. Tu pareja tiene que confirmarla.';

  @override
  String get repairFieldWhen => '¿Cuándo salieron?';

  @override
  String get repairFieldTitle => '¿Qué hicieron?';

  @override
  String get repairSubmit => 'Pedir salvar la semana';

  @override
  String get repairErrorWindow =>
      'Ya pasaron 48 horas desde que cerró esa semana.';

  @override
  String get repairErrorNotClosed =>
      'Esa semana todavía no cierra: regístrala como una cita normal.';

  @override
  String get repairErrorPending =>
      'Ya hay una reparación pendiente para esa semana.';

  @override
  String get repairSent => 'Enviado. Esperando que tu pareja confirme.';

  @override
  String get repairConfirmTitle => 'Confirmar la reparación';

  @override
  String get repairConfirmBody =>
      'Confirmar hace que la cita cuente y rehace la racha. Rechazar la elimina.';

  @override
  String get repairConfirm => 'Sí, salimos';

  @override
  String get repairReject => 'No';

  @override
  String get repairConfirmedToast => 'Confirmado. La racha volvió.';

  @override
  String get repairRejectedToast => 'Rechazado.';

  @override
  String get repairCannotConfirmOwn => 'Esto lo confirma tu pareja.';

  @override
  String get homeStreakFrozen => 'Congelada esta semana';

  @override
  String get homeRepairPending => 'Una reparación espera tu confirmación';

  @override
  String homeSeasonBest(int n) {
    return 'Mejor de la temporada $n';
  }

  @override
  String get wishlistTitle => 'Lista de deseos';

  @override
  String get wishlistEmpty => 'Nada en la lista. Agrega un lugar o una idea.';

  @override
  String get wishlistTabOpen => 'Abiertos';

  @override
  String get wishlistTabPlanned => 'Planificados';

  @override
  String get wishlistTabDone => 'Hechos';

  @override
  String get wishlistRoulette => 'Elige por nosotros';

  @override
  String get wishlistSuggestions => 'Ideas para ustedes';

  @override
  String get wishlistPlanThis => 'Planear esto';

  @override
  String get wishlistMarkDone => 'Marcar hecho';

  @override
  String get wishlistReopen => 'Reabrir';

  @override
  String get wishlistDelete => 'Borrar';

  @override
  String get wishlistDeletePlanned =>
      'Este deseo ya está planificado. ¿Borrar de todos modos?';

  @override
  String get wishNewTitle => 'Agregar a la lista';

  @override
  String get wishFieldTitle => '¿Qué quieren hacer?';

  @override
  String get wishFieldNote => 'Nota (opcional)';

  @override
  String get wishFieldPlace => 'Lugar (opcional)';

  @override
  String get wishFieldCost => 'Costo (opcional)';

  @override
  String get wishCostFree => 'Gratis';

  @override
  String get wishCostLow => 'Barato';

  @override
  String get wishCostMid => 'Medio';

  @override
  String get wishCostHigh => 'Caro';

  @override
  String get wishSaved => 'Agregado a la lista.';

  @override
  String get rouletteTitle => 'Elige por nosotros';

  @override
  String get rouletteSpin => 'Girar';

  @override
  String get rouletteAgain => 'Girar otra vez';

  @override
  String get rouletteCheap => 'Sólo barato';

  @override
  String get rouletteEmpty =>
      'Ningún deseo abierto cumple. Agrega alguno primero.';

  @override
  String get roulettePlanIt => 'Planearlo';

  @override
  String get suggestionsTitle => 'Ideas para ustedes';

  @override
  String get suggestionsCheap => 'Económicas';

  @override
  String get suggestionsEmpty =>
      'Sin ideas por ahora. Registren algunas citas y vuelvan.';

  @override
  String get suggestionAddToList => 'Agregar a la lista';

  @override
  String get homeWishlistCard => 'Qué hacer esta semana';

  @override
  String homeWishlistWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ideas esperando',
      one: '1 idea esperando',
    );
    return '$_temp0';
  }

  @override
  String get mapLayerVisited => 'Visitados';

  @override
  String get mapLayerToVisit => 'Por visitar';

  @override
  String get privacyTitle => 'Privacidad';

  @override
  String get privacyRequireTagConsent => 'Pídeme permiso para etiquetarme';

  @override
  String get privacyRequireTagConsentSub =>
      'Tu pareja tiene que aceptar la etiqueta antes de que la cita te incluya.';

  @override
  String get privacyShareCost => 'Compartir cuánto gastamos';

  @override
  String get privacyShareCostSub =>
      'Al apagarlo se oculta el gasto en todas las citas, pasadas y futuras.';

  @override
  String get privacyNotesPrivate => 'Notas privadas por defecto';

  @override
  String get privacyNotesPrivateSub =>
      'Las notas nuevas solo las ves tú hasta que decidas compartirlas.';

  @override
  String get privacyAnalytics => 'Analítica de uso';

  @override
  String get privacyAnalyticsSub =>
      'Datos anónimos que nos ayudan a mejorar la app.';

  @override
  String get privacyMarketing => 'Correos de producto';

  @override
  String get privacyMarketingSub =>
      'Novedades ocasionales. Nunca más de una vez al mes.';

  @override
  String get privacyExport => 'Exportar mis datos';

  @override
  String get privacyExportSub =>
      'Te enviamos por correo un enlace para descargar todo.';

  @override
  String get privacyExportQueued =>
      'En camino — revisa tu correo en un momento.';

  @override
  String get privacyLeaveCouple => 'Salir de la pareja';

  @override
  String get privacyLeaveCoupleWarning =>
      'La racha y todas las citas compartidas se quedan con la pareja. Vuelves a la pantalla de emparejamiento.';

  @override
  String get privacyLeaveCoupleConfirm => 'Salir';

  @override
  String get privacyDeleteSub => 'Esta acción no se puede deshacer';

  @override
  String get placeDetailUnknown => 'Lugar';

  @override
  String get placeDetailDatesHere => 'Citas aquí';

  @override
  String get placeDetailLogHere => 'Registrar cita aquí';

  @override
  String get placeDetailEmpty => 'Aún no hay citas registradas aquí.';

  @override
  String get placeDetailVisits => 'visitas';

  @override
  String get placeDetailRating => 'calificación';

  @override
  String get placeDetailTotalCost => 'gasto total';

  @override
  String get placeDetailOpen => 'Ver lugar';

  @override
  String get posterTitle => 'Póster del mapa';

  @override
  String get posterSave => 'Guardar imagen';

  @override
  String get posterSaved => 'Póster copiado.';

  @override
  String posterHeadline(int count) {
    return 'Sus $count citas';
  }

  @override
  String posterSubhead(int count) {
    return '$count lugares en el mapa';
  }

  @override
  String get posterPlaces => 'lugares';

  @override
  String get posterDates => 'citas';

  @override
  String get posterSpent => 'gasto';

  @override
  String get milestonesTitle => 'Sus hitos';

  @override
  String get milestonesEmpty =>
      'Registren su primera cita y los hitos empiezan a llenarse.';

  @override
  String get milestonesLatest => 'Último logro';

  @override
  String get milestonesAll => 'Todos los hitos';

  @override
  String get milestonesUnlocked => 'Desbloqueado';

  @override
  String get milestoneFirstDate => 'Primera cita registrada';

  @override
  String milestoneDates(int count) {
    return '$count citas juntos';
  }

  @override
  String milestoneStreak(int weeks) {
    return 'Racha de $weeks semanas';
  }

  @override
  String milestoneDays(int days) {
    return '$days días juntos';
  }

  @override
  String get wrappedEntry => 'Su año en Racha';

  @override
  String get wrappedPrev => 'Anterior';

  @override
  String get wrappedNext => 'Siguiente';

  @override
  String get wrappedIntroTitle => 'Su año en Racha';

  @override
  String get wrappedIntroBody => '¡Fue un gran año juntos!';

  @override
  String get wrappedTotalLabel => 'Total de citas';

  @override
  String wrappedTotalDates(int year) {
    return 'citas en $year';
  }

  @override
  String get wrappedNewPlaces => 'lugares nuevos';

  @override
  String wrappedWeeksShort(int count) {
    return '$count sem';
  }

  @override
  String get wrappedMaxStreak => 'racha máxima';

  @override
  String get wrappedFavCategory => 'Categoría favorita';

  @override
  String wrappedFavCategoryCount(int count, int total) {
    return '$count de sus $total citas';
  }

  @override
  String get wrappedBestMonth => 'Mejor mes';

  @override
  String get wrappedRecap => 'Su resumen';

  @override
  String get wrappedTotalSpend => 'Gasto total';

  @override
  String get homeStreakConsecutive => 'semanas consecutivas';

  @override
  String get homeWeekCoveredCheer => '¡Ya tienen la semana cubierta! 🎉';

  @override
  String get homeStatTotal => 'Total citas';

  @override
  String get homeStatRecord => 'Racha máx';

  @override
  String get homeStatMonth => 'Este mes';

  @override
  String get homeFavPlace => 'Lugar más visitado';

  @override
  String get timelineSearchHint => 'Buscar citas o lugares';

  @override
  String timelineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count citas',
      one: '1 cita',
    );
    return '$_temp0';
  }

  @override
  String get timelineNoMatch => 'Nada coincide con tu búsqueda';

  @override
  String get timelineClearSearch => 'Limpiar búsqueda';

  @override
  String get profileYourCouple => 'su pareja';

  @override
  String profileTogether(int days) {
    return 'Juntos hace $days días';
  }

  @override
  String get profileStatDates => 'citas';

  @override
  String get profileStatStreak => 'racha';

  @override
  String get profileStatRecord => 'récord';

  @override
  String get profileStatBestMonth => 'mejor mes';

  @override
  String get profileCoupleSettings => 'Configuración de la pareja';

  @override
  String get profileCoupleNameRow => 'Nombre de la pareja';

  @override
  String get profileTimezone => 'Zona horaria';

  @override
  String get coupleWeekCloseNote =>
      'Tu semana de racha cierra el domingo por la noche, en la zona horaria de la pareja.';

  @override
  String get profileInviteCode => 'Código de invitación';

  @override
  String get profileCopy => 'Copiar';

  @override
  String get profileCopied => 'Copiado';

  @override
  String get profileEditProfile => 'Editar perfil';

  @override
  String get mapSummary => 'Resumen';

  @override
  String get mapPoster => 'Póster';

  @override
  String get mapView => 'Ver';

  @override
  String get dateDetailLocation => 'Ubicación';

  @override
  String get dateNewStep1 => 'Paso 1 de 2 · Lugar';

  @override
  String get dateNewStep2 => 'Paso 2 de 2 · Detalles';

  @override
  String get dateNewResults => 'Resultados';

  @override
  String get dateRatingHint => 'Toca para calificar';

  @override
  String get calendarLegendDate => 'Cita';

  @override
  String get calendarLegendPlan => 'Plan';

  @override
  String get calendarLegendWeek => 'Semana actual';

  @override
  String get calendarIdeasNoDate => 'Ideas sin fecha';

  @override
  String get calendarAdd => 'Agregar';

  @override
  String get calendarPlanIt => 'Planear';

  @override
  String get protectIntro => 'Usa estas opciones para proteger su racha.';

  @override
  String protectIntroWeeks(int count) {
    return 'Usa estas opciones para proteger sus $count semanas de racha.';
  }

  @override
  String get protectRepairSub =>
      'Registra una cita retroactiva, dentro de 48 h del cierre de la semana.';

  @override
  String get freezeQuotaChip => '1 gratis disponible';

  @override
  String get freezeNoteTitle => '¿Qué pasa con la racha?';

  @override
  String get freezeNoteBody =>
      'Las semanas pausadas no la interrumpen, pero tampoco suman. Después de la pausa, retoma donde la dejaron.';

  @override
  String get repairConfirmNote =>
      'La reparación queda pendiente de que tu pareja la confirme. Ambos deben estar de acuerdo para que cuente.';

  @override
  String get loginSubtitle => 'de vuelta a tu racha';

  @override
  String get registerSubtitle => 'y empieza tu racha hoy';

  @override
  String get onboardingSkip => 'Saltar';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get pwWeak => 'Débil';

  @override
  String get pwFair => 'Regular';

  @override
  String get pwGood => 'Buena';

  @override
  String get pwStrong => 'Fuerte';

  @override
  String get pwReqMin8 => 'Al menos 8 caracteres';

  @override
  String get pwReqUpper => 'Al menos una mayúscula';

  @override
  String get pwReqNumber => 'Al menos un número';

  @override
  String get forgotDoneTitle => 'Revisa tu correo';

  @override
  String get forgotOauthNote =>
      'Si entraste con Google o Apple, usa ese mismo método para acceder.';

  @override
  String get resetWarning =>
      'Al cambiar la contraseña se cerrarán todas las sesiones en otros dispositivos.';

  @override
  String get resetConfirmLabel => 'Repetir contraseña';

  @override
  String get resetMismatch => 'Las contraseñas no coinciden';

  @override
  String get verifyAlreadyDone => 'Ya verifiqué';

  @override
  String get verifyBlockedTitle => 'Sin verificar no puedes:';

  @override
  String get verifyBlocked1 => 'Registrar citas';

  @override
  String get verifyBlocked2 => 'Crear o unirte a una pareja';

  @override
  String get verifyBlocked3 => 'Recibir notificaciones';

  @override
  String get coupleSetupSubtitle => 'Conéctala para empezar la racha';

  @override
  String get coupleSetupCreateSub =>
      'Tú creas el espacio y compartes el código';

  @override
  String get coupleSetupJoinSub => 'Tu pareja ya creó el espacio';

  @override
  String get coupleJoinInstruction =>
      'Pide a tu pareja el código de 6 caracteres';

  @override
  String get coupleWaitingCodeLabel => 'Código de invitación';

  @override
  String get coupleWaitingTapToCopy => 'Toca para copiar';

  @override
  String get coupleWaitingPolling => 'Esperando…';

  @override
  String get planHasDate => '¿Tienen fecha?';

  @override
  String get planHasDateSub => 'Sin fecha se guarda como idea';

  @override
  String get planNoteIdea =>
      'Se guardará como idea en la pestaña Ideas del calendario.';

  @override
  String get planNoteProposed =>
      'Tu pareja recibirá un aviso para confirmar el plan.';

  @override
  String get navHome => 'Inicio';

  @override
  String get navDates => 'Citas';

  @override
  String get navMap => 'Mapa';

  @override
  String get navProfile => 'Perfil';
}
