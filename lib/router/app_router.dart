import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/presentation/account_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/verify_email_screen.dart';
import '../features/common/placeholder_screen.dart';
import '../features/notifications/presentation/activity_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/plans/domain/models.dart';
import '../features/plans/presentation/calendar_screen.dart';
import '../features/plans/presentation/plan_detail_screen.dart';
import '../features/plans/presentation/plan_form_screen.dart';
import '../features/profile/presentation/language_screen.dart';
import '../features/couple/presentation/couple_create_screen.dart';
import '../features/couple/presentation/couple_join_screen.dart';
import '../features/couple/presentation/couple_setup_screen.dart';
import '../features/couple/presentation/couple_waiting_screen.dart';
import '../features/dates/domain/models.dart';
import '../features/dates/presentation/date_detail_screen.dart';
import '../features/dates/presentation/date_details_screen.dart';
import '../features/dates/presentation/date_edit_screen.dart';
import '../features/dates/presentation/home_screen.dart';
import '../features/dates/presentation/map_poster_screen.dart';
import '../features/dates/presentation/place_detail_screen.dart';
import '../features/dates/presentation/place_search_screen.dart';
import '../features/dates/presentation/places_map_screen.dart';
import '../features/dates/presentation/summary_screen.dart';
import '../features/dates/presentation/timeline_screen.dart';
import '../features/milestones/presentation/milestones_screen.dart';
import '../features/privacy/presentation/privacy_screen.dart';
import '../features/shell/scaffold_with_nav_bar.dart';
import '../features/wrapped/presentation/wrapped_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/streak/presentation/freeze_form_screen.dart';
import '../features/streak/presentation/protect_screen.dart';
import '../features/streak/presentation/repair_confirm_screen.dart';
import '../features/streak/presentation/repair_form_screen.dart';
import '../features/wishlist/presentation/roulette_screen.dart';
import '../features/wishlist/presentation/suggestions_screen.dart';
import '../features/wishlist/presentation/wish_form_screen.dart';
import '../features/wishlist/presentation/wishlist_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// All routes in the design. The four main sections live under a
/// [StatefulShellRoute] so the bottom bar persists across them; everything else
/// is pushed on the root navigator and covers the bar.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Pairing (slice: couples)
      GoRoute(
        path: '/couple/setup',
        builder: (_, __) => const CoupleSetupScreen(),
      ),
      GoRoute(
        path: '/couple/create',
        builder: (_, __) => const CoupleCreateScreen(),
      ),
      GoRoute(
        path: '/couple/join',
        builder: (_, __) => const CoupleJoinScreen(),
      ),
      GoRoute(
        path: '/couple/waiting',
        builder: (_, __) => const CoupleWaitingScreen(),
      ),

      // --- The four main sections, with the persistent bottom bar ---
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => ScaffoldWithNavBar(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dates',
                builder: (_, __) => const TimelineScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/places/map',
                builder: (_, __) => const PlacesMapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Register a date (modal stack over the bar)
      GoRoute(
        path: '/dates/new',
        builder: (_, __) => const PlaceSearchScreen(),
      ),
      GoRoute(
        path: '/dates/new/details',
        builder: (_, s) => DateDetailsScreen(place: s.extra as Place?),
      ),
      GoRoute(
        path: '/dates/:id/edit',
        builder: (_, s) => DateEditScreen(date: s.extra as DateEntry),
      ),
      GoRoute(
        path: '/dates/:id',
        builder: (_, s) => DateDetailScreen(dateId: s.pathParameters['id']!),
      ),

      GoRoute(
        path: '/places/poster',
        builder: (_, __) => const MapPosterScreen(),
      ),
      GoRoute(path: '/summary', builder: (_, __) => const SummaryScreen()),
      GoRoute(
        path: '/places/:id',
        builder: (_, s) => PlaceDetailScreen(placeId: s.pathParameters['id']!),
      ),

      // Resilient streak (slice: streak protection)
      GoRoute(
        path: '/streak/protect',
        builder: (_, __) => const ProtectScreen(),
      ),
      GoRoute(
        path: '/streak/freeze/new',
        builder: (_, __) => const FreezeFormScreen(),
      ),
      GoRoute(
        path: '/streak/repair/new',
        builder: (_, __) => const RepairFormScreen(),
      ),
      GoRoute(
        path: '/streak/repair/:id',
        builder: (_, s) =>
            RepairConfirmScreen(repairId: s.pathParameters['id']!),
      ),

      // Wishlist & suggestions (slice: wishlist)
      GoRoute(path: '/wishlist', builder: (_, __) => const WishlistScreen()),
      GoRoute(
        path: '/wishlist/new',
        builder: (_, __) => const WishFormScreen(),
      ),
      GoRoute(
        path: '/wishlist/roulette',
        builder: (_, __) => const RouletteScreen(),
      ),
      GoRoute(
        path: '/suggestions',
        builder: (_, __) => const SuggestionsScreen(),
      ),

      // Plans & calendar (slice: plans)
      GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
      GoRoute(
        path: '/plans/new',
        builder: (_, s) => PlanFormScreen(
          seed: switch (s.extra) {
            final PlanSeed seed => seed,
            final DateTime d => PlanSeed(date: d),
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: '/plans/:id',
        builder: (_, s) => PlanDetailScreen(planId: s.pathParameters['id']!),
      ),

      // Profile & account (settings stack over the bar)
      GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
      GoRoute(
        path: '/profile/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/profile/privacy',
        builder: (_, __) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/profile/language',
        builder: (_, __) => const LanguageScreen(),
      ),
      GoRoute(
        path: '/milestones',
        builder: (_, __) => const MilestonesScreen(),
      ),
      GoRoute(path: '/wrapped', builder: (_, __) => const WrappedScreen()),
      GoRoute(path: '/activity', builder: (_, __) => const ActivityScreen()),

      // Account recovery (E10)
      GoRoute(
        path: '/auth/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (_, s) =>
            ResetPasswordScreen(token: s.uri.queryParameters['token']),
      ),
      GoRoute(
        path: '/auth/verify-email',
        builder: (_, s) =>
            VerifyEmailScreen(token: s.uri.queryParameters['token']),
      ),
    ],
    errorBuilder: (_, state) =>
        PlaceholderScreen(title: 'Ruta no encontrada: ${state.uri}'),
  );
});
