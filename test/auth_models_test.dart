import 'package:flutter_test/flutter_test.dart';
import 'package:racha/features/auth/domain/models.dart';

void main() {
  group('AppUser.fromJson', () {
    test('absent email_verified_at means NOT verified (never assume true)', () {
      final u = AppUser.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'display_name': 'A',
        'timezone': 'UTC',
        'locale': 'es',
      });
      expect(u.emailVerified, isFalse);
    });

    test('null email_verified_at means NOT verified', () {
      final u = AppUser.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'display_name': 'A',
        'timezone': 'UTC',
        'locale': 'es',
        'email_verified_at': null,
      });
      expect(u.emailVerified, isFalse);
    });

    test('a timestamp means verified', () {
      final u = AppUser.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'display_name': 'A',
        'timezone': 'UTC',
        'locale': 'es',
        'email_verified_at': '2026-01-01T00:00:00Z',
      });
      expect(u.emailVerified, isTrue);
    });

    test('pending_deletion status is reflected', () {
      final u = AppUser.fromJson({
        'id': 'u1',
        'email': 'a@b.com',
        'display_name': 'A',
        'timezone': 'UTC',
        'locale': 'es',
        'status': 'pending_deletion',
      });
      expect(u.pendingDeletion, isTrue);
    });
  });

  group('MeBootstrap.fromJson', () {
    test('no couple -> coupleSetup route, no throw on a minimal payload', () {
      final me = MeBootstrap.fromJson({
        'user': {
          'id': 'u1',
          'email': 'a@b.com',
          'display_name': 'A',
          'timezone': 'UTC',
          'locale': 'es',
        },
        'couple': null,
      });
      expect(me.route, BootstrapRoute.coupleSetup);
      expect(me.deletionScheduledFor, isNull);
      expect(me.emailVerified, isFalse);
    });

    test('parses deletion_scheduled_for into a local DateTime', () {
      final me = MeBootstrap.fromJson({
        'user': {
          'id': 'u1',
          'email': 'a@b.com',
          'display_name': 'A',
          'timezone': 'UTC',
          'locale': 'es',
          'status': 'pending_deletion',
        },
        'couple': null,
        'deletion_scheduled_for': '2026-03-01T12:00:00Z',
      });
      expect(me.pendingDeletion, isTrue);
      expect(me.deletionScheduledFor, isNotNull);
      expect(me.deletionScheduledFor!.isUtc, isFalse);
    });

    test('couple present -> home route with name', () {
      final me = MeBootstrap.fromJson({
        'user': {
          'id': 'u1',
          'email': 'a@b.com',
          'display_name': 'A',
          'timezone': 'UTC',
          'locale': 'es',
        },
        'couple': {'name': 'A & B'},
      });
      expect(me.route, BootstrapRoute.home);
      expect(me.coupleName, 'A & B');
    });
  });
}
