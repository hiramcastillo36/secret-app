import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../dates/presentation/date_format.dart';
import '../../plans/domain/models.dart';
import '../data/wishlist_repository.dart';
import '../domain/models.dart';

/// /wishlist — places and ideas the couple wants to do. Tabs by status; from a
/// row you can plan it, mark it done, or delete it.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(wishlistProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.wishlistTitle),
          actions: [
            IconButton(
              tooltip: l10n.wishlistSuggestions,
              onPressed: () => context.push('/suggestions'),
              icon: const Icon(Icons.lightbulb_outline),
            ),
            IconButton(
              tooltip: l10n.wishlistRoulette,
              onPressed: () async {
                await context.push('/wishlist/roulette');
                ref.invalidate(wishlistProvider);
              },
              icon: const Icon(Icons.casino_outlined),
            ),
          ],
          bottom: TabBar(tabs: [
            Tab(text: l10n.wishlistTabOpen),
            Tab(text: l10n.wishlistTabPlanned),
            Tab(text: l10n.wishlistTabDone),
          ]),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await context.push('/wishlist/new');
            ref.invalidate(wishlistProvider);
          },
          child: const Icon(Icons.add),
        ),
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => Center(child: Text(l10n.commonSomethingWentWrong)),
          data: (list) => TabBarView(
            children: [
              _WishTab(items: list.items.where((i) => i.status == 'open').toList()),
              _WishTab(items: list.items.where((i) => i.status == 'planned').toList()),
              _WishTab(items: list.items.where((i) => i.status == 'done').toList()),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishTab extends ConsumerWidget {
  const _WishTab({required this.items});
  final List<WishItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(RachaTokens.space6),
          child: Text(l10n.wishlistEmpty, textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(RachaTokens.space4),
      itemCount: items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: RachaTokens.space3),
        child: _WishTile(item: items[i]),
      ),
    );
  }
}

String costBandLabel(AppLocalizations l10n, String? band) => switch (band) {
      'free' => l10n.wishCostFree,
      'low' => '\$',
      'mid' => '\$\$',
      'high' => '\$\$\$',
      _ => '',
    };

class _WishTile extends ConsumerWidget {
  const _WishTile({required this.item});
  final WishItem item;

  Future<void> _plan(BuildContext context, WidgetRef ref) async {
    await context.push('/plans/new',
        extra: PlanSeed(
          title: item.title,
          placeId: item.placeId,
          placeName: item.placeName,
          wishlistItemId: item.id,
        ));
    ref.invalidate(wishlistProvider);
  }

  Future<void> _toggleDone(BuildContext context, WidgetRef ref) async {
    final next = item.status == 'done' ? 'open' : 'done';
    try {
      await ref.read(wishlistRepositoryProvider).patch(item.id, status: next);
      ref.invalidate(wishlistProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    var force = false;
    if (item.status == 'planned') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(l10n.wishlistDeletePlanned),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.wishlistDelete)),
          ],
        ),
      );
      if (ok != true) return;
      force = true;
    }
    try {
      await ref.read(wishlistRepositoryProvider).delete(item.id, force: force);
      ref.invalidate(wishlistProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final band = costBandLabel(l10n, item.costBand);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: RachaTokens.brM,
        border: Border.all(color: scheme.outlineVariant, width: RachaTokens.borderHairline),
      ),
      padding: const EdgeInsets.all(RachaTokens.space3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: RachaTokens.brS,
            ),
            child: Icon(
              item.kind == 'place'
                  ? categoryIcon(item.placeCategory ?? 'other')
                  : Icons.lightbulb_outline,
              size: 20,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: RachaTokens.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                if (item.placeName != null || item.note != null) ...[
                  const SizedBox(height: 2),
                  Text(item.placeName ?? item.note!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: scheme.onSurfaceVariant, fontSize: RachaType.caption)),
                ],
                if (band.isNotEmpty) ...[
                  const SizedBox(height: RachaTokens.space2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: RachaTokens.space2, vertical: 2),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(RachaTokens.radiusFull),
                    ),
                    child: Text(band,
                        style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontSize: RachaType.micro,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: RachaTokens.space2),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (item.status != 'planned')
                FilledButton.tonal(
                  onPressed: () => _plan(context, ref),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: RachaTokens.space3),
                  ),
                  child: Text(l10n.wishlistPlanThis),
                ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'done':
                      _toggleDone(context, ref);
                    case 'delete':
                      _delete(context, ref);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                      value: 'done',
                      child: Text(item.status == 'done'
                          ? l10n.wishlistReopen
                          : l10n.wishlistMarkDone)),
                  PopupMenuItem(value: 'delete', child: Text(l10n.wishlistDelete)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
