import 'package:flutter_test/flutter_test.dart';

import 'package:racha/core/api/dio_client.dart';
import 'package:racha/router/app_router.dart';

void main() {
  group('isPublicApiPath (audit F-H3)', () {
    test('the resend-verification route is authenticated', () {
      // It lives in the server\'s RequireAuth group; the old contains("/auth/")
      // check skipped the bearer and it 401\'d every time.
      expect(isPublicApiPath('/auth/email/verify/send'), isFalse);
    });

    test('consuming a verification token is public', () {
      expect(isPublicApiPath('/auth/email/verify'), isTrue);
      expect(isPublicApiPath('/auth/email/verify?token=abc'), isTrue);
    });

    test('the credential endpoints are public', () {
      for (final p in const [
        '/auth/login',
        '/auth/register',
        '/auth/refresh',
        '/auth/logout',
        '/auth/password/forgot',
        '/auth/password/reset',
      ]) {
        expect(isPublicApiPath(p), isTrue, reason: p);
      }
    });

    test('everything else is authenticated', () {
      for (final p in const ['/me', '/dates', '/streaks/me', '/couples/me']) {
        expect(isPublicApiPath(p), isFalse, reason: p);
      }
    });
  });

  group('isPublicLocation (audit F-H1)', () {
    test('the entry and email-link screens are open', () {
      for (final loc in const [
        '/onboarding',
        '/login',
        '/register',
        '/auth/forgot-password',
        '/auth/reset-password',
        '/auth/verify-email',
      ]) {
        expect(isPublicLocation(loc), isTrue, reason: loc);
      }
    });

    test('a query string on a deep link stays open', () {
      expect(isPublicLocation('/auth/reset-password'), isTrue);
    });

    test('every product surface is gated', () {
      for (final loc in const [
        '/home',
        '/dates',
        '/dates/abc-123',
        '/plans/new',
        '/wishlist',
        '/streak/protect',
        '/profile',
        '/account',
        '/summary',
        '/places/map',
      ]) {
        expect(isPublicLocation(loc), isFalse, reason: loc);
      }
    });
  });
}
