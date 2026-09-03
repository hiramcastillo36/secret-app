import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';

/// Maps couple endpoint error codes to screen copy. Unknown codes fall back to
/// the server's already-localized message.
String coupleErrorText(AppLocalizations l10n, Object error) {
  if (error is! ApiException) return l10n.commonSomethingWentWrong;
  switch (error.code) {
    case 'NETWORK':
      return l10n.commonNoConnection;
    case 'INVALID_INVITE_CODE':
      return l10n.coupleJoinErrorInvalid;
    case 'INVITE_EXPIRED':
      return l10n.coupleJoinErrorExpired;
    case 'COUPLE_FULL':
      return l10n.coupleJoinErrorFull;
    case 'ALREADY_MEMBER':
      return l10n.coupleJoinErrorAlreadyMember;
    case 'ALREADY_IN_COUPLE':
      return l10n.coupleJoinErrorAlreadyInCouple;
    default:
      return error.message;
  }
}
