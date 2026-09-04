import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/money.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../dates/presentation/date_format.dart';
import '../application/wrapped_controller.dart';

/// /wrapped — a swipeable "year in review". Each card is a full-bleed panel with
/// one number; the dots track progress and the buttons step through. All figures
/// come from [wrappedProvider]; nothing here is stored.
class WrappedScreen extends ConsumerStatefulWidget {
  const WrappedScreen({super.key});

  @override
  ConsumerState<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends ConsumerState<WrappedScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final year = defaultWrappedYear();
    final async = ref.watch(wrappedProvider(year));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: async.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (_, __) => _ErrorBody(message: l10n.commonSomethingWentWrong),
        data: (data) {
          final cards = _buildCards(context, l10n, data);
          return SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(RachaTokens.space3),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (var i = 0; i < cards.length; i++)
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                ),
                                height: 6,
                                width: i == _page ? 20 : 6,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(
                                    alpha: i == _page ? 1 : 0.3,
                                  ),
                                  borderRadius: RachaTokens.brS,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: cards,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(RachaTokens.space5),
                  child: Row(
                    children: [
                      if (_page > 0)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () => _controller.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                            child: Text(l10n.wrappedPrev),
                          ),
                        ),
                      if (_page > 0 && _page < cards.length - 1)
                        const SizedBox(width: RachaTokens.space3),
                      if (_page < cards.length - 1)
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: () => _controller.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            ),
                            child: Text(l10n.wrappedNext),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCards(
    BuildContext context,
    AppLocalizations l10n,
    WrappedData data,
  ) {
    final ov = data.overview;
    final topCategory = data.places.byCategory.isEmpty
        ? null
        : data.places.byCategory.reduce((a, b) => a.visits >= b.visits ? a : b);

    return [
      _CardShell(
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 72,
          ),
          const SizedBox(height: RachaTokens.space4),
          Text(
            l10n.wrappedIntroTitle,
            style: _small,
            textAlign: TextAlign.center,
          ),
          Text('${data.year}', style: _huge),
          const SizedBox(height: RachaTokens.space4),
          Text(
            l10n.wrappedIntroBody,
            style: _body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      _CardShell(
        children: [
          Text(l10n.wrappedTotalLabel.toUpperCase(), style: _small),
          const SizedBox(height: RachaTokens.space4),
          Text('${ov.totalDates}', style: _huge),
          Text(l10n.wrappedTotalDates(data.year), style: _body),
          const SizedBox(height: RachaTokens.space6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _MiniStat(
                value: '${ov.distinctPlaces}',
                label: l10n.wrappedNewPlaces,
              ),
              const SizedBox(width: RachaTokens.space6),
              _MiniStat(
                value: l10n.wrappedWeeksShort(ov.longestStreak),
                label: l10n.wrappedMaxStreak,
              ),
            ],
          ),
        ],
      ),
      if (topCategory != null)
        _CardShell(
          children: [
            Text(l10n.wrappedFavCategory.toUpperCase(), style: _small),
            const SizedBox(height: RachaTokens.space4),
            Text(
              categoryLabel(l10n, topCategory.category),
              style: _big,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: RachaTokens.space2),
            Text(
              l10n.wrappedFavCategoryCount(topCategory.visits, ov.totalDates),
              style: _body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      if (ov.bestMonth != null && ov.datesByMonth.isNotEmpty)
        _CardShell(
          children: [
            Text(l10n.wrappedBestMonth.toUpperCase(), style: _small),
            const SizedBox(height: RachaTokens.space4),
            Text(
              monthLabel(
                ov.bestMonth!,
                Localizations.localeOf(context).toLanguageTag(),
                short: false,
              ),
              style: _big,
            ),
            const SizedBox(height: RachaTokens.space6),
            _MonthBars(months: ov.datesByMonth),
          ],
        ),
      _CardShell(
        children: [
          Text(l10n.wrappedRecap.toUpperCase(), style: _small),
          const SizedBox(height: RachaTokens.space5),
          for (final c in data.places.byCategory.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: RachaTokens.space2),
              child: _RecapRow(
                label: categoryLabel(l10n, c.category),
                value: l10n.summaryVisitsCount(c.visits),
              ),
            ),
          _RecapRow(
            label: l10n.wrappedTotalSpend,
            value: formatMoneyByCurrency(
              ov.costByCurrency,
              locale: Localizations.localeOf(context).toString(),
            ),
          ),
        ],
      ),
    ];
  }
}

const _small = TextStyle(color: Colors.white70, fontSize: RachaType.callout);
const _body = TextStyle(color: Colors.white, fontSize: RachaType.body);
const _big = TextStyle(
  color: Colors.white,
  fontSize: RachaType.title,
  fontWeight: FontWeight.w800,
);
const _huge = TextStyle(
  color: Colors.white,
  fontSize: 64,
  fontWeight: FontWeight.w900,
);

class _CardShell extends StatelessWidget {
  const _CardShell({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RachaTokens.space6),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: RachaType.headline,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: RachaType.caption,
        ),
      ),
    ],
  );
}

class _RecapRow extends StatelessWidget {
  const _RecapRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RachaTokens.space4,
        vertical: RachaTokens.space3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: RachaTokens.brM,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: RachaType.callout,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: RachaType.callout,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthBars extends StatelessWidget {
  const _MonthBars({required this.months});
  final List<({String month, int count})> months;

  @override
  Widget build(BuildContext context) {
    final maxCount = months.fold(1, (a, m) => m.count > a ? m.count : a);
    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final m in months)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Container(
                  height: 60 * (m.count / maxCount),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: m.count == maxCount ? 1 : 0.3,
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    ),
  );
}
