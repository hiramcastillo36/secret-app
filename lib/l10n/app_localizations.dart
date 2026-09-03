import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Racha'**
  String get appTitle;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @commonDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get commonDisplayName;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get commonSomethingWentWrong;

  /// No description provided for @commonNoConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get commonNoConnection;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Go out together'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Plan a date every week and make the time count.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Log where you went'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Save the place, a rating and a memory for each date.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Keep the streak alive'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'One date a week keeps your streak growing.'**
  String get onboardingBody3;

  /// No description provided for @onboardingCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get onboardingCreateAccount;

  /// No description provided for @onboardingSignIn.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingSignIn;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubmit.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSubmit;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get loginNoAccount;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email or password is incorrect.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginPasswordNotSet.
  ///
  /// In en, this message translates to:
  /// **'This account was created with {provider}. Sign in with that provider.'**
  String loginPasswordNotSet(String provider);

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get registerTitle;

  /// No description provided for @registerSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerSubmit;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get registerHaveAccount;

  /// No description provided for @registerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get registerPasswordHint;

  /// No description provided for @registerEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'That email is already registered.'**
  String get registerEmailTaken;

  /// No description provided for @validationEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get validationPasswordTooShort;

  /// No description provided for @validationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get validationNameRequired;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'One date a week.'**
  String get splashTagline;

  /// No description provided for @coupleSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'You and your person'**
  String get coupleSetupTitle;

  /// No description provided for @coupleSetupBody.
  ///
  /// In en, this message translates to:
  /// **'A streak needs two. Create your couple or join with the code your partner shared.'**
  String get coupleSetupBody;

  /// No description provided for @coupleSetupCreate.
  ///
  /// In en, this message translates to:
  /// **'Create our couple'**
  String get coupleSetupCreate;

  /// No description provided for @coupleSetupJoin.
  ///
  /// In en, this message translates to:
  /// **'I have a code'**
  String get coupleSetupJoin;

  /// No description provided for @coupleCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your couple'**
  String get coupleCreateTitle;

  /// No description provided for @coupleCreateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Couple name'**
  String get coupleCreateNameLabel;

  /// No description provided for @coupleCreateNameHint.
  ///
  /// In en, this message translates to:
  /// **'How you two call yourselves'**
  String get coupleCreateNameHint;

  /// No description provided for @coupleCreateTimezoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get coupleCreateTimezoneLabel;

  /// No description provided for @coupleCreateTimezoneHelp.
  ///
  /// In en, this message translates to:
  /// **'The time zone decides when each streak week closes. You can change it later.'**
  String get coupleCreateTimezoneHelp;

  /// No description provided for @coupleCreateSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create couple'**
  String get coupleCreateSubmit;

  /// No description provided for @coupleJoinTitle.
  ///
  /// In en, this message translates to:
  /// **'Join with a code'**
  String get coupleJoinTitle;

  /// No description provided for @coupleJoinLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get coupleJoinLabel;

  /// No description provided for @coupleJoinHelp.
  ///
  /// In en, this message translates to:
  /// **'Six characters, uppercase.'**
  String get coupleJoinHelp;

  /// No description provided for @coupleJoinSubmit.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get coupleJoinSubmit;

  /// No description provided for @coupleJoinWelcome.
  ///
  /// In en, this message translates to:
  /// **'You\'re in! Welcome, {name}.'**
  String coupleJoinWelcome(String name);

  /// No description provided for @coupleJoinErrorInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t valid.'**
  String get coupleJoinErrorInvalid;

  /// No description provided for @coupleJoinErrorExpired.
  ///
  /// In en, this message translates to:
  /// **'The code expired. Ask your partner for a new one.'**
  String get coupleJoinErrorExpired;

  /// No description provided for @coupleJoinErrorFull.
  ///
  /// In en, this message translates to:
  /// **'That couple is already complete.'**
  String get coupleJoinErrorFull;

  /// No description provided for @coupleJoinErrorAlreadyMember.
  ///
  /// In en, this message translates to:
  /// **'You\'re already part of this couple.'**
  String get coupleJoinErrorAlreadyMember;

  /// No description provided for @coupleJoinErrorAlreadyInCouple.
  ///
  /// In en, this message translates to:
  /// **'You already belong to a couple.'**
  String get coupleJoinErrorAlreadyInCouple;

  /// No description provided for @coupleWaitingTitle.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your partner'**
  String get coupleWaitingTitle;

  /// No description provided for @coupleWaitingBody.
  ///
  /// In en, this message translates to:
  /// **'Share this code. When they join, this screen moves on by itself.'**
  String get coupleWaitingBody;

  /// No description provided for @coupleWaitingShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get coupleWaitingShare;

  /// No description provided for @coupleWaitingCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get coupleWaitingCopied;

  /// No description provided for @coupleWaitingShareText.
  ///
  /// In en, this message translates to:
  /// **'Join our couple on Racha with this code: {code}'**
  String coupleWaitingShareText(String code);

  /// No description provided for @homeWeeks.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No weeks yet} =1{1 week} other{{count} weeks}}'**
  String homeWeeks(int count);

  /// No description provided for @homeStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'current streak'**
  String get homeStreakLabel;

  /// No description provided for @homeWeekCovered.
  ///
  /// In en, this message translates to:
  /// **'This week is covered.'**
  String get homeWeekCovered;

  /// No description provided for @homeWeekOpen.
  ///
  /// In en, this message translates to:
  /// **'No date logged this week yet.'**
  String get homeWeekOpen;

  /// No description provided for @homeWeekAtRisk.
  ///
  /// In en, this message translates to:
  /// **'Streak at risk — {days, plural, =1{1 day left} other{{days} days left}} this week.'**
  String homeWeekAtRisk(int days);

  /// No description provided for @homeRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent dates'**
  String get homeRecentTitle;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your first week starts now'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Log a date you went on together and watch the streak begin.'**
  String get homeEmptyBody;

  /// No description provided for @homeLogDate.
  ///
  /// In en, this message translates to:
  /// **'Log a date'**
  String get homeLogDate;

  /// No description provided for @homeVerifyEmailBanner.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email to secure your account.'**
  String get homeVerifyEmailBanner;

  /// No description provided for @dateNewPlaceTitle.
  ///
  /// In en, this message translates to:
  /// **'Where did you go?'**
  String get dateNewPlaceTitle;

  /// No description provided for @dateNewSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search a place'**
  String get dateNewSearchHint;

  /// No description provided for @dateNewUseNoPlace.
  ///
  /// In en, this message translates to:
  /// **'No place / at home'**
  String get dateNewUseNoPlace;

  /// No description provided for @dateNewRecent.
  ///
  /// In en, this message translates to:
  /// **'Places you\'ve been'**
  String get dateNewRecent;

  /// No description provided for @dateNewNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get dateNewNext;

  /// No description provided for @dateNewOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection — search needs the network.'**
  String get dateNewOffline;

  /// No description provided for @dateDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Date details'**
  String get dateDetailsTitle;

  /// No description provided for @dateFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get dateFieldTitle;

  /// No description provided for @dateFieldWhen.
  ///
  /// In en, this message translates to:
  /// **'When'**
  String get dateFieldWhen;

  /// No description provided for @dateFieldRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get dateFieldRating;

  /// No description provided for @dateFieldNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get dateFieldNotes;

  /// No description provided for @dateFieldCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get dateFieldCost;

  /// No description provided for @dateTagBoth.
  ///
  /// In en, this message translates to:
  /// **'Both of you'**
  String get dateTagBoth;

  /// No description provided for @dateTagWarning.
  ///
  /// In en, this message translates to:
  /// **'If you remove your partner, this date won\'t count toward the streak.'**
  String get dateTagWarning;

  /// No description provided for @dateSave.
  ///
  /// In en, this message translates to:
  /// **'Save date'**
  String get dateSave;

  /// No description provided for @dateSavedStreakUp.
  ///
  /// In en, this message translates to:
  /// **'Streak advanced!'**
  String get dateSavedStreakUp;

  /// No description provided for @dateErrorFuture.
  ///
  /// In en, this message translates to:
  /// **'You can\'t log a date in the future.'**
  String get dateErrorFuture;

  /// No description provided for @timelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Our dates'**
  String get timelineTitle;

  /// No description provided for @timelineEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dates yet. Log your first one.'**
  String get timelineEmpty;

  /// No description provided for @timelineDoesntCount.
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t count toward the streak'**
  String get timelineDoesntCount;

  /// No description provided for @timelineLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get timelineLoadMore;

  /// No description provided for @dateDetailEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get dateDetailEdit;

  /// No description provided for @dateDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get dateDetailDelete;

  /// No description provided for @dateDetailDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this date?'**
  String get dateDetailDeleteTitle;

  /// No description provided for @dateDetailDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone.'**
  String get dateDetailDeleteBody;

  /// No description provided for @dateDetailDeleteWarnsStreak.
  ///
  /// In en, this message translates to:
  /// **'This date counts toward your streak of {count}. Deleting it may lower it.'**
  String dateDetailDeleteWarnsStreak(int count);

  /// No description provided for @dateDetailDeleted.
  ///
  /// In en, this message translates to:
  /// **'Date deleted.'**
  String get dateDetailDeleted;

  /// No description provided for @dateDetailStreakDropped.
  ///
  /// In en, this message translates to:
  /// **'The streak dropped.'**
  String get dateDetailStreakDropped;

  /// No description provided for @dateEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit date'**
  String get dateEditTitle;

  /// No description provided for @dateEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get dateEditSave;

  /// No description provided for @summaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Where we\'ve been'**
  String get summaryTitle;

  /// No description provided for @summaryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log a couple of dates and your places will show up here.'**
  String get summaryEmpty;

  /// No description provided for @summaryDistinctPlaces.
  ///
  /// In en, this message translates to:
  /// **'places'**
  String get summaryDistinctPlaces;

  /// No description provided for @summaryTotalVisits.
  ///
  /// In en, this message translates to:
  /// **'visits'**
  String get summaryTotalVisits;

  /// No description provided for @summaryTotalCost.
  ///
  /// In en, this message translates to:
  /// **'spent'**
  String get summaryTotalCost;

  /// No description provided for @summaryFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favourite: {name}'**
  String summaryFavorite(String name);

  /// No description provided for @summaryByCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get summaryByCategory;

  /// No description provided for @summaryOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Open map'**
  String get summaryOpenMap;

  /// No description provided for @summaryVisitsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 visit} other{{count} visits}}'**
  String summaryVisitsCount(int count);

  /// No description provided for @mapTitle.
  ///
  /// In en, this message translates to:
  /// **'Places map'**
  String get mapTitle;

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'© OpenStreetMap contributors'**
  String get mapAttribution;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileStreak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get profileStreak;

  /// No description provided for @profileLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest'**
  String get profileLongest;

  /// No description provided for @profileTotalDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get profileTotalDates;

  /// No description provided for @profileDaysTogether.
  ///
  /// In en, this message translates to:
  /// **'Days together'**
  String get profileDaysTogether;

  /// No description provided for @profileDatesByMonth.
  ///
  /// In en, this message translates to:
  /// **'Dates per month'**
  String get profileDatesByMonth;

  /// No description provided for @profileMyAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get profileMyAccount;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Recover your password'**
  String get forgotTitle;

  /// No description provided for @forgotBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send a link to choose a new password.'**
  String get forgotBody;

  /// No description provided for @forgotSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get forgotSubmit;

  /// No description provided for @forgotDone.
  ///
  /// In en, this message translates to:
  /// **'If that email has an account, a link is on its way.'**
  String get forgotDone;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetTitle;

  /// No description provided for @resetTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Code from the email'**
  String get resetTokenLabel;

  /// No description provided for @resetNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get resetNewPassword;

  /// No description provided for @resetSubmit.
  ///
  /// In en, this message translates to:
  /// **'Set password'**
  String get resetSubmit;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Password updated. Sign in with your new password.'**
  String get resetDone;

  /// No description provided for @resetInvalidToken.
  ///
  /// In en, this message translates to:
  /// **'That link isn\'t valid or was already used.'**
  String get resetInvalidToken;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email'**
  String get verifyTitle;

  /// No description provided for @verifyBody.
  ///
  /// In en, this message translates to:
  /// **'We sent a link to {email}. Open it to confirm, or resend below.'**
  String verifyBody(String email);

  /// No description provided for @verifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get verifyResend;

  /// No description provided for @verifyResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String verifyResendIn(int seconds);

  /// No description provided for @verifySent.
  ///
  /// In en, this message translates to:
  /// **'Sent. Check your inbox.'**
  String get verifySent;

  /// No description provided for @verifyDone.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed.'**
  String get verifyDone;

  /// No description provided for @verifyManual.
  ///
  /// In en, this message translates to:
  /// **'Paste the code from the email'**
  String get verifyManual;

  /// No description provided for @verifyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get verifyConfirm;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get accountTitle;

  /// No description provided for @accountEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get accountEmail;

  /// No description provided for @accountVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get accountVerified;

  /// No description provided for @accountUnverified.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get accountUnverified;

  /// No description provided for @accountVerifyNow.
  ///
  /// In en, this message translates to:
  /// **'Confirm now'**
  String get accountVerifyNow;

  /// No description provided for @accountNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get accountNotifications;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is scheduled for deletion in 30 days. The app keeps working until then; you can cancel any time.'**
  String get accountDeleteBody;

  /// No description provided for @accountDeleteExplain.
  ///
  /// In en, this message translates to:
  /// **'This ends the couple after 30 days. Your partner\'s streak and dates are kept. Type your email to confirm.'**
  String get accountDeleteExplain;

  /// No description provided for @accountDeletePassword.
  ///
  /// In en, this message translates to:
  /// **'Password (if you signed in a while ago)'**
  String get accountDeletePassword;

  /// No description provided for @accountDeleteConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Type your email'**
  String get accountDeleteConfirmLabel;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Schedule deletion'**
  String get accountDeleteConfirm;

  /// No description provided for @accountDeleteScheduled.
  ///
  /// In en, this message translates to:
  /// **'Deletion scheduled for {date}.'**
  String accountDeleteScheduled(String date);

  /// No description provided for @accountCancelDeletion.
  ///
  /// In en, this message translates to:
  /// **'Cancel deletion'**
  String get accountCancelDeletion;

  /// No description provided for @accountDeletionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Deletion cancelled.'**
  String get accountDeletionCancelled;

  /// No description provided for @homeDeletionBanner.
  ///
  /// In en, this message translates to:
  /// **'Your account is scheduled for deletion.'**
  String get homeDeletionBanner;

  /// No description provided for @homeCancelDeletion.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get homeCancelDeletion;

  /// No description provided for @notifTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifTitle;

  /// No description provided for @notifStreakReminder.
  ///
  /// In en, this message translates to:
  /// **'Streak reminder'**
  String get notifStreakReminder;

  /// No description provided for @notifStreakReminderEx.
  ///
  /// In en, this message translates to:
  /// **'Sat & Sun: \"Your streak is still going — one outing this weekend keeps it.\"'**
  String get notifStreakReminderEx;

  /// No description provided for @notifStreakAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Streak advanced'**
  String get notifStreakAdvanced;

  /// No description provided for @notifTagPending.
  ///
  /// In en, this message translates to:
  /// **'Date to confirm'**
  String get notifTagPending;

  /// No description provided for @notifPartnerActivity.
  ///
  /// In en, this message translates to:
  /// **'Partner activity'**
  String get notifPartnerActivity;

  /// No description provided for @notifWeeklyRecap.
  ///
  /// In en, this message translates to:
  /// **'Weekly recap'**
  String get notifWeeklyRecap;

  /// No description provided for @notifReminderHour.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get notifReminderHour;

  /// No description provided for @notifQuietHours.
  ///
  /// In en, this message translates to:
  /// **'Quiet hours'**
  String get notifQuietHours;

  /// No description provided for @notifQuietFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get notifQuietFrom;

  /// No description provided for @notifQuietTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get notifQuietTo;

  /// No description provided for @notifPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off in system settings.'**
  String get notifPermissionDenied;

  /// No description provided for @notifOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get notifOpenSettings;

  /// No description provided for @notifSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get notifSaved;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get languageAutomatic;

  /// No description provided for @languageAutomaticHint.
  ///
  /// In en, this message translates to:
  /// **'Follow the device language'**
  String get languageAutomaticHint;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet. Reminders and your partner\'s activity will show up here.'**
  String get activityEmpty;

  /// No description provided for @activityMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get activityMarkAllRead;

  /// No description provided for @activityLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get activityLoadMore;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @calendarTabMonth.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTabMonth;

  /// No description provided for @calendarTabIdeas.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get calendarTabIdeas;

  /// No description provided for @calendarNoIdeas.
  ///
  /// In en, this message translates to:
  /// **'No ideas yet. Jot down something you\'d like to do.'**
  String get calendarNoIdeas;

  /// No description provided for @calendarDayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing planned this day.'**
  String get calendarDayEmpty;

  /// No description provided for @calendarPlanHere.
  ///
  /// In en, this message translates to:
  /// **'Plan something'**
  String get calendarPlanHere;

  /// No description provided for @calendarWeekCovered.
  ///
  /// In en, this message translates to:
  /// **'This week is covered'**
  String get calendarWeekCovered;

  /// No description provided for @calendarWeekPlanned.
  ///
  /// In en, this message translates to:
  /// **'Something planned this week'**
  String get calendarWeekPlanned;

  /// No description provided for @planNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan a date'**
  String get planNewTitle;

  /// No description provided for @planFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s the plan?'**
  String get planFieldTitle;

  /// No description provided for @planFieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Dinner, a movie, a walk'**
  String get planFieldTitleHint;

  /// No description provided for @planFieldPlace.
  ///
  /// In en, this message translates to:
  /// **'Place (optional)'**
  String get planFieldPlace;

  /// No description provided for @planFieldPlaceChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a place'**
  String get planFieldPlaceChoose;

  /// No description provided for @planFieldWhen.
  ///
  /// In en, this message translates to:
  /// **'When (optional)'**
  String get planFieldWhen;

  /// No description provided for @planFieldPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick a date'**
  String get planFieldPickDate;

  /// No description provided for @planFieldAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add a time'**
  String get planFieldAddTime;

  /// No description provided for @planNoDateHint.
  ///
  /// In en, this message translates to:
  /// **'No date? It\'s kept as an idea until it gets one.'**
  String get planNoDateHint;

  /// No description provided for @planSaveIdea.
  ///
  /// In en, this message translates to:
  /// **'Save idea'**
  String get planSaveIdea;

  /// No description provided for @planPropose.
  ///
  /// In en, this message translates to:
  /// **'Propose plan'**
  String get planPropose;

  /// No description provided for @planSavedProposed.
  ///
  /// In en, this message translates to:
  /// **'Sent to your partner.'**
  String get planSavedProposed;

  /// No description provided for @planSavedIdea.
  ///
  /// In en, this message translates to:
  /// **'Saved as an idea.'**
  String get planSavedIdea;

  /// No description provided for @planErrorPast.
  ///
  /// In en, this message translates to:
  /// **'That date has already passed — log it as a date instead.'**
  String get planErrorPast;

  /// No description provided for @planDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planDetailTitle;

  /// No description provided for @planStatusIdea.
  ///
  /// In en, this message translates to:
  /// **'Idea'**
  String get planStatusIdea;

  /// No description provided for @planStatusProposed.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a reply'**
  String get planStatusProposed;

  /// No description provided for @planStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get planStatusConfirmed;

  /// No description provided for @planStatusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Not this time'**
  String get planStatusDeclined;

  /// No description provided for @planStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get planStatusCancelled;

  /// No description provided for @planStatusMissed.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t happen'**
  String get planStatusMissed;

  /// No description provided for @planStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Logged as a date'**
  String get planStatusCompleted;

  /// No description provided for @planProposedByYou.
  ///
  /// In en, this message translates to:
  /// **'You proposed this'**
  String get planProposedByYou;

  /// No description provided for @planProposedByPartner.
  ///
  /// In en, this message translates to:
  /// **'Your partner proposed this'**
  String get planProposedByPartner;

  /// No description provided for @planJoinIn.
  ///
  /// In en, this message translates to:
  /// **'I\'m in'**
  String get planJoinIn;

  /// No description provided for @planNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get planNotNow;

  /// No description provided for @planNotNowHint.
  ///
  /// In en, this message translates to:
  /// **'Want to suggest another day?'**
  String get planNotNowHint;

  /// No description provided for @planDidYouGo.
  ///
  /// In en, this message translates to:
  /// **'Did you go out?'**
  String get planDidYouGo;

  /// No description provided for @planLogAsDate.
  ///
  /// In en, this message translates to:
  /// **'Log it as a date'**
  String get planLogAsDate;

  /// No description provided for @planEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get planEdit;

  /// No description provided for @planCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel plan'**
  String get planCancel;

  /// No description provided for @planCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel this plan?'**
  String get planCancelConfirm;

  /// No description provided for @planCancelBody.
  ///
  /// In en, this message translates to:
  /// **'It stays in the history for the stats, but leaves the calendar.'**
  String get planCancelBody;

  /// No description provided for @planResponseConfirmed.
  ///
  /// In en, this message translates to:
  /// **'You\'re in.'**
  String get planResponseConfirmed;

  /// No description provided for @planResponseDeclined.
  ///
  /// In en, this message translates to:
  /// **'Marked as not this time.'**
  String get planResponseDeclined;

  /// No description provided for @planViewDate.
  ///
  /// In en, this message translates to:
  /// **'Open the date'**
  String get planViewDate;

  /// No description provided for @homeNextPlan.
  ///
  /// In en, this message translates to:
  /// **'Next plan'**
  String get homeNextPlan;

  /// No description provided for @homePlanRespond.
  ///
  /// In en, this message translates to:
  /// **'Respond'**
  String get homePlanRespond;

  /// No description provided for @homePlansPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 plan to answer} other{{count} plans to answer}}'**
  String homePlansPending(int count);

  /// No description provided for @protectTitle.
  ///
  /// In en, this message translates to:
  /// **'Protect the streak'**
  String get protectTitle;

  /// No description provided for @protectSeasonBest.
  ///
  /// In en, this message translates to:
  /// **'Season best'**
  String get protectSeasonBest;

  /// No description provided for @protectRecord.
  ///
  /// In en, this message translates to:
  /// **'All-time best'**
  String get protectRecord;

  /// No description provided for @protectSeasonMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly season'**
  String get protectSeasonMonthly;

  /// No description provided for @protectSeasonQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly season'**
  String get protectSeasonQuarterly;

  /// No description provided for @protectSeasonInfinite.
  ///
  /// In en, this message translates to:
  /// **'No season reset'**
  String get protectSeasonInfinite;

  /// No description provided for @protectFreezeQuotaAvailable.
  ///
  /// In en, this message translates to:
  /// **'1 free pause left this month'**
  String get protectFreezeQuotaAvailable;

  /// No description provided for @protectFreezeQuotaUsed.
  ///
  /// In en, this message translates to:
  /// **'This month\'s pause is used'**
  String get protectFreezeQuotaUsed;

  /// No description provided for @protectActiveFreezeFrom.
  ///
  /// In en, this message translates to:
  /// **'Frozen {start} to {end}'**
  String protectActiveFreezeFrom(Object start, Object end);

  /// No description provided for @protectDeclarePause.
  ///
  /// In en, this message translates to:
  /// **'Declare a pause'**
  String get protectDeclarePause;

  /// No description provided for @protectSaveLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Save last week'**
  String get protectSaveLastWeek;

  /// No description provided for @protectPendingMine.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your partner to confirm ({week})'**
  String protectPendingMine(Object week);

  /// No description provided for @protectPendingYours.
  ///
  /// In en, this message translates to:
  /// **'Your partner wants to save {week}'**
  String protectPendingYours(Object week);

  /// No description provided for @protectCancelFreeze.
  ///
  /// In en, this message translates to:
  /// **'Cancel pause'**
  String get protectCancelFreeze;

  /// No description provided for @protectNothing.
  ///
  /// In en, this message translates to:
  /// **'Nothing to protect right now — the streak is on track.'**
  String get protectNothing;

  /// No description provided for @freezeNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Declare a pause'**
  String get freezeNewTitle;

  /// No description provided for @freezeReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get freezeReason;

  /// No description provided for @freezeReasonTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get freezeReasonTravel;

  /// No description provided for @freezeReasonIllness.
  ///
  /// In en, this message translates to:
  /// **'Illness'**
  String get freezeReasonIllness;

  /// No description provided for @freezeReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get freezeReasonOther;

  /// No description provided for @freezeFrom.
  ///
  /// In en, this message translates to:
  /// **'First week'**
  String get freezeFrom;

  /// No description provided for @freezeTo.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get freezeTo;

  /// No description provided for @freezeSubmit.
  ///
  /// In en, this message translates to:
  /// **'Freeze these weeks'**
  String get freezeSubmit;

  /// No description provided for @freezeErrorQuota.
  ///
  /// In en, this message translates to:
  /// **'You\'ve already used this month\'s free pause.'**
  String get freezeErrorQuota;

  /// No description provided for @freezeErrorWeekComplete.
  ///
  /// In en, this message translates to:
  /// **'One of those weeks already has a date.'**
  String get freezeErrorWeekComplete;

  /// No description provided for @freezeErrorPast.
  ///
  /// In en, this message translates to:
  /// **'A pause only protects future weeks.'**
  String get freezeErrorPast;

  /// No description provided for @freezeDone.
  ///
  /// In en, this message translates to:
  /// **'Streak frozen for those weeks.'**
  String get freezeDone;

  /// No description provided for @freezeCancelled.
  ///
  /// In en, this message translates to:
  /// **'Pause cancelled.'**
  String get freezeCancelled;

  /// No description provided for @repairNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Save the week'**
  String get repairNewTitle;

  /// No description provided for @repairBody.
  ///
  /// In en, this message translates to:
  /// **'Log a date from last week to save the streak. Your partner has to confirm it.'**
  String get repairBody;

  /// No description provided for @repairFieldWhen.
  ///
  /// In en, this message translates to:
  /// **'When did you go out?'**
  String get repairFieldWhen;

  /// No description provided for @repairFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'What did you do?'**
  String get repairFieldTitle;

  /// No description provided for @repairSubmit.
  ///
  /// In en, this message translates to:
  /// **'Ask to save the week'**
  String get repairSubmit;

  /// No description provided for @repairErrorWindow.
  ///
  /// In en, this message translates to:
  /// **'It\'s been over 48h since that week closed.'**
  String get repairErrorWindow;

  /// No description provided for @repairErrorNotClosed.
  ///
  /// In en, this message translates to:
  /// **'That week hasn\'t closed yet — log it as a normal date.'**
  String get repairErrorNotClosed;

  /// No description provided for @repairErrorPending.
  ///
  /// In en, this message translates to:
  /// **'There\'s already a repair pending for that week.'**
  String get repairErrorPending;

  /// No description provided for @repairSent.
  ///
  /// In en, this message translates to:
  /// **'Sent. Waiting for your partner to confirm.'**
  String get repairSent;

  /// No description provided for @repairConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm the repair'**
  String get repairConfirmTitle;

  /// No description provided for @repairConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Confirming makes the date count and rebuilds the streak. Rejecting removes it.'**
  String get repairConfirmBody;

  /// No description provided for @repairConfirm.
  ///
  /// In en, this message translates to:
  /// **'Yes, we went out'**
  String get repairConfirm;

  /// No description provided for @repairReject.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get repairReject;

  /// No description provided for @repairConfirmedToast.
  ///
  /// In en, this message translates to:
  /// **'Confirmed. The streak is back.'**
  String get repairConfirmedToast;

  /// No description provided for @repairRejectedToast.
  ///
  /// In en, this message translates to:
  /// **'Rejected.'**
  String get repairRejectedToast;

  /// No description provided for @repairCannotConfirmOwn.
  ///
  /// In en, this message translates to:
  /// **'Your partner confirms this one.'**
  String get repairCannotConfirmOwn;

  /// No description provided for @homeStreakFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen this week'**
  String get homeStreakFrozen;

  /// No description provided for @homeRepairPending.
  ///
  /// In en, this message translates to:
  /// **'A repair needs your confirmation'**
  String get homeRepairPending;

  /// No description provided for @homeSeasonBest.
  ///
  /// In en, this message translates to:
  /// **'Season best {n}'**
  String homeSeasonBest(int n);

  /// No description provided for @wishlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlistTitle;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing on the list yet. Add a place or an idea.'**
  String get wishlistEmpty;

  /// No description provided for @wishlistTabOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get wishlistTabOpen;

  /// No description provided for @wishlistTabPlanned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get wishlistTabPlanned;

  /// No description provided for @wishlistTabDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get wishlistTabDone;

  /// No description provided for @wishlistRoulette.
  ///
  /// In en, this message translates to:
  /// **'Pick for us'**
  String get wishlistRoulette;

  /// No description provided for @wishlistSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Ideas for you'**
  String get wishlistSuggestions;

  /// No description provided for @wishlistPlanThis.
  ///
  /// In en, this message translates to:
  /// **'Plan this'**
  String get wishlistPlanThis;

  /// No description provided for @wishlistMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get wishlistMarkDone;

  /// No description provided for @wishlistReopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get wishlistReopen;

  /// No description provided for @wishlistDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get wishlistDelete;

  /// No description provided for @wishlistDeletePlanned.
  ///
  /// In en, this message translates to:
  /// **'This wish is already planned. Delete anyway?'**
  String get wishlistDeletePlanned;

  /// No description provided for @wishNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to the list'**
  String get wishNewTitle;

  /// No description provided for @wishFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you want to do?'**
  String get wishFieldTitle;

  /// No description provided for @wishFieldNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get wishFieldNote;

  /// No description provided for @wishFieldPlace.
  ///
  /// In en, this message translates to:
  /// **'Place (optional)'**
  String get wishFieldPlace;

  /// No description provided for @wishFieldCost.
  ///
  /// In en, this message translates to:
  /// **'Cost (optional)'**
  String get wishFieldCost;

  /// No description provided for @wishCostFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get wishCostFree;

  /// No description provided for @wishCostLow.
  ///
  /// In en, this message translates to:
  /// **'Cheap'**
  String get wishCostLow;

  /// No description provided for @wishCostMid.
  ///
  /// In en, this message translates to:
  /// **'Mid'**
  String get wishCostMid;

  /// No description provided for @wishCostHigh.
  ///
  /// In en, this message translates to:
  /// **'Pricey'**
  String get wishCostHigh;

  /// No description provided for @wishSaved.
  ///
  /// In en, this message translates to:
  /// **'Added to the list.'**
  String get wishSaved;

  /// No description provided for @rouletteTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick for us'**
  String get rouletteTitle;

  /// No description provided for @rouletteSpin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get rouletteSpin;

  /// No description provided for @rouletteAgain.
  ///
  /// In en, this message translates to:
  /// **'Spin again'**
  String get rouletteAgain;

  /// No description provided for @rouletteCheap.
  ///
  /// In en, this message translates to:
  /// **'Cheap only'**
  String get rouletteCheap;

  /// No description provided for @rouletteEmpty.
  ///
  /// In en, this message translates to:
  /// **'No open wishes match. Add some first.'**
  String get rouletteEmpty;

  /// No description provided for @roulettePlanIt.
  ///
  /// In en, this message translates to:
  /// **'Plan it'**
  String get roulettePlanIt;

  /// No description provided for @suggestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Ideas for you'**
  String get suggestionsTitle;

  /// No description provided for @suggestionsCheap.
  ///
  /// In en, this message translates to:
  /// **'Budget-friendly'**
  String get suggestionsCheap;

  /// No description provided for @suggestionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No ideas right now. Log a few dates and check back.'**
  String get suggestionsEmpty;

  /// No description provided for @suggestionAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add to the list'**
  String get suggestionAddToList;

  /// No description provided for @homeWishlistCard.
  ///
  /// In en, this message translates to:
  /// **'What to do this week'**
  String get homeWishlistCard;

  /// No description provided for @homeWishlistWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 idea waiting} other{{count} ideas waiting}}'**
  String homeWishlistWaiting(int count);

  /// No description provided for @mapLayerVisited.
  ///
  /// In en, this message translates to:
  /// **'Visited'**
  String get mapLayerVisited;

  /// No description provided for @mapLayerToVisit.
  ///
  /// In en, this message translates to:
  /// **'To visit'**
  String get mapLayerToVisit;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyRequireTagConsent.
  ///
  /// In en, this message translates to:
  /// **'Ask before tagging me'**
  String get privacyRequireTagConsent;

  /// No description provided for @privacyRequireTagConsentSub.
  ///
  /// In en, this message translates to:
  /// **'Your partner has to accept a tag before a date counts you in.'**
  String get privacyRequireTagConsentSub;

  /// No description provided for @privacyShareCost.
  ///
  /// In en, this message translates to:
  /// **'Share what we spend'**
  String get privacyShareCost;

  /// No description provided for @privacyShareCostSub.
  ///
  /// In en, this message translates to:
  /// **'Off hides the cost on every date, past and future.'**
  String get privacyShareCostSub;

  /// No description provided for @privacyNotesPrivate.
  ///
  /// In en, this message translates to:
  /// **'Keep notes private by default'**
  String get privacyNotesPrivate;

  /// No description provided for @privacyNotesPrivateSub.
  ///
  /// In en, this message translates to:
  /// **'New notes are visible only to you until you share them.'**
  String get privacyNotesPrivateSub;

  /// No description provided for @privacyAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Usage analytics'**
  String get privacyAnalytics;

  /// No description provided for @privacyAnalyticsSub.
  ///
  /// In en, this message translates to:
  /// **'Anonymous data that helps us improve the app.'**
  String get privacyAnalyticsSub;

  /// No description provided for @privacyMarketing.
  ///
  /// In en, this message translates to:
  /// **'Product emails'**
  String get privacyMarketing;

  /// No description provided for @privacyMarketingSub.
  ///
  /// In en, this message translates to:
  /// **'Occasional news about new features. Never more than once a month.'**
  String get privacyMarketingSub;

  /// No description provided for @privacyExport.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get privacyExport;

  /// No description provided for @privacyExportSub.
  ///
  /// In en, this message translates to:
  /// **'We email you a link to download everything.'**
  String get privacyExportSub;

  /// No description provided for @privacyExportQueued.
  ///
  /// In en, this message translates to:
  /// **'On its way — check your email shortly.'**
  String get privacyExportQueued;

  /// No description provided for @privacyLeaveCouple.
  ///
  /// In en, this message translates to:
  /// **'Leave the couple'**
  String get privacyLeaveCouple;

  /// No description provided for @privacyLeaveCoupleWarning.
  ///
  /// In en, this message translates to:
  /// **'The streak and every shared date stay with the couple. You go back to the pairing screen.'**
  String get privacyLeaveCoupleWarning;

  /// No description provided for @privacyLeaveCoupleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get privacyLeaveCoupleConfirm;

  /// No description provided for @privacyDeleteSub.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone'**
  String get privacyDeleteSub;

  /// No description provided for @placeDetailUnknown.
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get placeDetailUnknown;

  /// No description provided for @placeDetailDatesHere.
  ///
  /// In en, this message translates to:
  /// **'Dates here'**
  String get placeDetailDatesHere;

  /// No description provided for @placeDetailLogHere.
  ///
  /// In en, this message translates to:
  /// **'Log a date here'**
  String get placeDetailLogHere;

  /// No description provided for @placeDetailEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dates logged here yet.'**
  String get placeDetailEmpty;

  /// No description provided for @placeDetailVisits.
  ///
  /// In en, this message translates to:
  /// **'visits'**
  String get placeDetailVisits;

  /// No description provided for @placeDetailRating.
  ///
  /// In en, this message translates to:
  /// **'rating'**
  String get placeDetailRating;

  /// No description provided for @placeDetailTotalCost.
  ///
  /// In en, this message translates to:
  /// **'total spent'**
  String get placeDetailTotalCost;

  /// No description provided for @placeDetailOpen.
  ///
  /// In en, this message translates to:
  /// **'Open place'**
  String get placeDetailOpen;

  /// No description provided for @posterTitle.
  ///
  /// In en, this message translates to:
  /// **'Map poster'**
  String get posterTitle;

  /// No description provided for @posterSave.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get posterSave;

  /// No description provided for @posterSaved.
  ///
  /// In en, this message translates to:
  /// **'Poster copied.'**
  String get posterSaved;

  /// No description provided for @posterHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your {count} dates'**
  String posterHeadline(int count);

  /// No description provided for @posterSubhead.
  ///
  /// In en, this message translates to:
  /// **'{count} places on the map'**
  String posterSubhead(int count);

  /// No description provided for @posterPlaces.
  ///
  /// In en, this message translates to:
  /// **'places'**
  String get posterPlaces;

  /// No description provided for @posterDates.
  ///
  /// In en, this message translates to:
  /// **'dates'**
  String get posterDates;

  /// No description provided for @posterSpent.
  ///
  /// In en, this message translates to:
  /// **'spent'**
  String get posterSpent;

  /// No description provided for @milestonesTitle.
  ///
  /// In en, this message translates to:
  /// **'Your milestones'**
  String get milestonesTitle;

  /// No description provided for @milestonesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Log your first date and the milestones start filling in.'**
  String get milestonesEmpty;

  /// No description provided for @milestonesLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get milestonesLatest;

  /// No description provided for @milestonesAll.
  ///
  /// In en, this message translates to:
  /// **'All milestones'**
  String get milestonesAll;

  /// No description provided for @milestonesUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get milestonesUnlocked;

  /// No description provided for @milestoneFirstDate.
  ///
  /// In en, this message translates to:
  /// **'First date logged'**
  String get milestoneFirstDate;

  /// No description provided for @milestoneDates.
  ///
  /// In en, this message translates to:
  /// **'{count} dates together'**
  String milestoneDates(int count);

  /// No description provided for @milestoneStreak.
  ///
  /// In en, this message translates to:
  /// **'{weeks}-week streak'**
  String milestoneStreak(int weeks);

  /// No description provided for @milestoneDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days together'**
  String milestoneDays(int days);

  /// No description provided for @wrappedEntry.
  ///
  /// In en, this message translates to:
  /// **'Your year in Racha'**
  String get wrappedEntry;

  /// No description provided for @wrappedPrev.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get wrappedPrev;

  /// No description provided for @wrappedNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get wrappedNext;

  /// No description provided for @wrappedIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Your year in Racha'**
  String get wrappedIntroTitle;

  /// No description provided for @wrappedIntroBody.
  ///
  /// In en, this message translates to:
  /// **'What a year together.'**
  String get wrappedIntroBody;

  /// No description provided for @wrappedTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total dates'**
  String get wrappedTotalLabel;

  /// No description provided for @wrappedTotalDates.
  ///
  /// In en, this message translates to:
  /// **'dates in {year}'**
  String wrappedTotalDates(int year);

  /// No description provided for @wrappedNewPlaces.
  ///
  /// In en, this message translates to:
  /// **'new places'**
  String get wrappedNewPlaces;

  /// No description provided for @wrappedWeeksShort.
  ///
  /// In en, this message translates to:
  /// **'{count}w'**
  String wrappedWeeksShort(int count);

  /// No description provided for @wrappedMaxStreak.
  ///
  /// In en, this message translates to:
  /// **'longest streak'**
  String get wrappedMaxStreak;

  /// No description provided for @wrappedFavCategory.
  ///
  /// In en, this message translates to:
  /// **'Favourite category'**
  String get wrappedFavCategory;

  /// No description provided for @wrappedFavCategoryCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of your {total} dates'**
  String wrappedFavCategoryCount(int count, int total);

  /// No description provided for @wrappedBestMonth.
  ///
  /// In en, this message translates to:
  /// **'Best month'**
  String get wrappedBestMonth;

  /// No description provided for @wrappedRecap.
  ///
  /// In en, this message translates to:
  /// **'Your recap'**
  String get wrappedRecap;

  /// No description provided for @wrappedTotalSpend.
  ///
  /// In en, this message translates to:
  /// **'Total spent'**
  String get wrappedTotalSpend;

  /// No description provided for @homeStreakConsecutive.
  ///
  /// In en, this message translates to:
  /// **'weeks in a row'**
  String get homeStreakConsecutive;

  /// No description provided for @homeWeekCoveredCheer.
  ///
  /// In en, this message translates to:
  /// **'This week is covered! 🎉'**
  String get homeWeekCoveredCheer;

  /// No description provided for @homeStatTotal.
  ///
  /// In en, this message translates to:
  /// **'Total dates'**
  String get homeStatTotal;

  /// No description provided for @homeStatRecord.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get homeStatRecord;

  /// No description provided for @homeStatMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get homeStatMonth;

  /// No description provided for @homeFavPlace.
  ///
  /// In en, this message translates to:
  /// **'Most visited place'**
  String get homeFavPlace;

  /// No description provided for @timelineSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search dates or places'**
  String get timelineSearchHint;

  /// No description provided for @timelineCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 date} other{{count} dates}}'**
  String timelineCount(int count);

  /// No description provided for @timelineNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches your search'**
  String get timelineNoMatch;

  /// No description provided for @timelineClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get timelineClearSearch;

  /// No description provided for @profileYourCouple.
  ///
  /// In en, this message translates to:
  /// **'your couple'**
  String get profileYourCouple;

  /// No description provided for @profileTogether.
  ///
  /// In en, this message translates to:
  /// **'Together for {days} days'**
  String profileTogether(int days);

  /// No description provided for @profileStatDates.
  ///
  /// In en, this message translates to:
  /// **'dates'**
  String get profileStatDates;

  /// No description provided for @profileStatStreak.
  ///
  /// In en, this message translates to:
  /// **'streak'**
  String get profileStatStreak;

  /// No description provided for @profileStatRecord.
  ///
  /// In en, this message translates to:
  /// **'record'**
  String get profileStatRecord;

  /// No description provided for @profileStatBestMonth.
  ///
  /// In en, this message translates to:
  /// **'best month'**
  String get profileStatBestMonth;

  /// No description provided for @profileCoupleSettings.
  ///
  /// In en, this message translates to:
  /// **'Couple settings'**
  String get profileCoupleSettings;

  /// No description provided for @profileCoupleNameRow.
  ///
  /// In en, this message translates to:
  /// **'Couple name'**
  String get profileCoupleNameRow;

  /// No description provided for @profileTimezone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get profileTimezone;

  /// No description provided for @profileWeekStart.
  ///
  /// In en, this message translates to:
  /// **'Week starts'**
  String get profileWeekStart;

  /// No description provided for @profileInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get profileInviteCode;

  /// No description provided for @profileCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get profileCopy;

  /// No description provided for @profileCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get profileCopied;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditProfile;

  /// No description provided for @weekStartMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get weekStartMonday;

  /// No description provided for @weekStartSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get weekStartSunday;

  /// No description provided for @mapSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get mapSummary;

  /// No description provided for @mapPoster.
  ///
  /// In en, this message translates to:
  /// **'Poster'**
  String get mapPoster;

  /// No description provided for @mapView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get mapView;

  /// No description provided for @dateDetailLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get dateDetailLocation;

  /// No description provided for @dateNewStep1.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2 · Place'**
  String get dateNewStep1;

  /// No description provided for @dateNewStep2.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2 · Details'**
  String get dateNewStep2;

  /// No description provided for @dateNewResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get dateNewResults;

  /// No description provided for @dateRatingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to rate'**
  String get dateRatingHint;

  /// No description provided for @calendarLegendDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get calendarLegendDate;

  /// No description provided for @calendarLegendPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get calendarLegendPlan;

  /// No description provided for @calendarLegendWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get calendarLegendWeek;

  /// No description provided for @calendarIdeasNoDate.
  ///
  /// In en, this message translates to:
  /// **'Ideas without a date'**
  String get calendarIdeasNoDate;

  /// No description provided for @calendarAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get calendarAdd;

  /// No description provided for @calendarPlanIt.
  ///
  /// In en, this message translates to:
  /// **'Plan it'**
  String get calendarPlanIt;

  /// No description provided for @protectIntro.
  ///
  /// In en, this message translates to:
  /// **'Use these to protect your streak.'**
  String get protectIntro;

  /// No description provided for @protectIntroWeeks.
  ///
  /// In en, this message translates to:
  /// **'Use these to protect your {count}-week streak.'**
  String protectIntroWeeks(int count);

  /// No description provided for @protectRepairSub.
  ///
  /// In en, this message translates to:
  /// **'Log a backdated date, within 48h of the week closing.'**
  String get protectRepairSub;

  /// No description provided for @freezeQuotaChip.
  ///
  /// In en, this message translates to:
  /// **'1 free available'**
  String get freezeQuotaChip;

  /// No description provided for @freezeNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'What happens to the streak?'**
  String get freezeNoteTitle;

  /// No description provided for @freezeNoteBody.
  ///
  /// In en, this message translates to:
  /// **'Paused weeks don\'t break it, but they don\'t add either. After the pause it picks up where you left off.'**
  String get freezeNoteBody;

  /// No description provided for @repairConfirmNote.
  ///
  /// In en, this message translates to:
  /// **'The repair stays pending your partner\'s confirmation. You both have to agree for it to count.'**
  String get repairConfirmNote;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'back to your streak'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'start your streak today'**
  String get registerSubtitle;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @pwWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get pwWeak;

  /// No description provided for @pwFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get pwFair;

  /// No description provided for @pwGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get pwGood;

  /// No description provided for @pwStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get pwStrong;

  /// No description provided for @pwReqMin8.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get pwReqMin8;

  /// No description provided for @pwReqUpper.
  ///
  /// In en, this message translates to:
  /// **'At least one capital letter'**
  String get pwReqUpper;

  /// No description provided for @pwReqNumber.
  ///
  /// In en, this message translates to:
  /// **'At least one number'**
  String get pwReqNumber;

  /// No description provided for @forgotDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email'**
  String get forgotDoneTitle;

  /// No description provided for @forgotOauthNote.
  ///
  /// In en, this message translates to:
  /// **'If you signed up with Google or Apple, use that same method to get in.'**
  String get forgotOauthNote;

  /// No description provided for @resetWarning.
  ///
  /// In en, this message translates to:
  /// **'Changing your password signs out every other device.'**
  String get resetWarning;

  /// No description provided for @resetConfirmLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat password'**
  String get resetConfirmLabel;

  /// No description provided for @resetMismatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'t match'**
  String get resetMismatch;

  /// No description provided for @verifyAlreadyDone.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified'**
  String get verifyAlreadyDone;

  /// No description provided for @verifyBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Until you verify, you can\'t:'**
  String get verifyBlockedTitle;

  /// No description provided for @verifyBlocked1.
  ///
  /// In en, this message translates to:
  /// **'Log dates'**
  String get verifyBlocked1;

  /// No description provided for @verifyBlocked2.
  ///
  /// In en, this message translates to:
  /// **'Create or join a couple'**
  String get verifyBlocked2;

  /// No description provided for @verifyBlocked3.
  ///
  /// In en, this message translates to:
  /// **'Get notifications'**
  String get verifyBlocked3;

  /// No description provided for @coupleSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect it to start the streak'**
  String get coupleSetupSubtitle;

  /// No description provided for @coupleSetupCreateSub.
  ///
  /// In en, this message translates to:
  /// **'You make the space and share the code'**
  String get coupleSetupCreateSub;

  /// No description provided for @coupleSetupJoinSub.
  ///
  /// In en, this message translates to:
  /// **'Your partner already made it'**
  String get coupleSetupJoinSub;

  /// No description provided for @coupleJoinInstruction.
  ///
  /// In en, this message translates to:
  /// **'Ask your partner for the 6-character code'**
  String get coupleJoinInstruction;

  /// No description provided for @coupleWaitingCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get coupleWaitingCodeLabel;

  /// No description provided for @coupleWaitingTapToCopy.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy'**
  String get coupleWaitingTapToCopy;

  /// No description provided for @coupleWaitingPolling.
  ///
  /// In en, this message translates to:
  /// **'Waiting…'**
  String get coupleWaitingPolling;

  /// No description provided for @planHasDate.
  ///
  /// In en, this message translates to:
  /// **'Have a date?'**
  String get planHasDate;

  /// No description provided for @planHasDateSub.
  ///
  /// In en, this message translates to:
  /// **'With no date it\'s saved as an idea'**
  String get planHasDateSub;

  /// No description provided for @planNoteIdea.
  ///
  /// In en, this message translates to:
  /// **'It\'s saved as an idea in the calendar\'s Ideas tab.'**
  String get planNoteIdea;

  /// No description provided for @planNoteProposed.
  ///
  /// In en, this message translates to:
  /// **'Your partner gets a nudge to confirm the plan.'**
  String get planNoteProposed;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get navDates;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;
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
      <String>['en', 'es'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
