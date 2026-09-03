import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';

/// Maps a backend error code to a screen-appropriate message. Unknown codes fall
/// back to the server-provided (already localized) message.
String authErrorText(AppLocalizations l10n, Object error) {
  if (error is! ApiException) return l10n.commonSomethingWentWrong;
  switch (error.code) {
    case 'NETWORK':
      return l10n.commonNoConnection;
    case 'INVALID_CREDENTIALS':
      return l10n.loginInvalidCredentials;
    case 'EMAIL_TAKEN':
      return l10n.registerEmailTaken;
    case 'PASSWORD_TOO_SHORT':
      return l10n.validationPasswordTooShort;
    case 'PASSWORD_NOT_SET':
      // The server message names the provider; keep it.
      return error.message;
    default:
      return error.message;
  }
}
