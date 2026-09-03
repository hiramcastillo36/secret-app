import 'package:flutter/material.dart';

import '../../../theme/tokens.dart';

/// The plum banner every auth screen opens with: a heart badge, a big white
/// title and a muted subtitle. Shows a white back arrow when there's somewhere
/// to go back to.
class AuthHero extends StatelessWidget {
  const AuthHero({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.favorite,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: RachaTokens.streakGradient,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(RachaTokens.space5, RachaTokens.space2,
              RachaTokens.space5, RachaTokens.space6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 40,
                child: canPop
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          style: IconButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(40, 40),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: RachaTokens.space3),
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: RachaTokens.brL,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Icon(icon, color: Colors.white, size: 32),
              ),
              const SizedBox(height: RachaTokens.space4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: RachaType.title,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
