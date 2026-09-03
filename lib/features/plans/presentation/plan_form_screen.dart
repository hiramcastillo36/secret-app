import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/field_tile.dart';
import '../../dates/domain/models.dart';
import '../../dates/presentation/place_picker_sheet.dart';
import '../application/plans.dart';
import '../domain/models.dart';

/// /plans/new — title is the only required field. No date → saved as an idea;
/// with a date → proposed to the partner. Can be seeded from a calendar day, a
/// wish or a place on the map.
class PlanFormScreen extends ConsumerStatefulWidget {
  const PlanFormScreen({super.key, this.seed});

  final PlanSeed? seed;

  @override
  ConsumerState<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends ConsumerState<PlanFormScreen> {
  final _title = TextEditingController();
  Place? _place;
  String? _seedPlaceId;
  String? _seedPlaceName;
  String? _wishlistItemId;
  DateTime? _date; // date-only
  TimeOfDay? _time;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.seed;
    if (s == null) return;
    if (s.date != null) {
      _date = DateTime(s.date!.year, s.date!.month, s.date!.day);
    }
    if (s.title != null) _title.text = s.title!;
    _seedPlaceId = s.placeId;
    _seedPlaceName = s.placeName;
    _wishlistItemId = s.wishlistItemId;
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  DateTime? get _scheduledAt {
    if (_date == null) return null;
    final t = _time ?? const TimeOfDay(hour: 20, minute: 0);
    return DateTime(_date!.year, _date!.month, _date!.day, t.hour, t.minute);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 20, minute: 0),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickPlace() async {
    final place = await PlacePickerSheet.show(context);
    if (place != null) {
      setState(() {
        _place = place;
        _seedPlaceId = null;
        _seedPlaceName = null;
      });
    }
  }

  String? get _placeLabel => _place?.name ?? _seedPlaceName;

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty && _wishlistItemId == null) {
      setState(() => _error = l10n.validationNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final plan = await ref
          .read(plansControllerProvider.notifier)
          .create(
            title: _title.text.trim(),
            placeId: _place?.id ?? _seedPlaceId,
            scheduledAt: _scheduledAt,
            hasTime: _time != null,
            wishlistItemId: _wishlistItemId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            plan.isIdea ? l10n.planSavedIdea : l10n.planSavedProposed,
          ),
        ),
      );
      context.pop();
    } on ApiException catch (e) {
      if (mounted) {
        setState(
          () => _error = e.code == 'PAST_DATE' ? l10n.planErrorPast : e.message,
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
    final hasDate = _date != null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.planNewTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(RachaTokens.space5),
                children: [
                  TextField(
                    controller: _title,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.planFieldTitle,
                      hintText: l10n.planFieldTitleHint,
                    ),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: RachaTokens.space5),

                  Text(
                    l10n.planFieldPlace,
                    style: const TextStyle(
                      fontSize: RachaType.callout,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RachaTokens.space2),
                  OutlinedButton.icon(
                    onPressed: _pickPlace,
                    icon: const Icon(Icons.place_outlined),
                    label: Text(_placeLabel ?? l10n.planFieldPlaceChoose),
                  ),
                  if (_place != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => setState(() => _place = null),
                        child: Text(l10n.commonCancel),
                      ),
                    ),
                  const SizedBox(height: RachaTokens.space5),

                  Material(
                    color: scheme.surfaceContainerHighest,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: RachaTokens.brM,
                      side: BorderSide(
                        color: scheme.outlineVariant,
                        width: RachaTokens.borderHairline,
                      ),
                    ),
                    child: SwitchListTile.adaptive(
                      value: hasDate,
                      title: Text(
                        l10n.planHasDate,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(l10n.planHasDateSub),
                      onChanged: (on) => setState(() {
                        if (on) {
                          _date = DateTime.now().add(const Duration(days: 1));
                        } else {
                          _date = null;
                          _time = null;
                        }
                      }),
                    ),
                  ),
                  if (hasDate) ...[
                    const SizedBox(height: RachaTokens.space3),
                    Row(
                      children: [
                        Expanded(
                          child: FieldTile(
                            label: l10n.planFieldWhen,
                            value: _fmtDate(_date!),
                            icon: Icons.event_outlined,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: RachaTokens.space2),
                        Expanded(
                          child: FieldTile(
                            label: l10n.planFieldAddTime,
                            value: _time == null ? '—' : _time!.format(context),
                            icon: Icons.schedule_outlined,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: RachaTokens.space3),
                  NoteBox(
                    icon: hasDate
                        ? Icons.mark_email_unread_outlined
                        : Icons.lightbulb_outline,
                    child: Text(
                      hasDate ? l10n.planNoteProposed : l10n.planNoteIdea,
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: RachaTokens.space4),
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
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(hasDate ? l10n.planPropose : l10n.planSaveIdea),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
