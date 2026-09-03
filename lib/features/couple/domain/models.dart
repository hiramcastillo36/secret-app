// Plain models for the couple feature (freezed migration comes with the shared
// models task).

class Couple {
  const Couple({
    required this.id,
    required this.name,
    required this.status,
    required this.timezone,
    required this.weekStart,
    this.inviteCode,
    this.startedAt,
  });

  final String id;
  final String name;
  final String status; // pending | active | closed
  final String timezone;
  final String weekStart;
  final String? inviteCode; // only present while pending
  final DateTime? startedAt;

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';

  factory Couple.fromJson(Map<String, dynamic> json) => Couple(
        id: json['id'] as String,
        name: json['name'] as String,
        status: json['status'] as String,
        timezone: json['timezone'] as String,
        weekStart: (json['week_start'] ?? 'monday') as String,
        inviteCode: json['invite_code'] as String?,
        startedAt: json['started_at'] == null
            ? null
            : DateTime.parse(json['started_at'] as String),
      );
}

class CoupleMember {
  const CoupleMember({
    required this.userId,
    required this.displayName,
    required this.role,
    this.avatarUrl,
  });

  final String userId;
  final String displayName;
  final String role;
  final String? avatarUrl;

  factory CoupleMember.fromJson(Map<String, dynamic> json) => CoupleMember(
        userId: json['user_id'] as String,
        displayName: json['display_name'] as String,
        role: json['role'] as String,
        avatarUrl: json['avatar_url'] as String?,
      );
}

class CoupleView {
  const CoupleView({required this.couple, required this.members});

  final Couple couple;
  final List<CoupleMember> members;

  factory CoupleView.fromJson(Map<String, dynamic> json) => CoupleView(
        couple: Couple.fromJson((json['couple'] as Map).cast<String, dynamic>()),
        members: ((json['members'] as List?) ?? const [])
            .map((e) => CoupleMember.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
      );
}

class JoinResult {
  const JoinResult({required this.couple, required this.partner});

  final Couple couple;
  final CoupleMember partner;

  factory JoinResult.fromJson(Map<String, dynamic> json) => JoinResult(
        couple: Couple.fromJson((json['couple'] as Map).cast<String, dynamic>()),
        partner:
            CoupleMember.fromJson((json['partner'] as Map).cast<String, dynamic>()),
      );
}
