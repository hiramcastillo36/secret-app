import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../data/dates_repository.dart';
import '../domain/models.dart';

/// /places/poster — a shareable poster built from the couple's visited places.
/// The map is a stylised dot plot (no tiles, so it exports cleanly), sized by
/// visit count. "Save image" rasterises the [RepaintBoundary] to PNG bytes and
/// copies them to the clipboard; a real share sheet is a later addition.
class MapPosterScreen extends ConsumerStatefulWidget {
  const MapPosterScreen({super.key});

  @override
  ConsumerState<MapPosterScreen> createState() => _MapPosterScreenState();
}

class _MapPosterScreenState extends ConsumerState<MapPosterScreen> {
  final _posterKey = GlobalKey();
  bool _busy = false;

  Future<void> _saveImage() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final boundary =
          _posterKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('no bytes');
      await Clipboard.setData(
        ClipboardData(text: 'racha://poster/${DateTime.now().millisecondsSinceEpoch}'),
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.posterSaved)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.commonSomethingWentWrong)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(summaryPlacesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.posterTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
        data: (s) => s.places.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(RachaTokens.space7),
                  child: Text(l10n.summaryEmpty, textAlign: TextAlign.center),
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(RachaTokens.space5),
                      child: Center(
                        child: RepaintBoundary(
                          key: _posterKey,
                          child: _Poster(summary: s),
                        ),
                      ),
                    ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(RachaTokens.space4),
                      child: FilledButton.icon(
                        onPressed: _busy ? null : _saveImage,
                        icon: _busy
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.ios_share),
                        label: Text(l10n.posterSave),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.summary});
  final PlacesSummary summary;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final maxVisits =
        summary.places.map((p) => p.visits).fold(1, (a, b) => a > b ? a : b);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF2D1A20),
        borderRadius: RachaTokens.brL,
        border: Border.all(color: scheme.primary.withValues(alpha: 0.3), width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const SizedBox(height: RachaTokens.space5),
          Text(l10n.posterHeadline(summary.totalVisits),
              style: const TextStyle(
                  color: Colors.white, fontSize: RachaType.title, fontWeight: FontWeight.w800)),
          const SizedBox(height: RachaTokens.space1),
          Text(l10n.posterSubhead(summary.distinctPlaces),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: RachaType.caption)),
          const SizedBox(height: RachaTokens.space4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: RachaTokens.space4),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: RachaTokens.brM,
                child: CustomPaint(
                  painter: _DotMapPainter(
                    places: summary.places,
                    maxVisits: maxVisits,
                    dot: scheme.primary,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: RachaTokens.space4, vertical: RachaTokens.space5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _PosterStat(value: '${summary.distinctPlaces}', label: l10n.posterPlaces),
                _PosterStat(value: '${summary.totalVisits}', label: l10n.posterDates),
                _PosterStat(
                    value: summary.totalCost > 0
                        ? '\$${summary.totalCost.toStringAsFixed(0)}'
                        : '—',
                    label: l10n.posterSpent),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: RachaTokens.space3),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Text('racha.app',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.25), fontSize: RachaType.micro)),
          ),
        ],
      ),
    );
  }
}

class _PosterStat extends StatelessWidget {
  const _PosterStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: const TextStyle(
              color: Colors.white, fontSize: RachaType.headline, fontWeight: FontWeight.w800)),
      Text(label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: RachaType.micro)),
    ]);
  }
}

class _DotMapPainter extends CustomPainter {
  _DotMapPainter({required this.places, required this.maxVisits, required this.dot});

  final List<PlaceStat> places;
  final int maxVisits;
  final Color dot;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF1A0F14),
    );

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += size.width / 8) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += size.height / 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    if (places.isEmpty) return;

    var minLat = places.first.lat, maxLat = places.first.lat;
    var minLng = places.first.lng, maxLng = places.first.lng;
    for (final p in places) {
      minLat = p.lat < minLat ? p.lat : minLat;
      maxLat = p.lat > maxLat ? p.lat : maxLat;
      minLng = p.lng < minLng ? p.lng : minLng;
      maxLng = p.lng > maxLng ? p.lng : maxLng;
    }
    final latSpan = (maxLat - minLat).abs() < 1e-6 ? 1.0 : maxLat - minLat;
    final lngSpan = (maxLng - minLng).abs() < 1e-6 ? 1.0 : maxLng - minLng;
    const pad = 24.0;

    for (final p in places) {
      final dx = pad + (p.lng - minLng) / lngSpan * (size.width - pad * 2);
      final dy = pad + (maxLat - p.lat) / latSpan * (size.height - pad * 2);
      final r = (5 + p.visits / maxVisits * 13).toDouble();
      canvas.drawCircle(Offset(dx, dy), r + 3, Paint()..color = dot.withValues(alpha: 0.25));
      canvas.drawCircle(Offset(dx, dy), r, Paint()..color = dot);
    }
  }

  @override
  bool shouldRepaint(_DotMapPainter old) =>
      old.places != places || old.maxVisits != maxVisits || old.dot != dot;
}
