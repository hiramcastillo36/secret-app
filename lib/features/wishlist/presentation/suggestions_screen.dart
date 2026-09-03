import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../dates/presentation/date_format.dart';
import '../../plans/domain/models.dart';
import '../application/wishlist.dart';

/// /suggestions — up to three ideas built from the couple's own history, each
/// with a reason. Add one to the list or plan it straight away.
class SuggestionsScreen extends ConsumerStatefulWidget {
  const SuggestionsScreen({super.key});

  @override
  ConsumerState<SuggestionsScreen> createState() => _SuggestionsScreenState();
}

class _SuggestionsScreenState extends ConsumerState<SuggestionsScreen> {
  bool _cheap = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(suggestionsProvider(_cheap));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.suggestionsTitle),
        actions: [
          Row(
            children: [
              Text(
                l10n.suggestionsCheap,
                style: const TextStyle(fontSize: RachaType.caption),
              ),
              Switch(
                value: _cheap,
                onChanged: (v) => setState(() => _cheap = v),
              ),
              const SizedBox(width: RachaTokens.space2),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  Center(child: Text(l10n.commonSomethingWentWrong)),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(RachaTokens.space6),
                      child: Text(
                        l10n.suggestionsEmpty,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final scheme = Theme.of(context).colorScheme;
                return ListView(
                  padding: const EdgeInsets.all(RachaTokens.space4),
                  children: [
                    for (final s in list)
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: RachaTokens.space3,
                        ),
                        padding: const EdgeInsets.all(RachaTokens.space4),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: RachaTokens.brM,
                          border: Border.all(
                            color: scheme.outlineVariant,
                            width: RachaTokens.borderHairline,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: scheme.primaryContainer,
                                    borderRadius: RachaTokens.brS,
                                  ),
                                  child: Icon(
                                    categoryIcon(s.category),
                                    size: 20,
                                    color: scheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: RachaTokens.space3),
                                Expanded(
                                  child: Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontSize: RachaType.body,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: RachaTokens.space2),
                            Text(
                              s.reason,
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: RachaType.caption,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: RachaTokens.space3),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => context.push(
                                      '/plans/new',
                                      extra: PlanSeed(
                                        title: s.name,
                                        placeId: s.placeId,
                                        placeName: s.name,
                                      ),
                                    ),
                                    child: Text(l10n.wishlistPlanThis),
                                  ),
                                ),
                                const SizedBox(width: RachaTokens.space2),
                                Expanded(
                                  child: FilledButton.tonal(
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(
                                              wishlistControllerProvider
                                                  .notifier,
                                            )
                                            .create(
                                              title: s.name,
                                              placeId: s.placeId,
                                            );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(l10n.wishSaved),
                                            ),
                                          );
                                        }
                                      } on ApiException catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(content: Text(e.message)),
                                          );
                                        }
                                      }
                                    },
                                    child: Text(l10n.suggestionAddToList),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
