import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/format/money.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../auth/application/auth.dart';
import '../../common/error_retry.dart';
import '../../common/osm_attribution.dart';
import '../../common/section_label.dart';
import '../application/dates.dart';
import '../domain/models.dart';
import 'date_format.dart';

/// The current user's own pending row on [date], if any — someone else
/// tagged them and it is still awaiting a yes/no (E11 tag consent).
DateParticipant? _myPendingTag(DateEntry date, String? myUserId) {
  if (myUserId == null) return null;
  for (final p in date.participants) {
    if (p.userId == myUserId && p.status == 'pending') return p;
  }
  return null;
}

class DateDetailScreen extends ConsumerWidget {
  const DateDetailScreen({super.key, required this.dateId});
  final String dateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(dateByIdProvider(dateId));

    return async.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.dateDetailsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: AppBar(title: Text(l10n.dateDetailsTitle)),
        body: ErrorRetry(
          onRetry: () => ref.invalidate(dateByIdProvider(dateId)),
        ),
      ),
      data: (d) => _Loaded(date: d),
    );
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.date});
  final DateEntry date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final place = date.place;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dateDetailsTitle),
        actions: [
          TextButton(
            onPressed: () async {
              await context.push('/dates/${date.id}/edit', extra: date);
              ref.invalidate(dateByIdProvider(date.id));
              ref.invalidate(streakProvider);
              ref.invalidate(recentDatesProvider);
            },
            child: Text(l10n.dateDetailEdit),
          ),
          IconButton(
            onPressed: () => _confirmDeleteDate(context, ref, date),
            icon: Icon(Icons.delete_outline, color: scheme.error),
            tooltip: l10n.dateDetailDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(RachaTokens.space5),
        children: [
          // Hero: the one filled surface on this screen.
          Container(
            padding: const EdgeInsets.all(RachaTokens.space5),
            decoration: const BoxDecoration(
              borderRadius: RachaTokens.brL,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: RachaTokens.streakGradient,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: RachaType.title,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                if (place != null) ...[
                  const SizedBox(height: RachaTokens.space2),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.name,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  if ((place.address ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 2),
                      child: Text(
                        place.address!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: RachaType.caption,
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: RachaTokens.space4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DateFormat.yMMMMEEEEd(
                        locale,
                      ).format(date.happenedAt.toLocal()),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    if (date.rating != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 1; i <= 5; i++)
                            Icon(
                              i <= date.rating!
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16,
                              color: Colors.white,
                            ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          if (date.photos.isNotEmpty) ...[
            const SizedBox(height: RachaTokens.space4),
            _PhotoGallery(date: date),
          ],

          if (_myPendingTag(date, ref.watch(meProvider).valueOrNull?.user.id) !=
              null) ...[
            const SizedBox(height: RachaTokens.space4),
            _TagConsentCard(dateId: date.id),
          ],

          if (date.participants.isNotEmpty) ...[
            const SizedBox(height: RachaTokens.space4),
            Container(
              padding: const EdgeInsets.all(RachaTokens.space3),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: RachaTokens.brM,
                border: Border.all(
                  color: scheme.outlineVariant,
                  width: RachaTokens.borderHairline,
                ),
              ),
              child: Row(
                children: [
                  for (final p in date.participants.take(3))
                    Padding(
                      padding: const EdgeInsets.only(right: RachaTokens.space1),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: scheme.primary,
                        child: Text(
                          _initial(p.displayName),
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: RachaType.caption,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: RachaTokens.space2),
                  Expanded(
                    child: Text(
                      date.participants.map((p) => p.displayName).join(' + '),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.favorite, size: 16, color: scheme.primary),
                ],
              ),
            ),
          ],

          if (date.cost != null) ...[
            const SizedBox(height: RachaTokens.space4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: RachaTokens.space4,
                vertical: RachaTokens.space3,
              ),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: RachaTokens.brM,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.wrappedTotalSpend,
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    formatMoney(
                      date.cost,
                      date.currency,
                      locale: Localizations.localeOf(context).toString(),
                    ),
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: RachaType.headline,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if ((date.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: RachaTokens.space5),
            SectionLabel(l10n.dateFieldNotes),
            const SizedBox(height: RachaTokens.space2),
            Text(date.notes!, style: const TextStyle(height: 1.5)),
          ],

          if (place != null) ...[
            const SizedBox(height: RachaTokens.space5),
            SectionLabel(l10n.dateDetailLocation),
            const SizedBox(height: RachaTokens.space2),
            _MiniMap(place: place),
          ],

          const SizedBox(height: RachaTokens.space5),
          Wrap(
            spacing: RachaTokens.space2,
            children: [
              if (place != null)
                Chip(
                  label: Text(categoryLabel(l10n, place.category)),
                  backgroundColor: scheme.primaryContainer,
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: RachaType.caption,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (!date.countsForStreak)
                Chip(
                  avatar: Icon(
                    Icons.link_off,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  label: Text(l10n.timelineDoesntCount),
                  backgroundColor: scheme.surfaceContainerHighest,
                  side: BorderSide(color: scheme.outlineVariant),
                  labelStyle: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: RachaType.caption,
                  ),
                ),
            ],
          ),
          const SizedBox(height: RachaTokens.space7),
        ],
      ),
    );
  }

  static String _initial(String name) =>
      name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
}

/// Shown on a date where the signed-in user still has a pending tag: confirm
/// counts it toward the streak, reject drops them from it (POST
/// /dates/{id}/participation).
class _TagConsentCard extends ConsumerStatefulWidget {
  const _TagConsentCard({required this.dateId});
  final String dateId;

  @override
  ConsumerState<_TagConsentCard> createState() => _TagConsentCardState();
}

class _TagConsentCardState extends ConsumerState<_TagConsentCard> {
  bool _busy = false;

  Future<void> _respond(bool confirm) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(datesControllerProvider.notifier)
          .respondParticipation(widget.dateId, confirm: confirm);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.localizedMessage(context))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final accent = Theme.of(context).brightness == Brightness.dark
        ? RachaTokens.atRiskDark
        : RachaTokens.atRiskLight;
    return Container(
      padding: const EdgeInsets.all(RachaTokens.space4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: RachaTokens.brM,
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_pin_circle_outlined, size: 18, color: accent),
              const SizedBox(width: RachaTokens.space2),
              Expanded(
                child: Text(
                  l10n.dateTagPendingTitle,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: RachaTokens.space1),
          Text(
            l10n.dateTagPendingBody,
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: RachaType.caption,
            ),
          ),
          const SizedBox(height: RachaTokens.space3),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _respond(false),
                  child: Text(l10n.dateTagReject),
                ),
              ),
              const SizedBox(width: RachaTokens.space2),
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : () => _respond(true),
                  child: _busy
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.dateTagConfirm),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMap extends StatelessWidget {
  const _MiniMap({required this.place});
  final Place place;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tappable = place.id.isNotEmpty;
    return ClipRRect(
      borderRadius: RachaTokens.brM,
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(place.lat, place.lng),
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                osmTileLayer(),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(place.lat, place.lng),
                      child: Icon(
                        Icons.location_on,
                        color: scheme.primary,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (tappable)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/places/${place.id}'),
                  ),
                ),
              ),
            // On top of the InkWell so its "i" stays tappable; ODbL requires
            // the attribution and its link even on this thumbnail (audit F-H9).
            const OsmAttribution(),
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmDeleteDate(
  BuildContext context,
  WidgetRef ref,
  DateEntry date,
) async {
  final l10n = AppLocalizations.of(context);
  final streak = ref.read(streakProvider).valueOrNull;
  final warn = date.countsForStreak && (streak?.currentStreak ?? 0) > 0;

  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dateDetailDeleteTitle),
      content: Text(
        warn
            ? l10n.dateDetailDeleteWarnsStreak(streak!.currentStreak)
            : l10n.dateDetailDeleteBody,
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => context.pop(true),
          child: Text(l10n.dateDetailDelete),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;

  final broken = await ref
      .read(datesControllerProvider.notifier)
      .delete(date.id);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        broken ? l10n.dateDetailStreakDropped : l10n.dateDetailDeleted,
      ),
    ),
  );
  context.go('/dates');
}

/// The photo strip at the top of the date. Signed URLs (audit-style: never
/// cached past this screen). Long-press offers to remove one — the same
/// gesture the brief calls for.
class _PhotoGallery extends ConsumerWidget {
  const _PhotoGallery({required this.date});
  final DateEntry date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: date.photos.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: RachaTokens.space2),
        itemBuilder: (context, i) {
          final photo = date.photos[i];
          return GestureDetector(
            onLongPress: () => _confirmDeletePhoto(context, ref, date, photo),
            child: ClipRRect(
              borderRadius: RachaTokens.brM,
              child: Image.network(
                photo.thumbUrl ?? photo.url,
                height: 96,
                width: 96,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null
                    ? child
                    : Container(
                        height: 96,
                        width: 96,
                        color: scheme.surfaceContainerHighest,
                      ),
                errorBuilder: (context, error, stack) => Container(
                  height: 96,
                  width: 96,
                  color: scheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _confirmDeletePhoto(
  BuildContext context,
  WidgetRef ref,
  DateEntry date,
  DatePhoto photo,
) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.dateDetailRemovePhotoTitle),
      content: Text(l10n.dateDetailRemovePhotoBody),
      actions: [
        TextButton(
          onPressed: () => context.pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => context.pop(true),
          child: Text(l10n.dateDetailRemovePhoto),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref
        .read(datesControllerProvider.notifier)
        .deletePhoto(date.id, photo.id);
  } on ApiException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(e.localizedMessage(context))));
  }
}
