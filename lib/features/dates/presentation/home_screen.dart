import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../auth/application/auth.dart';
import '../../common/section_label.dart';
import '../../common/stat_tile.dart';
import '../../couple/application/couple.dart';
import '../../notifications/application/notifications.dart';
import '../../plans/application/plans.dart';
import '../../plans/domain/models.dart';
import '../../streak/application/protect.dart';
import '../../wishlist/application/wishlist.dart';
import '../application/dates.dart';
import '../domain/models.dart';
import 'date_format.dart';

/// The main screen: a large animated streak counter on a plum hero, a 12-week
/// strip coloured by week status, a compact stat strip, the last few dates, the
/// most-visited place and a FAB to log a new date.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final streak = ref.watch(streakProvider);
    final recent = ref.watch(recentDatesProvider);
    final me = ref.watch(meProvider).valueOrNull;
    final unread = ref.watch(unreadNotificationsProvider).valueOrNull ?? 0;
    final plans = ref.watch(plansListProvider).valueOrNull;
    final hub = ref.watch(protectHubProvider).valueOrNull;
    final wishes = ref.watch(wishlistProvider).valueOrNull;
    final overview = ref.watch(overviewProvider).valueOrNull;
    final places = ref.watch(summaryPlacesProvider).valueOrNull;
    final coupleName =
        ref.watch(coupleMeProvider).valueOrNull?.couple.name ?? me?.coupleName;

    return Scaffold(
      appBar: AppBar(
        title: Text(coupleName ?? l10n.appTitle),
        actions: [
          IconButton(
            onPressed: () => context.push('/calendar'),
            tooltip: l10n.a11yCalendar,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            onPressed: () async {
              await context.push('/activity');
              ref.invalidate(unreadNotificationsProvider);
            },
            tooltip: unread > 0
                ? l10n.a11yNotificationsUnread(unread)
                : l10n.a11yNotifications,
            icon: Badge(
              isLabelVisible: unread > 0,
              // The count is already in the button's tooltip/label; keep the
              // visual badge out of the semantics tree to avoid it being read
              // as a separate, context-free number.
              label: ExcludeSemantics(
                child: Text(unread > 99 ? '99+' : '$unread'),
              ),
              child: const Icon(Icons.notifications_none_outlined),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(streakProvider);
          ref.invalidate(recentDatesProvider);
          ref.invalidate(overviewProvider);
          ref.invalidate(summaryPlacesProvider);
          await ref.read(streakProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            RachaTokens.space5,
            RachaTokens.space5,
            RachaTokens.space5,
            RachaTokens.space7 + RachaTokens.space5,
          ),
          children: [
            if (me != null && me.user.pendingDeletion)
              _Banner(
                text: me.deletionScheduledFor != null
                    ? l10n.homeDeletionBannerOn(
                        DateFormat.yMMMMd(
                          Localizations.localeOf(context).toString(),
                        ).format(me.deletionScheduledFor!),
                      )
                    : l10n.homeDeletionBanner,
                strong: true,
                actionLabel: l10n.homeCancelDeletion,
                onAction: () => context.push('/account'),
              ),
            if (me != null && !me.user.emailVerified)
              _Banner(
                text: l10n.homeVerifyEmailBanner,
                actionLabel: l10n.accountVerifyNow,
                onAction: () => context.push('/auth/verify-email'),
              ),
            if (hub?.needsMyAnswer != null)
              _Banner(
                text: l10n.homeRepairPending,
                strong: true,
                actionLabel: l10n.homePlanRespond,
                onAction: () async {
                  await context.push(
                    '/streak/repair/${hub!.needsMyAnswer!.id}',
                  );
                  ref.invalidate(protectHubProvider);
                  ref.invalidate(streakProvider);
                },
              ),

            streak.when(
              loading: () => const _CounterSkeleton(),
              error: (_, __) =>
                  _RetryTile(onRetry: () => ref.invalidate(streakProvider)),
              data: (s) => _StreakHero(streak: s),
            ),

            if (overview != null) ...[
              const SizedBox(height: RachaTokens.space4),
              Row(
                children: [
                  StatTile(
                    value: '${overview.totalDates}',
                    label: l10n.homeStatTotal,
                  ),
                  const SizedBox(width: RachaTokens.space3),
                  StatTile(
                    value: l10n.wrappedWeeksShort(overview.longestStreak),
                    label: l10n.homeStatRecord,
                  ),
                  const SizedBox(width: RachaTokens.space3),
                  StatTile(
                    value: '${_thisMonthCount(overview)}',
                    label: l10n.homeStatMonth,
                  ),
                ],
              ),
            ],

            if (plans != null) ...[
              const SizedBox(height: RachaTokens.space6),
              _NextPlan(
                plans: plans,
                myId: me?.user.id,
                onChanged: () => ref.invalidate(plansListProvider),
              ),
            ],

            const SizedBox(height: RachaTokens.space6),
            recent.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => _RetryTile(
                onRetry: () => ref.invalidate(recentDatesProvider),
              ),
              data: (page) => _RecentSection(dates: page.dates),
            ),

            if (places != null && places.places.isNotEmpty) ...[
              const SizedBox(height: RachaTokens.space6),
              SectionLabel(l10n.homeFavPlace),
              const SizedBox(height: RachaTokens.space2),
              _FavPlaceCard(place: places.places.first),
            ],

            if (wishes != null && wishes.counts.open > 0) ...[
              const SizedBox(height: RachaTokens.space5),
              _WishlistCard(open: wishes.counts.open),
            ],

            const SizedBox(height: RachaTokens.space5),
            _ProtectShortcut(
              onTap: () async {
                await context.push('/streak/protect');
                ref.invalidate(protectHubProvider);
                ref.invalidate(streakProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  int _thisMonthCount(Overview ov) =>
      ov.datesByMonth.isEmpty ? 0 : ov.datesByMonth.last.count;
}

/// The one element allowed to shout: a plum hero with the animated week count,
/// the 12-week strip and a status pill.
class _StreakHero extends StatelessWidget {
  const _StreakHero({required this.streak});
  final StreakView streak;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: RachaTokens.space6,
        horizontal: RachaTokens.space5,
      ),
      decoration: const BoxDecoration(
        borderRadius: RachaTokens.brL,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: RachaTokens.streakGradient,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(width: RachaTokens.space3),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: streak.currentStreak.toDouble()),
                duration: MediaQuery.of(context).disableAnimations
                    ? Duration.zero
                    : const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Text(
                  value.round().toString(),
                  style: const TextStyle(
                    fontSize: RachaType.display,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: RachaTokens.space1),
          Text(
            l10n.homeStreakConsecutive,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              fontSize: RachaType.callout,
            ),
          ),
          if (streak.season.best > streak.currentStreak) ...[
            const SizedBox(height: 2),
            Text(
              l10n.homeSeasonBest(streak.season.best),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: RachaType.caption,
              ),
            ),
          ],
          const SizedBox(height: RachaTokens.space5),
          _WeekStrip(weeks: streak.recentWeeks, frozen: streak.recentFrozen),
          const SizedBox(height: RachaTokens.space4),
          _StatusPill(status: streak.weekStatus, daysLeft: streak.daysLeft),
          if (streak.weekStatus == WeekStatus.covered) ...[
            const SizedBox(height: RachaTokens.space3),
            Text(
              l10n.homeWeekCoveredCheer,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: RachaType.caption,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.weeks, this.frozen = const []});
  final List<bool> weeks;
  final List<bool> frozen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dots = weeks.isEmpty ? List<bool>.filled(12, false) : weeks;
    final done = dots.where((w) => w).length;
    return Semantics(
      container: true,
      excludeSemantics: true,
      label: '${l10n.a11yWeekStrip}: $done/${dots.length}',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < dots.length; i++)
            Builder(
              builder: (_) {
                final isFrozen = i < frozen.length && frozen[i] && !dots[i];
                final Color fill;
                if (dots[i]) {
                  fill = Colors.white;
                } else if (isFrozen) {
                  fill = RachaTokens.atRiskDark;
                } else {
                  fill = Colors.white.withValues(alpha: 0.22);
                }
                // Older weeks fade slightly so the eye lands on the recent end.
                final age = dots.length <= 1
                    ? 1.0
                    : 0.55 + (i / (dots.length - 1)) * 0.45;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fill.withValues(alpha: (fill.a * age).clamp(0, 1)),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.daysLeft});
  final WeekStatus status;
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (String label, Color fg) = switch (status) {
      WeekStatus.covered => (l10n.homeWeekCovered, RachaTokens.okLight),
      WeekStatus.atRisk => (
        l10n.homeWeekAtRisk(daysLeft),
        RachaTokens.atRiskLight,
      ),
      WeekStatus.frozen => (l10n.homeStreakFrozen, RachaTokens.atRiskLight),
      WeekStatus.open => (l10n.homeWeekOpen, RachaTokens.seed),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RachaTokens.space4,
        vertical: RachaTokens.space2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RachaTokens.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: RachaType.callout,
        ),
      ),
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.dates});
  final List<DateEntry> dates;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    if (dates.isEmpty) {
      return Column(
        children: [
          Text(
            l10n.homeEmptyTitle,
            style: const TextStyle(
              fontSize: RachaType.headline,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: RachaTokens.space2),
          Text(
            l10n.homeEmptyBody,
            style: TextStyle(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(
          l10n.homeRecentTitle,
          trailing: TextButton(
            onPressed: () => context.push('/dates'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: RachaTokens.space2,
              ),
            ),
            child: Text(l10n.homeSeeAll),
          ),
        ),
        const SizedBox(height: RachaTokens.space3),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: RachaTokens.space3),
            itemBuilder: (context, i) => _MiniDateCard(date: dates[i]),
          ),
        ),
      ],
    );
  }
}

class _MiniDateCard extends StatelessWidget {
  const _MiniDateCard({required this.date});
  final DateEntry date;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push('/dates/${date.id}'),
      borderRadius: RachaTokens.brM,
      child: SizedBox(
        width: 132,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 68,
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: RachaTokens.brM,
              ),
              child: Icon(
                categoryIcon(date.place?.category ?? 'other'),
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: RachaTokens.space2),
            Text(
              date.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: RachaType.caption,
              ),
            ),
            Text(
              relativeDay(context, date.happenedAt),
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: RachaType.micro,
              ),
            ),
            const SizedBox(height: 2),
            if (date.rating != null) _RatingDots(rating: date.rating!),
          ],
        ),
      ),
    );
  }
}

