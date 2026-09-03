import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/auth/session_controller.dart';
import '../../../core/i18n/locale_controller.dart';
import '../../../core/storage/token_storage.dart';
import '../../../core/time/timezones.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../auth/application/auth.dart';
import '../../common/section_label.dart';
import '../../common/settings_group.dart';
import '../../couple/application/couple.dart';
import '../../couple/domain/models.dart';
import '../../dates/application/dates.dart';
import '../../dates/domain/models.dart';
import '../../dates/presentation/date_format.dart';
import '../../privacy/application/privacy.dart';
import 'language_screen.dart';

/// The couple's numbers on a plum header, then the couple + account settings and
/// the exits. Sign-out revokes the refresh token on the server before clearing
/// local state.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    // Sign-out is destructive enough to confirm (audit F, medium: it had none).
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(RachaTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.profileSignOut,
              style: const TextStyle(
                fontSize: RachaType.headline,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: RachaTokens.space2),
            Text(
              l10n.profileSignOutWarning,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: RachaTokens.space5),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: scheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.profileSignOutConfirm),
            ),
            const SizedBox(height: RachaTokens.space2),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final storage = ref.read(tokenStorageProvider);
    final refresh = await storage.readRefresh();
    if (refresh != null && refresh.isNotEmpty) {
      await ref.read(authActionsProvider.notifier).logout(refresh);
    }
    await ref.read(sessionControllerProvider.notifier).signOut();
    if (context.mounted) context.go('/splash');
  }

  Future<void> _leaveCouple(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(RachaTokens.space5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.privacyLeaveCouple,
              style: const TextStyle(
                fontSize: RachaType.headline,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: RachaTokens.space2),
            Text(
              l10n.privacyLeaveCoupleWarning,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: RachaTokens.space5),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: scheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.privacyLeaveCoupleConfirm),
            ),
            const SizedBox(height: RachaTokens.space2),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(privacyControllerProvider.notifier).leaveCouple();
      if (context.mounted) context.go('/couple/setup');
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(overviewProvider);
    final coupleView = ref.watch(coupleMeProvider).valueOrNull;
    final me = ref.watch(meProvider).valueOrNull;
    final coupleName =
        coupleView?.couple.name ?? me?.coupleName ?? l10n.profileTitle;

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (ov) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(overviewProvider);
            ref.invalidate(coupleMeProvider);
            await ref.read(overviewProvider.future);
          },
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _Header(
                coupleName: coupleName,
                overview: ov,
                members: coupleView?.members ?? const [],
              ),
              Padding(
                padding: const EdgeInsets.all(RachaTokens.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionLabel(l10n.profileDatesByMonth),
                    const SizedBox(height: RachaTokens.space3),
                    Container(
                      padding: const EdgeInsets.all(RachaTokens.space4),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: RachaTokens.brM,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: RachaTokens.borderHairline,
                        ),
                      ),
                      child: _MonthBars(months: ov.datesByMonth),
                    ),
                    const SizedBox(height: RachaTokens.space6),

                    SectionLabel(l10n.profileCoupleSettings),
                    const SizedBox(height: RachaTokens.space3),
                    SettingsGroup(
                      children: [
                        _InfoRow(
                          label: l10n.profileCoupleNameRow,
                          value: coupleView?.couple.name ?? coupleName,
                        ),
                        _InfoRow(
                          label: l10n.profileTimezone,
                          value: coupleView?.couple.timezone ?? 'â',
                          onTap: coupleView == null
                              ? null
                              : () => _pickTimezone(
                                  context,
                                  ref,
                                  coupleView.couple.timezone,
                                ),
                        ),
                        if (coupleView?.couple.inviteCode != null)
                          _InviteRow(code: coupleView!.couple.inviteCode!),
                      ],
                    ),
                    const SizedBox(height: RachaTokens.space2),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: RachaTokens.space2,
                      ),
                      child: Text(
                        l10n.coupleWeekCloseNote,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(height: RachaTokens.space6),

                    SectionLabel(l10n.profileMyAccount),
                    const SizedBox(height: RachaTokens.space3),
                    SettingsGroup(
                      children: [
                        SettingsRow(
                          icon: Icons.manage_accounts_outlined,
                          label: l10n.profileEditProfile,
                          onTap: () => context.push('/account'),
                        ),
                        SettingsRow(
                          icon: Icons.emoji_events_outlined,
                          label: l10n.milestonesTitle,
                          onTap: () => context.push('/milestones'),
                        ),
                        SettingsRow(
                          icon: Icons.auto_awesome_outlined,
                          label: l10n.wrappedEntry,
                          onTap: () => context.push('/wrapped'),
                        ),
                        SettingsRow(
                          icon: Icons.notifications_outlined,
                          label: l10n.accountNotifications,
                          onTap: () => context.push('/profile/notifications'),
                        ),
                        SettingsRow(
                          icon: Icons.lock_outline,
                          label: l10n.privacyTitle,
                          onTap: () => context.push('/profile/privacy'),
                        ),
                        SettingsRow(
                          icon: Icons.translate_outlined,
                          label: l10n.settingsLanguage,
                          value: languageLabel(
                            l10n,
                            ref.watch(localeControllerProvider),
                          ),
                          onTap: () => context.push('/profile/language'),
                        ),
                      ],
                    ),
                    const SizedBox(height: RachaTokens.space6),

                    SettingsGroup(
                      danger: true,
                      children: [
                        SettingsRow(
                          icon: Icons.logout,
                          label: l10n.profileSignOut,
                          danger: true,
                          onTap: () => _signOut(context, ref),
                        ),
                        SettingsRow(
                          icon: Icons.link_off,
                          label: l10n.privacyLeaveCouple,
                          danger: true,
                          onTap: () => _leaveCouple(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: RachaTokens.space7 + RachaTokens.space5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.coupleName,
    required this.overview,
    required this.members,
  });
  final String coupleName;
  final Overview overview;
  final List<CoupleMember> members;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final white70 = Colors.white.withValues(alpha: 0.7);
    final white50 = Colors.white.withValues(alpha: 0.5);
    final names = members
        .map((m) => m.displayName)
        .where((n) => n.isNotEmpty)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: RachaTokens.streakGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            RachaTokens.space5,
            RachaTokens.space4,
            RachaTokens.space5,
            RachaTokens.space6,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileYourCouple.toUpperCase(),
                          style: TextStyle(
                            color: white50,
                            fontSize: RachaType.micro,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          coupleName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: RachaType.title,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.profileMyAccount,
                    onPressed: () => context.push('/account'),
                    icon: const Icon(Icons.person_outline, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RachaTokens.space4),
              Row(
                children: [
                  for (var i = 0; i < names.length && i < 2; i++)
                    Align(
                      widthFactor: i == 0 ? 1 : 0.7,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: Text(
                          names[i].characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  if (names.isNotEmpty)
                    const SizedBox(width: RachaTokens.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (names.isNotEmpty)
                          Text(
                            names.take(2).join(' & '),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        Text(
                          l10n.profileTogether(overview.daysTogether),
                          style: TextStyle(
                            color: white70,
                            fontSize: RachaType.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: RachaTokens.space5),
              Row(
                children: [
                  _HeaderStat(
                    value: '${overview.totalDates}',
                    label: l10n.profileStatDates,
                  ),
                  _HeaderStat(
                    value: l10n.wrappedWeeksShort(overview.currentStreak),
                    label: l10n.profileStatStreak,
                  ),
                  _HeaderStat(
                    value: l10n.wrappedWeeksShort(overview.longestStreak),
                    label: l10n.profileStatRecord,
                  ),
                  _HeaderStat(
                    value:
                        overview.bestMonth == null ||
                            overview.bestMonth!.isEmpty
                        ? '—'
                        : monthLabel(
                            overview.bestMonth!,
                            Localizations.localeOf(context).toLanguageTag(),
                          ),
                    label: l10n.profileStatBestMonth,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: RachaTokens.space2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: RachaTokens.brS,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: RachaType.body,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: RachaType.micro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Opens a picker for the couple's IANA timezone and patches it (audit F, low:
/// the zone was fixed at creation and profile showed it read-only). The server
/// recalculates the streak against the new week boundaries.
Future<void> _pickTimezone(
  BuildContext context,
  WidgetRef ref,
  String current,
) async {
  final l10n = AppLocalizations.of(context);
  final picked = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(RachaTokens.space4),
              child: Text(
                l10n.profileTimezone,
                style: const TextStyle(
                  fontSize: RachaType.headline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final tz in timezoneOptions(current))
                    ListTile(
                      title: Text(tz),
                      trailing: tz == current ? const Icon(Icons.check) : null,
                      onTap: () => Navigator.pop(context, tz),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  if (picked == null || picked == current || !context.mounted) return;
  try {
    await ref
        .read(coupleControllerProvider.notifier)
        .updateSettings(timezone: picked);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.notifSaved)));
    }
  } on ApiException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.localizedMessage(context))));
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.onTap});
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final body = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RachaTokens.space4,
        vertical: RachaTokens.space3,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: RachaType.callout,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: RachaType.caption,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.edit_outlined, size: 18, color: scheme.onSurfaceVariant),
        ],
      ),
    );
    if (onTap == null) return body;
    return InkWell(onTap: onTap, child: body);
  }
}

class _InviteRow extends StatelessWidget {
  const _InviteRow({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: RachaTokens.space4,
        vertical: RachaTokens.space3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileInviteCode,
            style: const TextStyle(
              fontSize: RachaType.callout,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: RachaTokens.space2),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: RachaTokens.space3,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: RachaTokens.brS,
                    border: Border.all(
                      color: scheme.outlineVariant,
                      width: RachaTokens.borderHairline,
                    ),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: RachaType.headline,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: RachaTokens.space2),
              FilledButton.tonalIcon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l10n.profileCopied)));
                },
                icon: const Icon(Icons.copy, size: 16),
                label: Text(l10n.profileCopy),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthBars extends StatelessWidget {
  const _MonthBars({required this.months});
  final List<({String month, int count})> months;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (months.isEmpty) {
      return SizedBox(
        height: 90,
        child: Center(
          child: Text(
            AppLocalizations.of(context).summaryEmpty,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }
    final maxCount = months.fold(1, (a, m) => m.count > a ? m.count : a);
    return SizedBox(
      height: 110,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < months.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${months[i].count}',
                      style: const TextStyle(fontSize: RachaType.micro),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: 74 * (months[i].count / maxCount),
                      decoration: BoxDecoration(
                        color: i == months.length - 1
                            ? scheme.primary
                            : scheme.primaryContainer,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      monthLabel(
                        months[i].month,
                        Localizations.localeOf(context).toLanguageTag(),
                      ),
                      style: const TextStyle(fontSize: RachaType.micro),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
