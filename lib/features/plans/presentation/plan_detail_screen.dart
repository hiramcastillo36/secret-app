import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../auth/application/auth.dart';
import '../../common/status_pill.dart';
import '../../dates/application/dates.dart';
import '../application/plans.dart';
import '../domain/models.dart';

/// /plans/:id — the plan, who proposed it and its state. If it was proposed to
/// you: "I'm in" / "Not now". If its date has passed: "Did you go out?" with the
/// button that turns it into a real date (and into streak).
class PlanDetailScreen extends ConsumerWidget {
  const PlanDetailScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(planProvider(planId));
    final myId = ref.watch(meProvider).valueOrNull?.user.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.planDetailTitle),
        actions: [
          async.maybeWhen(
            data: (plan) => plan.isActionable
                ? _PlanMenu(
                    plan: plan,
                    onChanged: () => ref.invalidate(planProvider(planId)),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (plan) => _Body(plan: plan, myId: myId),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.plan, required this.myId});
  final Plan plan;
  final String? myId;

  String _statusLabel(AppLocalizations l10n) => switch (plan.status) {
    'idea' => l10n.planStatusIdea,
    'proposed' => l10n.planStatusProposed,
    'confirmed' => l10n.planStatusConfirmed,
    'declined' => l10n.planStatusDeclined,
    'cancelled' => l10n.planStatusCancelled,
    'missed' => l10n.planStatusMissed,
    'completed' => l10n.planStatusCompleted,
    _ => plan.status,
  };

  (Color, IconData?) _statusStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return switch (plan.status) {
      'confirmed' || 'completed' => (
        dark ? RachaTokens.okDark : RachaTokens.okLight,
        Icons.check,
      ),
      'proposed' => (
        dark ? RachaTokens.atRiskDark : RachaTokens.atRiskLight,
        null,
      ),
      'declined' || 'cancelled' || 'missed' => (scheme.error, null),
      _ => (scheme.onSurfaceVariant, null),
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final mine = myId != null && plan.proposedBy == myId;
    final awaitingMe = plan.status == 'proposed' && !mine;
    final askOutcome = plan.isPast && plan.status == 'confirmed';
    final (statusColor, statusIcon) = _statusStyle(context);
    final highlight = plan.status == 'proposed';

    return ListView(
      padding: const EdgeInsets.all(RachaTokens.space5),
      children: [
        if (askOutcome) _OutcomeCard(plan: plan),

        Container(
          padding: const EdgeInsets.all(RachaTokens.space5),
          decoration: BoxDecoration(
            color: highlight
                ? (Theme.of(context).brightness == Brightness.dark
                          ? RachaTokens.atRiskDark
                          : RachaTokens.atRiskLight)
                      .withValues(alpha: 0.12)
                : scheme.surfaceContainerLow,
            borderRadius: RachaTokens.brL,
            border: Border.all(
              color: highlight
                  ? (Theme.of(context).brightness == Brightness.dark
                        ? RachaTokens.atRiskDark
                        : RachaTokens.atRiskLight)
                  : scheme.outlineVariant,
              width: RachaTokens.borderHairline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event, color: scheme.primary),
                  const Spacer(),
                  StatusPill(
                    label: _statusLabel(l10n),
                    color: statusColor,
                    icon: statusIcon,
                  ),
                ],
              ),
              const SizedBox(height: RachaTokens.space3),
              Text(
                plan.title,
                style: const TextStyle(
                  fontSize: RachaType.headline,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (plan.scheduledAt != null) ...[
                const SizedBox(height: RachaTokens.space2),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _fmtWhen(context, plan),
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: RachaTokens.space3),
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: scheme.primary,
                    child: Text(
                      mine ? '·' : '?',
                      style: TextStyle(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: RachaTokens.space2),
                  Text(
                    mine ? l10n.planProposedByYou : l10n.planProposedByPartner,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              if (plan.responseNote != null &&
                  plan.responseNote!.isNotEmpty) ...[
                const SizedBox(height: RachaTokens.space3),
                Text(
                  '“${plan.responseNote!}”',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: RachaTokens.space6),

        if (awaitingMe) _RespondButtons(plan: plan),

        if (plan.status == 'completed' && plan.dateEntryId != null)
          FilledButton.tonalIcon(
            onPressed: () => context.push('/dates/${plan.dateEntryId}'),
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(l10n.planViewDate),
          ),
      ],
    );
  }

  static String _fmtWhen(BuildContext context, Plan plan) {
    final d = plan.scheduledAt!;
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    if (!plan.hasTime) return date;
    return '$date · ${TimeOfDay.fromDateTime(d).format(context)}';
  }
}

class _RespondButtons extends ConsumerStatefulWidget {
  const _RespondButtons({required this.plan});
  final Plan plan;

  @override
  ConsumerState<_RespondButtons> createState() => _RespondButtonsState();
}

class _RespondButtonsState extends ConsumerState<_RespondButtons> {
  bool _busy = false;

  Future<void> _respond(String decision) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(plansControllerProvider.notifier)
          .respond(widget.plan.id, decision);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decision == 'confirm'
                ? l10n.planResponseConfirmed
                : l10n.planResponseDeclined,
          ),
        ),
      );
      if (decision == 'decline') {
        // Offer, without forcing, to propose another day.
        _maybeSuggestAnotherDay();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _maybeSuggestAnotherDay() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.planNotNowHint),
        action: SnackBarAction(
          label: l10n.planFieldPickDate,
          onPressed: () => _PlanMenu.changeDate(context, ref, widget.plan),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_busy) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        FilledButton.icon(
          onPressed: () => _respond('confirm'),
          icon: const Icon(Icons.check),
          label: Text(l10n.planJoinIn),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
        const SizedBox(height: RachaTokens.space3),
        OutlinedButton(
          onPressed: () => _respond('decline'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(l10n.planNotNow),
        ),
      ],
    );
  }
}

class _OutcomeCard extends ConsumerStatefulWidget {
  const _OutcomeCard({required this.plan});
  final Plan plan;

  @override
  ConsumerState<_OutcomeCard> createState() => _OutcomeCardState();
}

class _OutcomeCardState extends ConsumerState<_OutcomeCard> {
  bool _busy = false;

  Future<void> _logIt() async {
    setState(() => _busy = true);
    try {
      final dateId = await ref
          .read(plansControllerProvider.notifier)
          .complete(
            widget.plan.id,
            happenedAt: widget.plan.scheduledAt ?? DateTime.now(),
          );
      if (!mounted) return;
      ref.invalidate(streakProvider);
      context.pushReplacement('/dates/$dateId');
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: RachaTokens.space5),
      padding: const EdgeInsets.all(RachaTokens.space4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: RachaTokens.brM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.planDidYouGo,
            style: TextStyle(
              fontSize: RachaType.headline,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: RachaTokens.space3),
          FilledButton(
            onPressed: _busy ? null : _logIt,
            child: _busy
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.planLogAsDate),
          ),
        ],
      ),
    );
  }
}

