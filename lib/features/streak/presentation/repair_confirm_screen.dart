import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../dates/application/dates.dart';
import '../application/protect.dart';

/// /streak/repair/:id — the partner confirms or rejects a pending repair.
class RepairConfirmScreen extends ConsumerStatefulWidget {
  const RepairConfirmScreen({super.key, required this.repairId});
  final String repairId;

  @override
  ConsumerState<RepairConfirmScreen> createState() =>
      _RepairConfirmScreenState();
}

class _RepairConfirmScreenState extends ConsumerState<RepairConfirmScreen> {
  bool _busy = false;

  Future<void> _respond(String decision) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(protectControllerProvider.notifier)
          .respondRepair(widget.repairId, decision);
      if (!mounted) return;
      ref.invalidate(protectHubProvider);
      ref.invalidate(streakProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            decision == 'confirm'
                ? l10n.repairConfirmedToast
                : l10n.repairRejectedToast,
          ),
        ),
      );
      context.pop();
    } on ApiException catch (e) {
      if (mounted) {
        final msg = e.code == 'cannot_confirm_own_repair'
            ? l10n.repairCannotConfirmOwn
            : e.message;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final hub = ref.watch(protectHubProvider).valueOrNull;
    PendingRepair? repair;
    for (final r in hub?.pendingRepairs ?? const <PendingRepair>[]) {
      if (r.id == widget.repairId) repair = r;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.repairConfirmTitle)),
      body: Padding(
        padding: const EdgeInsets.all(RachaTokens.space5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: RachaTokens.space4),
            Center(
              child: Container(
                height: 72,
                width: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      (Theme.of(context).brightness == Brightness.dark
                              ? RachaTokens.atRiskDark
                              : RachaTokens.atRiskLight)
                          .withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.hourglass_bottom,
                  size: 34,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? RachaTokens.atRiskDark
                      : RachaTokens.atRiskLight,
                ),
              ),
            ),
            const SizedBox(height: RachaTokens.space5),
            if (repair != null)
              Text(
                l10n.protectPendingYours(repair.targetWeekKey),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: RachaType.headline,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: RachaTokens.space3),
            Text(
              l10n.repairConfirmBody,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            const Spacer(),
            if (_busy)
              const Center(child: CircularProgressIndicator())
            else ...[
              FilledButton(
                onPressed: () => _respond('confirm'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(l10n.repairConfirm),
              ),
              const SizedBox(height: RachaTokens.space3),
              OutlinedButton(
                onPressed: () => _respond('reject'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(l10n.repairReject),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
