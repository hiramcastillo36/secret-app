import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../common/error_banner.dart';
import '../../common/field_tile.dart';
import '../application/couple_controller.dart';
import 'couple_error.dart';

/// A short curated list of IANA zones. The couple's zone can be changed later
/// from settings; the important thing is that it is a real zone.
const _timezones = <String>[
  'America/Mexico_City',
  'America/Tijuana',
  'America/Monterrey',
  'America/Bogota',
  'America/Lima',
  'America/Santiago',
  'America/Argentina/Buenos_Aires',
  'America/New_York',
  'America/Chicago',
  'America/Denver',
  'America/Los_Angeles',
  'America/Sao_Paulo',
  'Europe/Madrid',
  'Europe/London',
  'UTC',
];

class CoupleCreateScreen extends ConsumerStatefulWidget {
  const CoupleCreateScreen({super.key});

  @override
  ConsumerState<CoupleCreateScreen> createState() => _CoupleCreateScreenState();
}

class _CoupleCreateScreenState extends ConsumerState<CoupleCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _timezone = _timezones.first;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    final couple = await ref
        .read(coupleControllerProvider.notifier)
        .create(name: _name.text.trim(), timezone: _timezone);
    if (!mounted || couple == null) return;
    context.go('/couple/waiting');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(coupleControllerProvider);
    final loading = state.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.coupleCreateTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(RachaTokens.space5),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _submitted
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _name,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: l10n.coupleCreateNameLabel,
                          helperText: l10n.coupleCreateNameHint,
                        ),
                        validator: (v) =>
                            (v ?? '').trim().isEmpty ? l10n.validationNameRequired : null,
                      ),
                      const SizedBox(height: RachaTokens.space4),
                      DropdownButtonFormField<String>(
                        initialValue: _timezone,
                        isExpanded: true,
                        decoration: InputDecoration(labelText: l10n.coupleCreateTimezoneLabel),
                        items: [
                          for (final tz in _timezones)
                            DropdownMenuItem(value: tz, child: Text(tz)),
                        ],
                        onChanged: loading
                            ? null
                            : (v) => setState(() => _timezone = v ?? _timezone),
                      ),
                      const SizedBox(height: RachaTokens.space3),
                      NoteBox(
                        icon: Icons.schedule,
                        child: Text(l10n.coupleCreateTimezoneHelp),
                      ),
                      if (state.hasError) ...[
                        const SizedBox(height: RachaTokens.space3),
                        ErrorBanner(text: coupleErrorText(l10n, state.error!)),
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
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: RachaTokens.borderHairline),
                ),
              ),
              child: FilledButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.coupleCreateSubmit),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
