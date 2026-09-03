/// Plain models for the auth feature. These will move to freezed + json
/// serialization with the shared models task; hand-written for now so the slice
/// runs without a codegen step.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.timezone,
    required this.locale,
    this.avatarUrl,
    this.emailVerified = true,
    this.status = 'active',
  });

  final String id;
  final String email;
  final String displayName;
  final String timezone;
  final String locale;
  final String? avatarUrl;
  final bool emailVerified;
  final String status; // active | pending_deletion | deleted

  bool get pendingDeletion => status == 'pending_deletion';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['display_name'] as String,
        timezone: json['timezone'] as String,
        locale: (json['locale'] ?? 'es') as String,
        avatarUrl: json['avatar_url'] as String?,
        emailVerified: json.containsKey('email_verified_at')
            ? json['email_verified_at'] != null
            : true,
        status: (json['status'] ?? 'active') as String,
      );
}

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.coupleId,
  });

  final String accessToken;
  final String refreshToken;
  final AppUser user;
  final String? coupleId;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
        user: AppUser.fromJson((json['user'] as Map).cast<String, dynamic>()),
        coupleId: json['couple_id'] as String?,
      );
}

/// Where the user should land after the splash checks GET /me.
enum BootstrapRoute { onboarding, coupleSetup, home }

class MeBootstrap {
  const MeBootstrap({
    required this.user,
    required this.route,
    this.coupleName,
    this.deletionScheduledFor,
  });

  final AppUser user;
  final BootstrapRoute route;
  final String? coupleName;
  final DateTime? deletionScheduledFor;

  bool get emailVerified => user.emailVerified;
  bool get pendingDeletion => user.pendingDeletion;

  factory MeBootstrap.fromJson(Map<String, dynamic> json) {
    final user = AppUser.fromJson((json['user'] as Map).cast<String, dynamic>());
    final couple = json['couple'];
    return MeBootstrap(
      user: user,
      coupleName: couple is Map ? couple['name'] as String? : null,
      route: couple == null ? BootstrapRoute.coupleSetup : BootstrapRoute.home,
    );
  }
}
