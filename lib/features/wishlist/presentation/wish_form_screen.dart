import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../dates/domain/models.dart';
import '../../dates/presentation/place_picker_sheet.dart';
import '../application/wishlist.dart';

/// /wishlist/new — a place or an idea. Only the title is required.
class WishFormScreen extends ConsumerStatefulWidget {
  const WishFormScreen({super.key});

  @override
  ConsumerState<WishFormScreen> createState() => _WishFormScreenState();
}

class _WishFormScreenState extends ConsumerState<WishFormScreen> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  Place? _place;
  String? _cost;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickPlace() async {
    final p = await PlacePickerSheet.show(context);
    if (p != null) setState(() => _place = p);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_title.text.trim().isEmpty) {
      setState(() => _error = l10n.validationNameRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(wishlistControllerProvider.notifier)
          .create(
            title: _title.text.trim(),
            placeId: _place?.id,
            note: _note.text.trim(),
            costBand: _cost,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.wishSaved)));
      context.pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wishNewTitle)),
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
                    decoration: InputDecoration(labelText: l10n.wishFieldTitle),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                  ),
                  const SizedBox(height: RachaTokens.space5),
                  Text(
                    l10n.wishFieldCost,
                    style: const TextStyle(
                      fontSize: RachaType.callout,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RachaTokens.space2),
                  Wrap(
                    spacing: RachaTokens.space2,
                    children: [
                      for (final e in [
                        ('free', l10n.wishCostFree),
                        ('low', l10n.wishCostLow),
                        ('mid', l10n.wishCostMid),
                        ('high', l10n.wishCostHigh),
                      ])
                        ChoiceChip(
                          label: Text(e.$2),
                          selected: _cost == e.$1,
                          onSelected: (v) =>
                              setState(() => _cost = v ? e.$1 : null),
                        ),
                    ],
                  ),
                  const SizedBox(height: RachaTokens.space5),
                  Text(
                    l10n.wishFieldPlace,
                    style: const TextStyle(
                      fontSize: RachaType.callout,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: RachaTokens.space2),
                  OutlinedButton.icon(
                    onPressed: _pickPlace,
                    icon: const Icon(Icons.place_outlined),
                    label: Text(_place?.name ?? l10n.planFieldPlaceChoose),
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
                  TextField(
                    controller: _note,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(labelText: l10n.wishFieldNote),
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
                    : Text(l10n.commonSave),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