class _PlanMenu extends ConsumerWidget {
  const _PlanMenu({required this.plan, required this.onChanged});
  final Plan plan;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      onSelected: (v) async {
        if (v == 'date') {
          await changeDate(context, ref, plan);
          onChanged();
        } else if (v == 'cancel') {
          await _confirmCancel(context, ref, plan);
          onChanged();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(value: 'date', child: Text(l10n.planFieldPickDate)),
        PopupMenuItem(value: 'cancel', child: Text(l10n.planCancel)),
      ],
    );
  }

  static Future<void> changeDate(
    BuildContext context,
    WidgetRef ref,
    Plan plan,
  ) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: plan.scheduledAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: plan.scheduledAt != null && plan.hasTime
          ? TimeOfDay.fromDateTime(plan.scheduledAt!)
          : const TimeOfDay(hour: 20, minute: 0),
    );
    final t = time ?? const TimeOfDay(hour: 20, minute: 0);
    final at = DateTime(date.year, date.month, date.day, t.hour, t.minute);
    try {
      await ref
          .read(plansControllerProvider.notifier)
          .reschedule(plan.id, scheduledAt: at, hasTime: time != null);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  static Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    Plan plan,
  ) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.planCancelConfirm),
        content: Text(l10n.planCancelBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.planCancel),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(plansControllerProvider.notifier).cancel(plan.id);
      if (context.mounted) {
        Navigator.of(context).maybePop();
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }
}
