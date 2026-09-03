// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Racha';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Password';

  @override
  String get commonDisplayName => 'Your name';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonRetry => 'Retry';

  @override
  String get a11yBack => 'Back';

  @override
  String get a11yCalendar => 'Open calendar';

  @override
  String get a11yNotifications => 'Notifications';

  @override
  String a11yNotificationsUnread(int count) {
    return 'Notifications, $count unread';
  }

  @override
  String get a11yClearSearch => 'Clear search';

  @override
  String get a11yPreviousMonth => 'Previous month';

  @override
  String get a11yNextMonth => 'Next month';

  @override
  String get a11yMoreOptions => 'More options';

  @override
  String get a11yWeekStrip => 'Streak over the last 12 weeks';

  @override
  String a11yRatingStars(int rating) {
    return '$rating of 5 stars';
  }

  @override
  String a11yCategoryShare(String category, String percent) {
    return '$category: $percent%';
  }

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSomethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get commonNoConnection =>
      'No connection. Check your network and try again.';

  @override
  String get onboardingTitle1 => 'Go out together';

  @override
  String get onboardingBody1 =>
      'Plan a date every week and make the time count.';

  @override
  String get onboardingTitle2 => 'Log where you went';

  @override
  String get onboardingBody2 =>
      'Save the place, a rating and a memory for each date.';

  @override
  String get onboardingTitle3 => 'Keep the streak alive';

  @override
  String get onboardingBody3 => 'One date a week keeps your streak growing.';

  @override
  String get onboardingCreateAccount => 'Create account';

  @override
  String get onboardingSignIn => 'I already have an account';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get loginNoAccount => 'Don\'t have an account? Sign up';

  @override
  String get loginInvalidCredentials => 'Email or password is incorrect.';

  @override
  String loginPasswordNotSet(String provider) {
    return 'This account was created with $provider. Sign in with that provider.';
  }

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerSubmit => 'Create account';

  @override
  String get registerHaveAccount => 'Already have an account? Sign in';

  @override
  String get registerPasswordHint => 'At least 8 characters';

  @override
  String get registerEmailTaken => 'That email is already registered.';

  @override
  String get validationEmailRequired => 'Enter your email';

  @override
  String get validationEmailInvalid => 'Enter a valid email';

  @override
  String get validationPasswordRequired => 'Enter your password';

  @override
  String get validationPasswordTooShort => 'Use at least 8 characters';

  @override
  String get validationNameRequired => 'Enter your name';

  @override
  String get splashTagline => 'One date a week.';

  @override
  String get coupleSetupTitle => 'You and your person';

  @override
  String get coupleSetupBody =>
      'A streak needs two. Create your couple or join with the code your partner shared.';

  @override
  String get coupleSetupCreate => 'Create our couple';

  @override
  String get coupleSetupJoin => 'I have a code';

  @override
  String get coupleCreateTitle => 'Create your couple';

  @override
  String get coupleCreateNameLabel => 'Couple name';

  @override
  String get coupleCreateNameHint => 'How you two call yourselves';

  @override
  String get coupleCreateTimezoneLabel => 'Time zone';

  @override
  String get coupleCreateTimezoneHelp =>
      'The time zone decides when each streak week closes. You can change it later.';

  @override
  String get coupleCreateSubmit => 'Create couple';

  @override
  String get coupleJoinTitle => 'Join with a code';

  @override
  String get coupleJoinLabel => 'Invite code';

  @override
  String get coupleJoinHelp => 'Six characters, uppercase.';

  @override
  String get coupleJoinSubmit => 'Join';

  @override
  String coupleJoinWelcome(String name) {
    return 'You\'re in! Welcome, $name.';
  }

  @override
  String get coupleJoinErrorInvalid => 'That code isn\'t valid.';

  @override
  String get coupleJoinErrorExpired =>
      'The code expired. Ask your partner for a new one.';

  @override
  String get coupleJoinErrorFull => 'That couple is already complete.';

  @override
  String get coupleJoinErrorAlreadyMember =>
      'You\'re already part of this couple.';

  @override
  String get coupleJoinErrorAlreadyInCouple =>
      'You already belong to a couple.';

  @override
  String get coupleWaitingTitle => 'Waiting for your partner';

  @override
  String get coupleWaitingBody =>
      'Share this code. When they join, this screen moves on by itself.';

  @override
  String get coupleWaitingShare => 'Share';

  @override
  String get coupleWaitingCopied => 'Code copied';

  @override
  String coupleWaitingShareText(String code) {
    return 'Join our couple on Racha with this code: $code';
  }

  @override
  String homeWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks',
      one: '1 week',
      zero: 'No weeks yet',
    );
    return '$_temp0';
  }

  @override
  String get homeStreakLabel => 'current streak';

  @override
  String get homeWeekCovered => 'This week is covered.';

  @override
  String get homeWeekOpen => 'No date logged this week yet.';

  @override
  String homeWeekAtRisk(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days left',
      one: '1 day left',
    );
    return 'Streak at risk — $_temp0 this week.';
  }

  @override
  String get homeRecentTitle => 'Recent dates';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get homeEmptyTitle => 'Your first week starts now';

  @override
  String get homeEmptyBody =>
      'Log a date you went on together and watch the streak begin.';

  @override
  String get homeLogDate => 'Log a date';

  @override
  String get homeVerifyEmailBanner =>
      'Confirm your email to secure your account.';

  @override
  String get dateNewPlaceTitle => 'Where did you go?';

  @override
  String get dateNewSearchHint => 'Search a place';

  @override
  String get dateNewUseNoPlace => 'No place / at home';

  @override
  String get dateNewRecent => 'Places you\'ve been';

  @override
  String get dateNewNext => 'Next';

  @override
  String get dateNewOffline => 'No connection — search needs the network.';

  @override
  String get dateDetailsTitle => 'Date details';

  @override
  String get dateFieldTitle => 'Title';

  @override
  String get dateFieldWhen => 'When';

  @override
  String get dateFieldRating => 'Rating';

  @override
  String get dateFieldNotes => 'Notes';

  @override
  String get dateFieldCost => 'Cost';

  @override
  String get dateTagBoth => 'Both of you';

  @override
  String get dateTagWarning =>
      'If you remove your partner, this date won\'t count toward the streak.';

  @override
  String get dateSave => 'Save date';

  @override
  String get dateSavedStreakUp => 'Streak advanced!';

  @override
  String get dateErrorFuture => 'You can\'t log a date in the future.';

  @override
  String get timelineTitle => 'Our dates';

  @override
  String get timelineEmpty => 'No dates yet. Log your first one.';

  @override
  String get timelineDoesntCount => 'Doesn\'t count toward the streak';

  @override
  String get timelineLoadMore => 'Load more';

  @override
  String get dateDetailEdit => 'Edit';

  @override
  String get dateDetailDelete => 'Delete';

  @override
  String get dateDetailDeleteTitle => 'Delete this date?';

  @override
  String get dateDetailDeleteBody => 'This can\'t be undone.';

  @override
  String dateDetailDeleteWarnsStreak(int count) {
    return 'This date counts toward your streak of $count. Deleting it may lower it.';
  }

  @override
  String get dateDetailDeleted => 'Date deleted.';

  @override
  String get dateDetailStreakDropped => 'The streak dropped.';

  @override
  String get dateEditTitle => 'Edit date';

  @override
  String get dateEditSave => 'Save changes';

  @override
  String get summaryTitle => 'Where we\'ve been';

  @override
  String get summaryEmpty =>
      'Log a couple of dates and your places will show up here.';

  @override
  String get summaryDistinctPlaces => 'places';

  @override
  String get summaryTotalVisits => 'visits';

  @override
  String get summaryTotalCost => 'spent';

  @override
  String summaryFavorite(String name) {
    return 'Favourite: $name';
  }

  @override
  String get summaryByCategory => 'By category';

  @override
  String get summaryOpenMap => 'Open map';

  @override
  String summaryVisitsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count visits',
      one: '1 visit',
    );
    return '$_temp0';
  }

  @override
  String get mapTitle => 'Places map';

  @override
  String get mapAttribution => '© OpenStreetMap contributors';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileStreak => 'Streak';

  @override
  String get profileLongest => 'Longest';

  @override
  String get profileTotalDates => 'Dates';

  @override
  String get profileDaysTogether => 'Days together';

  @override
  String get profileDatesByMonth => 'Dates per month';

  @override
  String get profileMyAccount => 'My account';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignOutWarning =>
      'You will need to sign in again on this device. Your dates and streak are untouched.';

  @override
  String get profileSignOutConfirm => 'Sign out';

  @override
  String get forgotTitle => 'Recover your password';

  @override
  String get forgotBody =>
      'Enter your email and we\'ll send a link to choose a new password.';

  @override
  String get forgotSubmit => 'Send link';

  @override
  String get forgotDone =>
      'If that email has an account, a link is on its way.';

  @override
  String get resetTitle => 'New password';

  @override
  String get resetTokenLabel => 'Code from the email';

  @override
  String get resetNewPassword => 'New password';

  @override
  String get resetSubmit => 'Set password';

  @override
  String get resetDone => 'Password updated. Sign in with your new password.';

  @override
  String get resetInvalidToken => 'That link isn\'t valid or was already used.';

  @override
  String get verifyTitle => 'Confirm your email';

  @override
  String verifyBody(String email) {
    return 'We sent a link to $email. Open it to confirm, or resend below.';
  }

  @override
  String get verifyResend => 'Resend';

  @override
  String verifyResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get verifySent => 'Sent. Check your inbox.';

  @override
  String get verifyDone => 'Email confirmed.';

  @override
  String get verifyManual => 'Paste the code from the email';

  @override
  String get verifyConfirm => 'Confirm';

  @override
  String get accountTitle => 'My account';

  @override
  String get accountEmail => 'Email';

  @override
  String get accountVerified => 'Verified';

  @override
  String get accountUnverified => 'Not verified';

  @override
  String get accountVerifyNow => 'Confirm now';

  @override
  String get accountNotifications => 'Notifications';

  @override
  String get accountDeleteTitle => 'Delete account';

  @override
  String get accountDeleteBody =>
      'Your account is scheduled for deletion in 30 days. The app keeps working until then; you can cancel any time.';

  @override
  String get accountDeleteExplain =>
      'This ends the couple after 30 days. Your partner\'s streak and dates are kept. Type your email to confirm.';

  @override
  String get accountDeletePassword => 'Password (if you signed in a while ago)';

  @override
  String get accountDeleteConfirmLabel => 'Type your email';

  @override
  String get accountDeleteConfirm => 'Schedule deletion';

  @override
  String accountDeleteScheduled(String date) {
    return 'Deletion scheduled for $date.';
  }

  @override
  String get accountCancelDeletion => 'Cancel deletion';

  @override
  String get accountDeletionCancelled => 'Deletion cancelled.';

  @override
  String get homeDeletionBanner => 'Your account is scheduled for deletion.';

  @override
  String homeDeletionBannerOn(String date) {
    return 'Your account will be deleted on $date.';
  }

  @override
  String get homeCancelDeletion => 'Cancel';

  @override
  String get notifTitle => 'Notifications';

  @override
  String get notifStreakReminder => 'Streak reminder';

  @override
  String get notifStreakReminderEx =>
      'Sat & Sun: \"Your streak is still going — one outing this weekend keeps it.\"';

  @override
  String get notifStreakAdvanced => 'Streak advanced';

  @override
  String get notifTagPending => 'Date to confirm';

  @override
  String get notifPartnerActivity => 'Partner activity';

  @override
  String get notifWeeklyRecap => 'Weekly recap';

  @override
  String get notifReminderHour => 'Reminder time';

  @override
  String get notifQuietHours => 'Quiet hours';

  @override
  String get notifQuietFrom => 'From';

  @override
  String get notifQuietTo => 'To';

  @override
  String get notifPermissionDenied =>
      'Notifications are off in system settings.';

  @override
  String get notifOpenSettings => 'Open settings';

  @override
  String get notifSaved => 'Saved.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageAutomatic => 'Automatic';

  @override
  String get languageAutomaticHint => 'Follow the device language';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activityEmpty =>
      'Nothing here yet. Reminders and your partner\'s activity will show up here.';

  @override
  String get activityMarkAllRead => 'Mark all read';

  @override
  String get activityLoadMore => 'Load more';

  @override
  String get commonSave => 'Save';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get calendarTabMonth => 'Calendar';

  @override
  String get calendarTabIdeas => 'Ideas';

  @override
  String get calendarNoIdeas =>
      'No ideas yet. Jot down something you\'d like to do.';

  @override
  String get calendarDayEmpty => 'Nothing planned this day.';

  @override
  String get calendarPlanHere => 'Plan something';

  @override
  String get calendarWeekCovered => 'This week is covered';

  @override
  String get calendarWeekPlanned => 'Something planned this week';

  @override
  String get planNewTitle => 'Plan a date';

  @override
  String get planFieldTitle => 'What\'s the plan?';

  @override
  String get planFieldTitleHint => 'e.g. Dinner, a movie, a walk';

  @override
  String get planFieldPlace => 'Place (optional)';

  @override
  String get planFieldPlaceChoose => 'Choose a place';

  @override
  String get planFieldWhen => 'When (optional)';

  @override
  String get planFieldPickDate => 'Pick a date';

  @override
  String get planFieldAddTime => 'Add a time';

  @override
  String get planNoDateHint =>
      'No date? It\'s kept as an idea until it gets one.';

  @override
  String get planSaveIdea => 'Save idea';

  @override
  String get planPropose => 'Propose plan';

  @override
  String get planSavedProposed => 'Sent to your partner.';

  @override
  String get planSavedIdea => 'Saved as an idea.';

  @override
  String get planErrorPast =>
      'That date has already passed — log it as a date instead.';

  @override
  String get planDetailTitle => 'Plan';

  @override
  String get planStatusIdea => 'Idea';

  @override
  String get planStatusProposed => 'Waiting for a reply';

  @override
  String get planStatusConfirmed => 'Confirmed';

  @override
  String get planStatusDeclined => 'Not this time';

  @override
  String get planStatusCancelled => 'Cancelled';

  @override
  String get planStatusMissed => 'Didn\'t happen';

  @override
  String get planStatusCompleted => 'Logged as a date';

  @override
  String get planProposedByYou => 'You proposed this';

  @override
  String get planProposedByPartner => 'Your partner proposed this';

  @override
  String get planJoinIn => 'I\'m in';

  @override
  String get planNotNow => 'Not now';

  @override
  String get planNotNowHint => 'Want to suggest another day?';

  @override
  String get planDidYouGo => 'Did you go out?';

  @override
  String get planLogAsDate => 'Log it as a date';

  @override
  String get planEdit => 'Edit';

  @override
  String get planCancel => 'Cancel plan';

  @override
  String get planCancelConfirm => 'Cancel this plan?';

  @override
  String get planCancelBody =>
      'It stays in the history for the stats, but leaves the calendar.';

  @override
  String get planResponseConfirmed => 'You\'re in.';

  @override
  String get planResponseDeclined => 'Marked as not this time.';

  @override
  String get planViewDate => 'Open the date';

  @override
  String get homeNextPlan => 'Next plan';

  @override
  String get homePlanRespond => 'Respond';

  @override
  String homePlansPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans to answer',
      one: '1 plan to answer',
    );
    return '$_temp0';
  }

  @override
  String get protectTitle => 'Protect the streak';

  @override
  String get protectSeasonBest => 'Season best';

  @override
  String get protectRecord => 'All-time best';

  @override
  String get protectSeasonMonthly => 'Monthly season';

  @override
  String get protectSeasonQuarterly => 'Quarterly season';

  @override
  String get protectSeasonInfinite => 'No season reset';

  @override
  String get protectFreezeQuotaAvailable => '1 free pause left this month';

  @override
  String get protectFreezeQuotaUsed => 'This month\'s pause is used';

  @override
  String protectActiveFreezeFrom(Object start, Object end) {
    return 'Frozen $start to $end';
  }

  @override
  String get protectDeclarePause => 'Declare a pause';

  @override
  String get protectSaveLastWeek => 'Save last week';

  @override
  String protectPendingMine(Object week) {
    return 'Waiting for your partner to confirm ($week)';
  }

  @override
  String protectPendingYours(Object week) {
    return 'Your partner wants to save $week';
  }

  @override
  String get protectCancelFreeze => 'Cancel pause';

  @override
  String get protectNothing =>
      'Nothing to protect right now — the streak is on track.';

  @override
  String get freezeNewTitle => 'Declare a pause';

  @override
  String get freezeReason => 'Reason';

  @override
  String get freezeReasonTravel => 'Travel';

  @override
  String get freezeReasonIllness => 'Illness';

  @override
  String get freezeReasonOther => 'Other';

  @override
  String get freezeFrom => 'First week';

  @override
  String get freezeTo => 'Last week';

  @override
  String get freezeSubmit => 'Freeze these weeks';

  @override
  String get freezeErrorQuota =>
      'You\'ve already used this month\'s free pause.';

  @override
  String get freezeErrorWeekComplete =>
      'One of those weeks already has a date.';

  @override
  String get freezeErrorPast => 'A pause only protects future weeks.';

  @override
  String get freezeDone => 'Streak frozen for those weeks.';

  @override
  String get freezeCancelled => 'Pause cancelled.';

  @override
  String get repairNewTitle => 'Save the week';

  @override
  String get repairBody =>
      'Log a date from last week to save the streak. Your partner has to confirm it.';

  @override
  String get repairFieldWhen => 'When did you go out?';

  @override
  String get repairFieldTitle => 'What did you do?';

  @override
  String get repairSubmit => 'Ask to save the week';

  @override
  String get repairErrorWindow => 'It\'s been over 48h since that week closed.';

  @override
  String get repairErrorNotClosed =>
      'That week hasn\'t closed yet — log it as a normal date.';

  @override
  String get repairErrorPending =>
      'There\'s already a repair pending for that week.';

  @override
  String get repairSent => 'Sent. Waiting for your partner to confirm.';

  @override
  String get repairConfirmTitle => 'Confirm the repair';

  @override
  String get repairConfirmBody =>
      'Confirming makes the date count and rebuilds the streak. Rejecting removes it.';

  @override
  String get repairConfirm => 'Yes, we went out';

  @override
  String get repairReject => 'No';

  @override
  String get repairConfirmedToast => 'Confirmed. The streak is back.';

  @override
  String get repairRejectedToast => 'Rejected.';

  @override
  String get repairCannotConfirmOwn => 'Your partner confirms this one.';

  @override
  String get homeStreakFrozen => 'Frozen this week';

  @override
  String get homeRepairPending => 'A repair needs your confirmation';

  @override
  String homeSeasonBest(int n) {
    return 'Season best $n';
  }

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistEmpty =>
      'Nothing on the list yet. Add a place or an idea.';

  @override
  String get wishlistTabOpen => 'Open';

  @override
  String get wishlistTabPlanned => 'Planned';

  @override
  String get wishlistTabDone => 'Done';

  @override
  String get wishlistRoulette => 'Pick for us';

  @override
  String get wishlistSuggestions => 'Ideas for you';

  @override
  String get wishlistPlanThis => 'Plan this';

  @override
  String get wishlistMarkDone => 'Mark done';

  @override
  String get wishlistReopen => 'Reopen';

  @override
  String get wishlistDelete => 'Delete';

  @override
  String get wishlistDeletePlanned =>
      'This wish is already planned. Delete anyway?';

  @override
  String get wishlistDeleteConfirm => 'Remove this wish from the list?';

  @override
  String get wishNewTitle => 'Add to the list';

  @override
  String get wishFieldTitle => 'What do you want to do?';

  @override
  String get wishFieldNote => 'Note (optional)';

  @override
  String get wishFieldPlace => 'Place (optional)';

  @override
  String get wishFieldCost => 'Cost (optional)';

  @override
  String get wishCostFree => 'Free';

  @override
  String get wishCostLow => 'Cheap';

  @override
  String get wishCostMid => 'Mid';

  @override
  String get wishCostHigh => 'Pricey';

  @override
  String get wishSaved => 'Added to the list.';

  @override
  String get rouletteTitle => 'Pick for us';

  @override
  String get rouletteSpin => 'Spin';

  @override
  String get rouletteAgain => 'Spin again';

  @override
  String get rouletteCheap => 'Cheap only';

  @override
  String get rouletteEmpty => 'No open wishes match. Add some first.';

  @override
  String get roulettePlanIt => 'Plan it';

  @override
  String get suggestionsTitle => 'Ideas for you';

  @override
  String get suggestionsCheap => 'Budget-friendly';

  @override
  String get suggestionsEmpty =>
      'No ideas right now. Log a few dates and check back.';

  @override
  String get suggestionAddToList => 'Add to the list';

  @override
  String get homeWishlistCard => 'What to do this week';

  @override
  String homeWishlistWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ideas waiting',
      one: '1 idea waiting',
    );
    return '$_temp0';
  }

  @override
  String get mapLayerVisited => 'Visited';

  @override
  String get mapLayerToVisit => 'To visit';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyRequireTagConsent => 'Ask before tagging me';

  @override
  String get privacyRequireTagConsentSub =>
      'Your partner has to accept a tag before a date counts you in.';

  @override
  String get privacyShareCost => 'Share what we spend';

  @override
  String get privacyShareCostSub =>
      'Off hides the cost on every date, past and future.';

  @override
  String get privacyNotesPrivate => 'Keep notes private by default';

  @override
  String get privacyNotesPrivateSub =>
      'New notes are visible only to you until you share them.';

  @override
  String get privacyAnalytics => 'Usage analytics';

  @override
  String get privacyAnalyticsSub =>
      'Anonymous data that helps us improve the app.';

  @override
  String get privacyMarketing => 'Product emails';

  @override
  String get privacyMarketingSub =>
      'Occasional news about new features. Never more than once a month.';

  @override
  String get privacyExport => 'Export my data';

  @override
  String get privacyExportSub => 'We email you a link to download everything.';

  @override
  String get privacyExportQueued => 'On its way — check your email shortly.';

  @override
  String get privacyLeaveCouple => 'Leave the couple';

  @override
  String get privacyLeaveCoupleWarning =>
      'The streak and every shared date stay with the couple. You go back to the pairing screen.';

  @override
  String get privacyLeaveCoupleConfirm => 'Leave';

  @override
  String get privacyDeleteSub => 'This can\'t be undone';

  @override
  String get placeDetailUnknown => 'Place';

  @override
  String get placeDetailDatesHere => 'Dates here';

  @override
  String get placeDetailLogHere => 'Log a date here';

  @override
  String get placeDetailEmpty => 'No dates logged here yet.';

  @override
  String get placeDetailVisits => 'visits';

  @override
  String get placeDetailRating => 'rating';

  @override
  String get placeDetailTotalCost => 'total spent';

  @override
  String get placeDetailOpen => 'Open place';

  @override
  String get posterTitle => 'Map poster';

  @override
  String get posterSave => 'Save image';

  @override
  String get posterSaved => 'Poster copied.';

  @override
  String posterHeadline(int count) {
    return 'Your $count dates';
  }

  @override
  String posterSubhead(int count) {
    return '$count places on the map';
  }

  @override
  String get posterPlaces => 'places';

  @override
  String get posterDates => 'dates';

  @override
  String get posterSpent => 'spent';

  @override
  String get milestonesTitle => 'Your milestones';

  @override
  String get milestonesEmpty =>
      'Log your first date and the milestones start filling in.';

  @override
  String get milestonesLatest => 'Latest';

  @override
  String get milestonesAll => 'All milestones';

  @override
  String get milestonesUnlocked => 'Unlocked';

  @override
  String get milestoneFirstDate => 'First date logged';

  @override
  String milestoneDates(int count) {
    return '$count dates together';
  }

  @override
  String milestoneStreak(int weeks) {
    return '$weeks-week streak';
  }

  @override
  String milestoneDays(int days) {
    return '$days days together';
  }

  @override
  String get wrappedEntry => 'Your year in Racha';

  @override
  String get wrappedPrev => 'Back';

  @override
  String get wrappedNext => 'Next';

  @override
  String get wrappedIntroTitle => 'Your year in Racha';

  @override
  String get wrappedIntroBody => 'What a year together.';

  @override
  String get wrappedTotalLabel => 'Total dates';

  @override
  String wrappedTotalDates(int year) {
    return 'dates in $year';
  }

  @override
  String get wrappedNewPlaces => 'new places';

  @override
  String wrappedWeeksShort(int count) {
    return '${count}w';
  }

  @override
  String get wrappedMaxStreak => 'longest streak';

  @override
  String get wrappedFavCategory => 'Favourite category';

  @override
  String wrappedFavCategoryCount(int count, int total) {
    return '$count of your $total dates';
  }

  @override
  String get wrappedBestMonth => 'Best month';

  @override
  String get wrappedRecap => 'Your recap';

  @override
  String get wrappedTotalSpend => 'Total spent';

  @override
  String get homeStreakConsecutive => 'weeks in a row';

  @override
  String get homeWeekCoveredCheer => 'This week is covered! 🎉';

  @override
  String get homeStatTotal => 'Total dates';

  @override
  String get homeStatRecord => 'Best streak';

  @override
  String get homeStatMonth => 'This month';

  @override
  String get homeFavPlace => 'Most visited place';

  @override
  String get timelineSearchHint => 'Search dates or places';

  @override
  String timelineCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dates',
      one: '1 date',
    );
    return '$_temp0';
  }

  @override
  String get timelineNoMatch => 'Nothing matches your search';

  @override
  String get timelineClearSearch => 'Clear search';

  @override
  String get profileYourCouple => 'your couple';

  @override
  String profileTogether(int days) {
    return 'Together for $days days';
  }

  @override
  String get profileStatDates => 'dates';

  @override
  String get profileStatStreak => 'streak';

  @override
  String get profileStatRecord => 'record';

  @override
  String get profileStatBestMonth => 'best month';

  @override
  String get profileCoupleSettings => 'Couple settings';

  @override
  String get profileCoupleNameRow => 'Couple name';

  @override
  String get profileTimezone => 'Time zone';

  @override
  String get coupleWeekCloseNote =>
      'Your streak week closes on Sunday night, in your couple\'s time zone.';

  @override
  String get profileInviteCode => 'Invite code';

  @override
  String get profileCopy => 'Copy';

  @override
  String get profileCopied => 'Copied';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get mapSummary => 'Summary';

  @override
  String get mapPoster => 'Poster';

  @override
  String get mapView => 'View';

  @override
  String get dateDetailLocation => 'Location';

  @override
  String get dateNewStep1 => 'Step 1 of 2 · Place';

  @override
  String get dateNewStep2 => 'Step 2 of 2 · Details';

  @override
  String get dateNewResults => 'Results';

  @override
  String get dateRatingHint => 'Tap to rate';

  @override
  String get calendarLegendDate => 'Date';

  @override
  String get calendarLegendPlan => 'Plan';

  @override
  String get calendarLegendWeek => 'This week';

  @override
  String get calendarIdeasNoDate => 'Ideas without a date';

  @override
  String get calendarAdd => 'Add';

  @override
  String get calendarPlanIt => 'Plan it';

  @override
  String get protectIntro => 'Use these to protect your streak.';

  @override
  String protectIntroWeeks(int count) {
    return 'Use these to protect your $count-week streak.';
  }

  @override
  String get protectRepairSub =>
      'Log a backdated date, within 48h of the week closing.';

  @override
  String get freezeQuotaChip => '1 free available';

  @override
  String get freezeNoteTitle => 'What happens to the streak?';

  @override
  String get freezeNoteBody =>
      'Paused weeks don\'t break it, but they don\'t add either. After the pause it picks up where you left off.';

  @override
  String get repairConfirmNote =>
      'The repair stays pending your partner\'s confirmation. You both have to agree for it to count.';

  @override
  String get loginSubtitle => 'back to your streak';

  @override
  String get registerSubtitle => 'start your streak today';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get pwWeak => 'Weak';

  @override
  String get pwFair => 'Fair';

  @override
  String get pwGood => 'Good';

  @override
  String get pwStrong => 'Strong';

  @override
  String get pwReqMin8 => 'At least 8 characters';

  @override
  String get pwReqUpper => 'At least one capital letter';

  @override
  String get pwReqNumber => 'At least one number';

  @override
  String get forgotDoneTitle => 'Check your email';

  @override
  String get forgotOauthNote =>
      'If you signed up with Google or Apple, use that same method to get in.';

  @override
  String get resetWarning =>
      'Changing your password signs out every other device.';

  @override
  String get resetConfirmLabel => 'Repeat password';

  @override
  String get resetMismatch => 'The passwords don\'t match';

  @override
  String get verifyAlreadyDone => 'I\'ve verified';

  @override
  String get verifyBlockedTitle => 'Until you verify, you can\'t:';

  @override
  String get verifyBlocked1 => 'Log dates';

  @override
  String get verifyBlocked2 => 'Create or join a couple';

  @override
  String get verifyBlocked3 => 'Get notifications';

  @override
  String get coupleSetupSubtitle => 'Connect it to start the streak';

  @override
  String get coupleSetupCreateSub => 'You make the space and share the code';

  @override
  String get coupleSetupJoinSub => 'Your partner already made it';

  @override
  String get coupleJoinInstruction =>
      'Ask your partner for the 6-character code';

  @override
  String get coupleWaitingCodeLabel => 'Invite code';

  @override
  String get coupleWaitingTapToCopy => 'Tap to copy';

  @override
  String get coupleWaitingPolling => 'Waiting…';

  @override
  String get planHasDate => 'Have a date?';

  @override
  String get planHasDateSub => 'With no date it\'s saved as an idea';

  @override
  String get planNoteIdea =>
      'It\'s saved as an idea in the calendar\'s Ideas tab.';

  @override
  String get planNoteProposed =>
      'Your partner gets a nudge to confirm the plan.';

  @override
  String get navHome => 'Home';

  @override
  String get navDates => 'Dates';

  @override
  String get navMap => 'Map';

  @override
  String get navProfile => 'Profile';
}
