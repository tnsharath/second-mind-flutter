import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/config/app_config.dart';
import '../../../core/shared/widgets/aura_logo.dart';
import '../../../routes/app_router.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 900),
    );

    useEffect(() {
      controller.forward();
      final timer = Timer(const Duration(milliseconds: 1400), () {
        if (context.mounted) context.go(AppRoutes.home);
      });
      return timer.cancel;
    }, const []);

    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuraLogo(size: 96),
              const SizedBox(height: 24),
              Text(
                'A U R A',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(letterSpacing: 8, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(AppConfig.tagline, style: theme.textTheme.bodySmall),
              const SizedBox(height: 36),
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
