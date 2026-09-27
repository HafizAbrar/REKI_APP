import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/observability_service.dart';
import '../../../core/theme/app_theme.dart';

/// Phase 8 — First-run onboarding (ASO / activation).
///
/// Shown once after install (flag stored in SharedPreferences). Slides explain
/// the core value props; "Get started" routes to login/signup.
class OnboardingScreen extends ConsumerStatefulWidget {
  static const _seenKey = 'onboarding_seen_v1';

  const OnboardingScreen({super.key});

  static Future<bool> hasCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_seenKey) ?? false;
  }

  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seenKey, true);
  }

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(observabilityProvider).trackEvent('onboarding_viewed', const {});
    });
  }

  static const _slides = [
    (Icons.place_outlined, 'Find the right vibe',
        'See live busyness and vibes for venues across your city.'),
    (Icons.local_offer_outlined, 'Unlock offers',
        'Discover and redeem exclusive deals at your favourite spots.'),
    (Icons.notifications_active_outlined, 'Never miss out',
        'Smart alerts when your favourite venues are about to get lively.'),
  ];

  Future<void> _finish({bool skipped = false}) async {
    await OnboardingScreen.markCompleted();
    ref.read(observabilityProvider).trackEvent(
          skipped ? 'onboarding_skipped' : 'onboarding_completed',
          {'slides_viewed': _index + 1},
        );
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _finish(skipped: true),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) {
                  final (icon, title, subtitle) = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ExcludeSemantics(
                          child: Icon(icon,
                              size: 96, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: 24),
                        Semantics(
                          header: true,
                          child: Text(title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall),
                        ),
                        const SizedBox(height: 12),
                        Text(subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  width: _index == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? AppTheme.primaryColor
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: _index == _slides.length - 1
                      ? 'Get started'
                      : 'Next',
                  child: FilledButton(
                    onPressed: () {
                      if (_index == _slides.length - 1) {
                        _finish();
                      } else {
                        _controller.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut);
                      }
                    },
                    child: Text(_index == _slides.length - 1
                        ? 'Get started'
                        : 'Next'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
