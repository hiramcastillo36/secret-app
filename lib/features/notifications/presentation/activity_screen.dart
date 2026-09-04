import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';
import '../../dates/presentation/date_format.dart';
import '../application/notifications.dart';

/// /activity — the in-app notification centre: reminders and partner activity,
/// newest first, cursor-paginated. Opening the screen marks everything read and
/// clears the Home badge.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _items = <AppNotification>[];
  String? _cursor;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _loadFirst();
  }

  Future<void> _loadFirst() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final c = ref.read(notificationsControllerProvider.notifier);
      final page = await c.history();
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(page.items);
        _cursor = page.nextCursor;
        _loading = false;
      });
      // Opening the centre counts as seeing everything.
      if (page.unread > 0) {
        await c.markAllRead();
        if (mounted) {
          setState(() {
            for (var i = 0; i < _items.length; i++) {
              _items[i] = _read(_items[i]);
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _cursor == null) return;
    setState(() => _loadingMore = true);
    try {
      final page = await ref
          .read(notificationsControllerProvider.notifier)
          .history(cursor: _cursor);
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _cursor = page.nextCursor;
      });
    } catch (_) {
      // Without this the failure was swallowed and "load more" just went
      // quiet (audit F, low: finally with no catch). The cursor is kept so
      // the next scroll / tap retries.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).commonSomethingWentWrong,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  static AppNotification _read(AppNotification n) => AppNotification(
    id: n.id,
    kind: n.kind,
    title: n.title,
    body: n.body,
    route: n.route,
    read: true,
    createdAt: n.createdAt,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityTitle)),
      body: RefreshIndicator(onRefresh: _loadFirst, child: _buildBody(l10n)),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _items.isEmpty) {
      return _CenteredRetry(
        message: l10n.commonSomethingWentWrong,
        retryLabel: l10n.commonRetry,
        onRetry: _loadFirst,
      );
    }
    if (_items.isEmpty) {
      return _EmptyState(text: l10n.activityEmpty);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(RachaTokens.space4),
      itemCount: _items.length + (_cursor != null ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _items.length) {
          return Padding(
            padding: const EdgeInsets.all(RachaTokens.space4),
            child: Center(
              child: _loadingMore
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: _loadMore,
                      child: Text(l10n.activityLoadMore),
                    ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: RachaTokens.space2),
          child: _NotificationTile(item: _items[i]),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});
  final AppNotification item;

  IconData get _icon => switch (item.kind) {
    'streak_advanced' => Icons.local_fire_department_outlined,
    'streak_at_risk' => Icons.event_available_outlined,
    'tag_pending' => Icons.how_to_reg_outlined,
    'partner_activity' => Icons.favorite_outline,
    'weekly_recap' => Icons.insights_outlined,
    _ => Icons.notifications_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unread = !item.read;
    return Material(
      color: unread ? scheme.surfaceContainerLow : scheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: RachaTokens.brM,
        side: BorderSide(
          color: scheme.outlineVariant,
          width: RachaTokens.borderHairline,
        ),
      ),
      child: InkWell(
        onTap: () => context.push(item.route),
        child: Padding(
          padding: const EdgeInsets.all(RachaTokens.space3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 8,
                child: unread
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scheme.primary,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: RachaTokens.space2),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: unread
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest,
                  borderRadius: RachaTokens.brS,
                ),
                child: Icon(
                  _icon,
                  size: 20,
                  color: unread
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: RachaTokens.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (item.body.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.body,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: RachaType.caption,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      relativeDay(context, item.createdAt),
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: RachaType.micro,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.notifications_none_outlined,
          size: 48,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(height: RachaTokens.space4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: RachaTokens.space6),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}

class _CenteredRetry extends StatelessWidget {
  const _CenteredRetry({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 140),
        Center(child: Text(message, textAlign: TextAlign.center)),
        const SizedBox(height: RachaTokens.space2),
        Center(
          child: TextButton(onPressed: onRetry, child: Text(retryLabel)),
        ),
      ],
    );
  }
}
