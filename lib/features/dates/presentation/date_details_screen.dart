import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_banner.dart';
import '../../common/field_tile.dart';
import '../../common/step_bar.dart';
import '../../couple/data/couple_repository.dart';
import '../data/dates_repository.dart';
import '../domain/models.dart';

/// Step 2 of 2: the details. Time can't be in the future; both members are
/// tagged by default and un-tagging the partner warns that the date won't count.
class DateDetailsScreen extends ConsumerStatefulWidget {
  const DateDetailsScreen({super.key, this.place});
  final Place? place;

  @override
  ConsumerState<DateDetailsScreen> createState() => _DateDetailsScreenState();
}

class _DateDetailsScreenState extends ConsumerState<DateDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  final _notes = TextEditingController();
  final _cost = TextEditingController();
  DateTime _when = DateTime.now();
  int _rating = 0;
  final Set<String> _tagged = {};
  bool _submitting = false;
  String? _submitError;
  final String _idempotencyKey = DateTime.now().microsecondsSinceEpoch.toString();

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.place?.name ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    _cost.dispose();
    super.dispose();
  }

  Future<void> _pickWhen() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (!mounted) return;
    var picked = DateTime(date.year, date.month, date.day, time?.hour ?? 0, time?.minute ?? 0);
    if (picked.isAfter(now)) picked = now;
    setState(() => _when = picked);
  }

  static String _initial(String name) =>
      name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();

  Future<void> _submit(List<String> memberIds) async {
    if (!_formKey.currentState!.validate()) return;
    if (_when.isAfter(DateTime.now())) {
      setState(() => _submitError = AppLocalizations.of(context).dateErrorFuture);
      return;
    }
    setState(() {
      _submitting = true;
      _submitError = null;
    });

    // Default (both tagged) -> send null so the backend tags both.
    final everyone = _tagged.length == memberIds.length;
    try {
      final res = await ref.read(datesRepositoryProvider).create(
            title: _title.text.trim(),
            happenedAt: _when,
            placeId: widget.place?.id,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
            rating: _rating == 0 ? null : _rating,
            cost: double.tryParse(_cost.text.replaceAll(',', '.')),
            participantIds: everyone ? null : _tagged.toList(),
            idempotencyKey: _idempotencyKey,
          );
      if (!mounted) return;
      ref.invalidate(streakProvider);
      ref.invalidate(recentDatesProvider);
      final l10n = AppLocalizations.of(context);
      if (res.streakAdvanced) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.dateSavedStreakUp)));
      }
      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _submitError = e.code == 'FUTURE_DATE'
            ? AppLocalizations.of(context).dateErrorFuture
            : (e.isNetwork ? AppLocalizations.of(context).commonNoConnection : e.message);
        _submitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final coupleAsync = ref.watch(coupleMeProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place?.name ?? l10n.dateDetailsTitle),
        bottom: StepBar(step: 2, total: 2, label: l10n.dateNewStep2),
      ),
      body: coupleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (view) {
          final members = view.members;
          if (_tagged.isEmpty) {
            _tagged.addAll(members.map((m) => m.userId));
          }
          final bothTagged = _tagged.length == members.length;
          final memberIds = members.map((m) => m.userId).toList();

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(RachaTokens.space5),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _title,
                            decoration: InputDecoration(labelText: l10n.dateFieldTitle),
                            validator: (v) => (v ?? '').trim().isEmpty
                                ? l10n.validationNameRequired
                                : null,
                          ),
                          const SizedBox(height: RachaTokens.space4),
                          FieldTile(
                            label: l10n.dateFieldWhen,
                            value: DateFormat.yMMMEd(locale).add_jm().format(_when),
                            icon: Icons.edit_calendar_outlined,
                            onTap: _pickWhen,
                          ),
                          const SizedBox(height: RachaTokens.space4),
                          Text(l10n.dateFieldRating,
                              style: const TextStyle(
                                  fontSize: RachaType.callout, fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              for (var i = 1; i <= 5; i++)
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  iconSize: 32,
                                  onPressed: () =>
                                      setState(() => _rating = _rating == i ? 0 : i),
                                  icon: Icon(
                                    i <= _rating ? Icons.star : Icons.star_border,
                                    color: i <= _rating
                                        ? scheme.primary
                                        : scheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          if (_rating == 0)
                            Text(l10n.dateRatingHint,
                                style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: RachaType.caption)),
                          const SizedBox(height: RachaTokens.space4),
                          Text(l10n.dateTagBoth,
                              style: const TextStyle(
                                  fontSize: RachaType.callout, fontWeight: FontWeight.w600)),
                          const SizedBox(height: RachaTokens.space2),
                          Wrap(
                            spacing: RachaTokens.space2,
                            children: [
                              for (final m in members)
                                FilterChip(
                                  avatar: CircleAvatar(
                                    backgroundColor: scheme.primary,
                                    child: Text(
                                      _initial(m.displayName),
                                      style: TextStyle(
                                          color: scheme.onPrimary,
                                          fontSize: RachaType.micro,
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  label: Text(m.displayName),
                                  selected: _tagged.contains(m.userId),
                                  onSelected: (on) => setState(() {
                                    if (on) {
                                      _tagged.add(m.userId);
                                    } else {
                                      _tagged.remove(m.userId);
                                    }
                                  }),
                                ),
                            ],
                          ),
                          if (!bothTagged)
                            Padding(
                              padding: const EdgeInsets.only(top: RachaTokens.space2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      size: 16, color: scheme.error),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(l10n.dateTagWarning,
                                        style: TextStyle(
                                            color: scheme.error,
                                            fontSize: RachaType.caption)),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: RachaTokens.space4),
                          TextFormField(
                            controller: _notes,
                            minLines: 2,
                            maxLines: 4,
                            decoration: InputDecoration(labelText: l10n.dateFieldNotes),
                          ),
                          const SizedBox(height: RachaTokens.space4),
                          TextFormField(
                            controller: _cost,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: l10n.dateFieldCost,
                              prefixText: '\$ ',
                              suffixText: 'MXN',
                            ),
                          ),
                          if (_submitError != null) ...[
                            const SizedBox(height: RachaTokens.space3),
                            ErrorBanner(text: _submitError!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(RachaTokens.space4),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                          color: scheme.outlineVariant,
                          width: RachaTokens.borderHairline),
                    ),
                  ),
                  child: FilledButton(
                    onPressed: _submitting ? null : () => _submit(memberIds),
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(l10n.dateSave),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

