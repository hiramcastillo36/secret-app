import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_banner.dart';
import '../../common/field_tile.dart';
import '../application/dates.dart';
import '../domain/models.dart';

/// Edit the mutable fields of an existing date. Place changes are out of scope
/// for v1; title, time, rating and notes cover the common corrections.
class DateEditScreen extends ConsumerStatefulWidget {
  const DateEditScreen({super.key, required this.date});
  final DateEntry date;

  @override
  ConsumerState<DateEditScreen> createState() => _DateEditScreenState();
}

class _DateEditScreenState extends ConsumerState<DateEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late DateTime _when;
  late int _rating;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.date.title);
    _notes = TextEditingController(text: widget.date.notes ?? '');
    _when = widget.date.happenedAt.toLocal();
    _rating = widget.date.rating ?? 0;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
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
    var picked = DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
    if (picked.isAfter(now)) picked = now;
    setState(() => _when = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(datesControllerProvider.notifier)
          .update(
            widget.date.id,
            title: _title.text.trim(),
            happenedAt: _when,
            notes: _notes.text.trim(),
            rating: _rating == 0 ? null : _rating,
          );
      if (!mounted) return;
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.code == 'FUTURE_DATE'
            ? AppLocalizations.of(context).dateErrorFuture
            : (e.isNetwork
                  ? AppLocalizations.of(context).commonNoConnection
                  : e.message);
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dateEditTitle)),
      body: SafeArea(
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
                        decoration: InputDecoration(
                          labelText: l10n.dateFieldTitle,
                        ),
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
                      Text(
                        l10n.dateFieldRating,
                        style: const TextStyle(
                          fontSize: RachaType.callout,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 1; i <= 5; i++)
                            IconButton(
                              tooltip: l10n.a11yRatingStars(i),
                              visualDensity: VisualDensity.compact,
                              iconSize: 32,
                              onPressed: () => setState(
                                () => _rating = _rating == i ? 0 : i,
                              ),
                              icon: Icon(
                                i <= _rating ? Icons.star : Icons.star_border,
                                color: i <= _rating
                                    ? scheme.primary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: RachaTokens.space2),
                      TextFormField(
                        controller: _notes,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: l10n.dateFieldNotes,
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: RachaTokens.space3),
                        ErrorBanner(text: _error!),
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
                    width: RachaTokens.borderHairline,
                  ),
                ),
              ),
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.dateEditSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
