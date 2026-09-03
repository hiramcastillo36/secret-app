import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/api/dio_client.dart';

/// ISO-8601 week key ("YYYY-Www") for a local date. Monday-based, matching the
/// backend — the streak week is never locale-dependent.
String isoWeekKey(DateTime d) {
  final date = DateTime(d.year, d.month, d.day);
  final monBased = (date.weekday + 6) % 7; // Mon=0 … Sun=6
  final thursday = date.add(Duration(days: 3 - monBased));
  final firstThursday = DateTime(thursday.year, 1, 4);
  final week1Monday =
      firstThursday.subtract(Duration(days: (firstThursday.weekday + 6) % 7));
  final weekNum = (thursday.difference(week1Monday).inDays ~/ 7) + 1;
  return '${thursday.year.toString().padLeft(4, '0')}-W${weekNum.toString().padLeft(2, '0')}';
}

class ActiveFreeze {
  const ActiveFreeze({
    required this.id,
    required this.reason,
    required this.startsWeekKey,
    required this.endsWeekKey,
    required this.createdBy,
  });

  final String id;
  final String reason;
  final String startsWeekKey;
  final String endsWeekKey;
  final String createdBy;

  factory ActiveFreeze.fromJson(Map<String, dynamic> j) => ActiveFreeze(
        id: j['id'] as String,
        reason: (j['reason'] ?? 'other') as String,
        startsWeekKey: (j['starts_week_key'] ?? '') as String,
        endsWeekKey: (j['ends_week_key'] ?? '') as String,
        createdBy: (j['created_by'] ?? '') as String,
      );
}

class PendingRepair {
  const PendingRepair({
    required this.id,
    required this.targetWeekKey,
    required this.requestedBy,
    required this.isMine,
    required this.requestedAt,
  });

  final String id;
  final String targetWeekKey;
  final String requestedBy;

  /// True when the caller filed it (and is waiting). False → it's the caller's
  /// turn to confirm.
  final bool isMine;
  final String requestedAt;

  factory PendingRepair.fromJson(Map<String, dynamic> j) => PendingRepair(
        id: j['id'] as String,
        targetWeekKey: (j['target_week_key'] ?? '') as String,
        requestedBy: (j['requested_by'] ?? '') as String,
        isMine: (j['is_mine'] ?? false) as bool,
        requestedAt: (j['requested_at'] ?? '') as String,
      );
}

class ProtectHub {
  const ProtectHub({
    required this.activeFreeze,
    required this.freezeQuotaUsed,
    required this.quotaMonth,
    required this.pendingRepairs,
    required this.repairAvailable,
    required this.lastWeekKey,
  });

  final ActiveFreeze? activeFreeze;
  final bool freezeQuotaUsed;
  final String quotaMonth;
  final List<PendingRepair> pendingRepairs;
  final bool repairAvailable;
  final String lastWeekKey;

  /// A pending repair the caller must answer, if any.
  PendingRepair? get needsMyAnswer {
    for (final r in pendingRepairs) {
      if (!r.isMine) return r;
    }
    return null;
  }

  factory ProtectHub.fromJson(Map<String, dynamic> j) => ProtectHub(
        activeFreeze: j['active_freeze'] == null
            ? null
            : ActiveFreeze.fromJson((j['active_freeze'] as Map).cast<String, dynamic>()),
        freezeQuotaUsed: (j['freeze_quota_used'] ?? false) as bool,
        quotaMonth: (j['quota_month'] ?? '') as String,
        pendingRepairs: ((j['pending_repairs'] as List?) ?? const [])
            .map((e) => PendingRepair.fromJson((e as Map).cast<String, dynamic>()))
            .toList(),
        repairAvailable: (j['repair_available'] ?? false) as bool,
        lastWeekKey: (j['last_week_key'] ?? '') as String,
      );
}

class ProtectRepository {
  ProtectRepository(this._dio);
  final Dio _dio;

  Future<ProtectHub> hub() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/streaks/protect');
      return ProtectHub.fromJson(res.data!);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /streaks/freeze. Reason is travel | illness | other.
  Future<void> createFreeze({
    required String reason,
    required String startsWeekKey,
    required String endsWeekKey,
  }) async {
    try {
      await _dio.post<Map<String, dynamic>>('/streaks/freeze', data: {
        'reason': reason,
        'starts_week_key': startsWeekKey,
        'ends_week_key': endsWeekKey,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> cancelFreeze(String id) async {
    try {
      await _dio.delete<Map<String, dynamic>>('/streaks/freeze/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /streaks/repair — files a tentative date for a closed week.
  Future<void> createRepair({required DateTime happenedAt, String? title}) async {
    try {
      await _dio.post<Map<String, dynamic>>('/streaks/repair', data: {
        'happened_at': happenedAt.toUtc().toIso8601String(),
        if (title != null && title.isNotEmpty) 'title': title,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// decision: confirm | reject.
  Future<void> respondRepair(String id, String decision) async {
    try {
      await _dio.post<Map<String, dynamic>>('/streaks/repair/$id/respond',
          data: {'decision': decision});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

final protectRepositoryProvider = Provider<ProtectRepository>((ref) {
  return ProtectRepository(ref.watch(dioProvider));
});

final protectHubProvider = FutureProvider.autoDispose<ProtectHub>((ref) {
  return ref.watch(protectRepositoryProvider).hub();
});
