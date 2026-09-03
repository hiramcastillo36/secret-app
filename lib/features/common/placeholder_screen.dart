import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Stand-in for screens that later vertical slices will build. Keeps the router
/// complete so navigation between finished screens already works.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(RachaTokens.space6),
          child: Text(
            '“$title” — próximamente',
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
