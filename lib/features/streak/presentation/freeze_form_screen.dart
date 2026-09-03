import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/field_tile.dart';
import '../data/protect_repository.dart';

/// /streak/freeze/new — declare a travel/illness pause and freeze the streak for
/// the weeks it spans. One free pause per calendar month.
class FreezeFormScreen extends ConsumerStatefulWidget {
  const FreezeFormScreen({super.key});

  @override
  ConsumerState<FreezeFormScreen> createState() => _FreezeFormScreenState();
}

class _FreezeFormScreenState extends ConsumerState<FreezeFormScreen> {
  String _reason = 'travel';
  DateTime? _from;
  DateTime? _to;
  bool _busy = false;
  String? _error;

  Future<void> _pick(bool isFrom) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to != null && _to!.isBefore(picked)) _to = picked;
      } else {
        _to = picked;
      }
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_from == null) return;
    final to = _to ?? _from!;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(protectRepositoryProvider).createFreeze(
            reason: _reason,
            startsWeekKey: isoWeekKey(_from!),
            endsWeekKey: isoWeekKey(to),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.freezeDone)));
      context.pop();
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = switch (e.code) {
              'freeze_quota_exceeded' => l10n.freezeErrorQuota,
              'week_already_complete' => l10n.freezeErrorWeekComplete,
              'freeze_past' => l10n.freezeErrorPast,
              _ => e.message,
            });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    String fmt(DateTime? d) => d == null
        ? '—'
        : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    final quotaUsed = ref.watch(protectHubProvider).valueOrNull?.freezeQuotaUsed ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.freezeNewTitle),
        actions: [
          if (!quotaUsed)
            Padding(
              padding: const EdgeInsets.only(right: RachaTokens.space4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: RachaTokens.space3, vertical: 2),
                  decoration: BoxDecoration(
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? RachaTokens.okDark
                            : RachaTokens.okLight)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(RachaTokens.radiusFull),
                  ),
                  child: Text(
                    l10n.freezeQuotaChip,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? RachaTokens.okDark
                          : RachaTokens.okLight,
                      fontSize: RachaType.caption,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(RachaTokens.space5),
                children: [
                  Text(l10n.freezeReason,
                      style: const TextStyle(
                          fontSize: RachaType.callout, fontWeight: FontWeight.w600)),
                  const SizedBox(height: RachaTokens.space2),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'travel', label: Text(l10n.freezeReasonTravel)),
                      ButtonSegment(value: 'illness', label: Text(l10n.freezeReasonIllness)),
                      ButtonSegment(value: 'other', label: Text(l10n.freezeReasonOther)),
                    ],
                    selected: {_reason},
                    onSelectionChanged: (s) => setState(() => _reason = s.first),
                  ),
                  const SizedBox(height: RachaTokens.space5),
                  FieldTile(
                    label: l10n.freezeFrom,
                    value: fmt(_from),
                    icon: Icons.edit_calendar_outlined,
                    onTap: () => _pick(true),
                  ),
                  const SizedBox(height: RachaTokens.space3),
                  FieldTile(
                    label: l10n.freezeTo,
                    value: fmt(_to ?? _from),
                    icon: Icons.edit_calendar_outlined,
                    onTap: () => _pick(false),
                  ),
                  const SizedBox(height: RachaTokens.space4),
                  NoteBox(
                    tone: 'warning',
                    icon: Icons.ac_unit,
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                          text: '${l10n.freezeNoteTitle} ',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      TextSpan(text: l10n.freezeNoteBody),
                    ])),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: RachaTokens.space3),
                    Text(_error!, style: TextStyle(color: scheme.error)),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(RachaTokens.space4),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: scheme.outlineVariant, width: RachaTokens.borderHairline),
                ),
              ),
              child: FilledButton(
                onPressed: (_from == null || _busy) ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.freezeSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
