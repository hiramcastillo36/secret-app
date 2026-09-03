import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens.dart';

/// Three swipeable cards on the plum ground that state the promise, then two
/// actions: create an account, or sign in.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const _icons = [
    Icons.restaurant_menu,
    Icons.menu_book_outlined,
    Icons.local_fire_department,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final cards = [
      (l10n.onboardingTitle1, l10n.onboardingBody1),
      (l10n.onboardingTitle2, l10n.onboardingBody2),
      (l10n.onboardingTitle3, l10n.onboardingBody3),
    ];
    final last = _page == cards.length - 1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: RachaTokens.streakGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white.withValues(alpha: 0.7),
                  ),
                  child: Text(l10n.onboardingSkip),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemCount: cards.length,
                  itemBuilder: (context, i) {
                    final (title, body) = cards[i];
                    return Padding(
                      padding: const EdgeInsets.all(RachaTokens.space6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 128,
                            width: 128,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              _icons[i],
                              color: Colors.white,
                              size: 56,
                            ),
                          ),
                          const SizedBox(height: RachaTokens.space6),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: RachaType.title,
                              fontWeight: FontWeight.w900,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: RachaTokens.space3),
                          Text(
                            body,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: RachaType.body,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(cards.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(
                      horizontal: RachaTokens.space1,
                    ),
                    width: active ? RachaTokens.space5 : RachaTokens.space2,
                    height: RachaTokens.space2,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: active ? 1 : 0.35),
                      borderRadius: RachaTokens.brL,
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(RachaTokens.space5),
                child: last
                    ? Column(
                        children: [
                          _WhiteButton(
                            label: l10n.onboardingCreateAccount,
                            onPressed: () => context.push('/register'),
                          ),
                          const SizedBox(height: RachaTokens.space2),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              minimumSize: const Size.fromHeight(52),
                            ),
                            onPressed: () => context.push('/login'),
                            child: Text(l10n.onboardingSignIn),
                          ),
                        ],
                      )
                    : _WhiteButton(
                        label: l10n.onboardingNext,
                        onPressed: () => _controller.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteButton extends StatelessWidget {
  const _WhiteButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: RachaTokens.seed,
        minimumSize: const Size.fromHeight(52),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
