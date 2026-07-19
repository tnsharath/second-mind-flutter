import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.now, required this.name});

  final DateTime now;
  final String name;

  String get _greeting {
    final hour = now.hour;
    if (hour < 5) return 'Up late';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = name.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, MMMM d').format(now),
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        Text('$_greeting, $firstName', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          DateFormat('HH:mm').format(now),
          style: theme.textTheme.displaySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
