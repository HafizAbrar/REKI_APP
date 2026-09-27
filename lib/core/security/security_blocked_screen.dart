import 'package:flutter/material.dart';

/// Phase 8 — Blocking screen shown when freeRASP detects a serious runtime
/// integrity threat (tampered binary, jailbreak/root) in production builds.
///
/// Deliberately vague about the specific check that failed. Non-dismissable,
/// so sensitive business/payment functionality cannot be reached while active.
class SecurityBlockedScreen extends StatelessWidget {
  const SecurityBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.gpp_bad_outlined,
                      size: 72, color: Color(0xFFEF4444)),
                  const SizedBox(height: 24),
                  Semantics(
                    header: true,
                    child: Text(
                      'Security check failed',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'REKI cannot run on this device because it does not pass '
                    'our security checks. This can happen on modified devices '
                    'or operating systems.\n\nPlease use an unmodified, '
                    'officially supported device, and contact '
                    'security@reki.uk if you believe this is a mistake.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
