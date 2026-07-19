import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/shared/widgets/aura_button.dart';
import '../../../core/shared/widgets/aura_loading.dart';
import '../../../core/shared/widgets/aura_logo.dart';
import '../../../routes/app_router.dart';
import '../application/auth_controller.dart';

class AuthScreen extends HookConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (previous, next) {
      if (next.hasError && !next.isLoading) {
        final error = next.error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is AppFailure
                  ? error.message
                  : 'Sign-in failed. Please try again.',
            ),
          ),
        );
      }
    });

    final state = ref.watch(authStateProvider);
    final isLoading = state.isLoading;
    final theme = Theme.of(context);

    Future<void> goHomeIfSignedIn() async {
      if (context.mounted && ref.read(authStateProvider).valueOrNull != null) {
        context.go(AppRoutes.home);
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  const AuraLogo(size: 88),
                  const SizedBox(height: 24),
                  Text('Meet AURA', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  Text(
                    'A calm, persistent companion that remembers, '
                    'plans and speaks with you — everywhere.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(flex: 3),
                  AuraButton(
                    label: 'Continue with Google',
                    icon: Icons.login_rounded,
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(authStateProvider.notifier)
                                .signInWithGoogle();
                            await goHomeIfSignedIn();
                          },
                  ),
                  const SizedBox(height: 12),
                  AuraButton(
                    label: 'Skip for now',
                    variant: AuraButtonVariant.ghost,
                    onPressed: isLoading
                        ? null
                        : () async {
                            await ref
                                .read(authStateProvider.notifier)
                                .continueAsGuest();
                            await goHomeIfSignedIn();
                          },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'By continuing you agree to the AURA terms and privacy policy.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const AuraLoading(),
            ),
        ],
      ),
    );
  }
}
