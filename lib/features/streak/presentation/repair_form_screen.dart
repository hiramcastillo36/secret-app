import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/field_tile.dart';
import '../../dates/application/dates.dart';
import '../application/protect.dart';

/// /streak/repair/new — log a date from an already-closed week (within 48h of
/// its close) to save the streak. It stays tentative until the partner confirms.
class RepairFormScreen extends ConsumerStatefulWidget {
  const RepairFormScreen({super.key});

  @override
  ConsumerState<RepairFormScreen> createState() => _RepairFormScreenState();
}

class _RepairFormScreenState extends ConsumerState<RepairFormScreen> {
  final _title = TextEditingController();
  DateTime? _when;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Default to last Saturday evening — most likely a missed outing.
    final now = DateTime.now();
    final lastSat = now.subtract(Duration(days: (now.weekday % 7) + 1));
    _when = DateTime(lastSat.year, lastSat.month, lastSat.day, 20);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _when ?? now.subtract(const Duration(days: 3)),
      firstDate: now.subtract(const Duration(days: 21)),
      lastDate: now,
    );
    if (picked == null) return;
    setState(() => _when = DateTime(picked.year, picked.month, picked.day, 20));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_when == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(protectControllerProvider.notifier)
          .createRepair(happenedAt: _when!, title: _title.text.trim());
      if (!mounted) return;
      ref.invalidate(protectHubProvider);
      ref.invalidate(streakProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.repairSent)));
      context.pop();
    } on ApiException catch (e) {
      if (mounted) {
        setState(
          () => _error = switch (e.code) {
            'repair_window_closed' => l10n.repairErrorWindow,
            'repair_week_not_closed' => l10n.repairErrorNotClosed,
            'repair_already_pending' => l10n.repairErrorPending,
            _ => e.localizedMessage(context),
          },
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.repairNewTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(RachaTokens.space5),
                children: [
                  NoteBox(
                    tone: 'warning',
                    icon: Icons.history,
                    child: Text(l10n.repairBody),
                  ),
                  const SizedBox(height: RachaTokens.space4),
                  FieldTile(
                    label: l10n.repairFieldWhen,
                    value: _when == null
                        ? '—'
                        : '${_when!.day.toString().padLeft(2, '0')}/${_when!.month.toString().padLeft(2, '0')}/${_when!.year}',
                    icon: Icons.edit_calendar_outlined,
                    onTap: _pick,
                  ),
                  const SizedBox(height: RachaTokens.space3),
                  TextField(
                    controller: _title,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.repairFieldTitle,
                    ),
                  ),
                  const SizedBox(height: RachaTokens.space4),
                  NoteBox(
                    icon: Icons.info_outline,
                    child: Text(l10n.repairConfirmNote),
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
                    color: scheme.outlineVariant,
                    width: RachaTokens.borderHairline,
                  ),
                ),
              ),
              child: FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.repairSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
