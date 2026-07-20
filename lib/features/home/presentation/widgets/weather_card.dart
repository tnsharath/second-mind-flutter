import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/shared/widgets/aura_card.dart';
import '../../../../core/shared/widgets/aura_loading.dart';
import '../../application/home_providers.dart';

class WeatherCard extends HookConsumerWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider);
    final theme = Theme.of(context);
    return AuraCard(
      child: weather.when(
        data: (info) => Row(
          children: [
            Icon(
              Icons.wb_sunny_outlined,
              size: 34,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${info.temperatureC.round()}° · ${info.condition}',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'High ${info.highC?.round() ?? '—'}° · Low ${info.lowC?.round() ?? '—'}°',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const AuraShimmerBox(height: 34),
        error: (_, __) => Text(
          'Weather unavailable.',
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}