class _RatingDots extends StatelessWidget {
  const _RatingDots({required this.rating});
  final int rating;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      excludeSemantics: true,
      label: AppLocalizations.of(context).a11yRatingStars(rating),
      child: Row(
        children: [
          for (var n = 1; n <= 5; n++)
            Container(
              margin: const EdgeInsets.only(right: 3),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: n <= rating ? scheme.primary : scheme.outlineVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _FavPlaceCard extends StatelessWidget {
  const _FavPlaceCard({required this.place});
  final PlaceStat place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: place.placeId.isEmpty
          ? null
          : () => context.push('/places/${place.placeId}'),
      borderRadius: RachaTokens.brM,
      child: Container(
        padding: const EdgeInsets.all(RachaTokens.space3),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: RachaTokens.brM,
          border: Border.all(
            color: scheme.outlineVariant,
            width: RachaTokens.borderHairline,
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: RachaTokens.brS,
              ),
              child: Icon(
                categoryIcon(place.category),
                color: scheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: RachaTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${l10n.summaryVisitsCount(place.visits)} · ${place.category}',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: RachaType.caption,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ProtectShortcut extends StatelessWidget {
  const _ProtectShortcut({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: RachaTokens.brM,
      child: Container(
        padding: const EdgeInsets.all(RachaTokens.space4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: RachaTokens.brM,
          border: Border.all(
            color: scheme.outlineVariant,
            width: RachaTokens.borderHairline,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.shield_outlined, color: scheme.onSurfaceVariant),
            const SizedBox(width: RachaTokens.space3),
            Expanded(
              child: Text(
                l10n.protectTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.text,
    required this.actionLabel,
    required this.onAction,
    this.strong = false,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onAction;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = strong ? scheme.errorContainer : scheme.surfaceContainerHighest;
    final fg = strong ? scheme.onErrorContainer : scheme.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: RachaTokens.space4),
      padding: const EdgeInsets.fromLTRB(
        RachaTokens.space4,
        RachaTokens.space2,
        RachaTokens.space2,
        RachaTokens.space2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: RachaTokens.brM,
        border: Border.all(
          color: strong ? scheme.error : scheme.outlineVariant,
          width: RachaTokens.borderHairline,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(text, style: TextStyle(color: fg)),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

/// The next dated plan, shown below the counter. If a plan is waiting for the
/// viewer's answer, it becomes a prompt with a Respond button.
class _NextPlan extends StatelessWidget {
  const _NextPlan({
    required this.plans,
    required this.myId,
    required this.onChanged,
  });
  final PlanList plans;
  final String? myId;
  final VoidCallback onChanged;

  Plan? get _awaitingMe {
    for (final p in plans.plans) {
      if (p.status == 'proposed' && myId != null && p.proposedBy != myId) {
        return p;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final pending = _awaitingMe;
    final next = plans.next;
    if (pending == null && next == null) return const SizedBox.shrink();

    final plan = pending ?? next!;
    final prompt = pending != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.homeNextPlan),
        const SizedBox(height: RachaTokens.space2),
        Container(
          padding: const EdgeInsets.all(RachaTokens.space4),
          decoration: BoxDecoration(
            color: prompt
                ? scheme.primaryContainer
                : scheme.surfaceContainerLow,
            borderRadius: RachaTokens.brM,
            border: Border.all(
              color: prompt ? scheme.primary : scheme.outlineVariant,
              width: RachaTokens.borderHairline,
            ),
          ),
          child: Row(
            children: [
              Icon(
                prompt
                    ? Icons.mark_email_unread_outlined
                    : Icons.event_available_outlined,
                color: prompt
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: RachaTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (prompt)
                      Text(
                        l10n.homePlansPending(plans.needsResponse),
                        style: TextStyle(
                          fontSize: RachaType.caption,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    Text(
                      plan.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if (plan.scheduledAt != null)
                      Text(
                        relativeDay(context, plan.scheduledAt!),
                        style: TextStyle(
                          fontSize: RachaType.caption,
                          color: prompt
                              ? scheme.onPrimaryContainer
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await context.push('/plans/${plan.id}');
                  onChanged();
                },
                child: Text(prompt ? l10n.homePlanRespond : l10n.homeSeeAll),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "What to do this week" — a nudge toward the wishlist when it has open ideas.
class _WishlistCard extends StatelessWidget {
  const _WishlistCard({required this.open});
  final int open;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push('/wishlist'),
      borderRadius: RachaTokens.brM,
      child: Container(
        padding: const EdgeInsets.all(RachaTokens.space4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: RachaTokens.brM,
          border: Border.all(
            color: scheme.outlineVariant,
            width: RachaTokens.borderHairline,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: scheme.onSurfaceVariant),
            const SizedBox(width: RachaTokens.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeWishlistCard,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    l10n.homeWishlistWaiting(open),
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: RachaType.caption,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _CounterSkeleton extends StatelessWidget {
  const _CounterSkeleton();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: RachaTokens.brL,
        color: scheme.surfaceContainerHighest,
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _RetryTile extends StatelessWidget {
  const _RetryTile({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(RachaTokens.space5),
        child: Column(
          children: [
            Text(l10n.commonSomethingWentWrong, textAlign: TextAlign.center),
            TextButton(onPressed: onRetry, child: Text(l10n.commonRetry)),
          ],
        ),
      ),
    );
  }
}
