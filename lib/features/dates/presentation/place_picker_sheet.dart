import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../data/dates_repository.dart';
import '../domain/models.dart';
import 'date_format.dart';

/// A debounced place search shown as a modal bottom sheet. Returns the chosen
/// [Place] via `Navigator.pop`, or null on dismiss. Always goes through the
/// backend, never Nominatim directly.
class PlacePickerSheet extends ConsumerStatefulWidget {
  const PlacePickerSheet({super.key});

  static Future<Place?> show(BuildContext context) {
    return showModalBottomSheet<Place>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const PlacePickerSheet(),
    );
  }

  @override
  ConsumerState<PlacePickerSheet> createState() => _PlacePickerSheetState();
}

class _PlacePickerSheetState extends ConsumerState<PlacePickerSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<Place> _results = const [];
  bool _loading = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    final q = v.trim();
    if (q.length < 3) {
      setState(() {
        _results = const [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final res = await ref.read(datesRepositoryProvider).searchPlaces(q);
        if (mounted) {
          setState(() {
            _results = res.results;
            _loading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: RachaTokens.space4,
        right: RachaTokens.space4,
        top: RachaTokens.space4,
        bottom: MediaQuery.of(context).viewInsets.bottom + RachaTokens.space4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: RachaTokens.space3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(RachaTokens.radiusFull),
            ),
          ),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.dateNewSearchHint,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: _onChanged,
          ),
          const SizedBox(height: RachaTokens.space2),
          if (_loading) const LinearProgressIndicator(),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final p in _results)
                  ListTile(
                    shape: const RoundedRectangleBorder(borderRadius: RachaTokens.brM),
                    leading: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: RachaTokens.brS,
                      ),
                      child: Icon(categoryIcon(p.category),
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                    title: Text(p.name),
                    subtitle: p.address == null
                        ? null
                        : Text(p.address!, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.of(context).pop(p),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
