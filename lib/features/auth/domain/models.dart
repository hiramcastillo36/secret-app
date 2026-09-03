/// Plain hand-written models for the auth feature. Every [fromJson] tolerates a
/// missing or null field rather than throwing, so a slimmer server response can
/// never crash the bootstrap.
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.timezone,
    required this.locale,
    this.avatarUrl,
    this.emailVerified = false,
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
    id: (json['id'] ?? '') as String,
    email: (json['email'] ?? '') as String,
    displayName: (json['display_name'] ?? '') as String,
    timezone: (json['timezone'] ?? 'UTC') as String,
    locale: (json['locale'] ?? 'es') as String,
    avatarUrl: json['avatar_url'] as String?,
    // Absent or null => not verified. Never assume verified.
    emailVerified: json['email_verified_at'] != null,
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
    accessToken: (json['access_token'] ?? '') as String,
    refreshToken: (json['refresh_token'] ?? '') as String,
    user: AppUser.fromJson(
      ((json['user'] as Map?) ?? const {}).cast<String, dynamic>(),
    ),
    coupleId: json['couple_id'] as String?,
  );
}

/// Where the user should land after the splash checks GET /me.
enum BootstrapRoute { coupleSetup, home }

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
    final user = AppUser.fromJson(
      ((json['user'] as Map?) ?? const {}).cast<String, dynamic>(),
    );
    final couple = json['couple'];
    final scheduled = json['deletion_scheduled_for'];
    return MeBootstrap(
      user: user,
      coupleName: couple is Map ? couple['name'] as String? : null,
      route: couple == null ? BootstrapRoute.coupleSetup : BootstrapRoute.home,
      deletionScheduledFor: scheduled is String
          ? DateTime.tryParse(scheduled)?.toLocal()
          : null,
    );
  }
}
