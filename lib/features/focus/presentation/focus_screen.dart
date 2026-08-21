import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/shared/widgets/aura_bottom_sheet.dart';
import '../../../core/shared/widgets/aura_button.dart';
import '../../../core/shared/widgets/aura_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../application/focus_providers.dart';

class FocusScreen extends HookConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(focusTimerProvider);
    final controller = ref.read(focusTimerProvider.notifier);
    final theme = Theme.of(context);

    final statusLabel = switch (timer.phase) {
      FocusPhase.idle => 'Choose a length, then begin',
      FocusPhase.running => 'Focusing…',
      FocusPhase.paused => 'Paused',
      FocusPhase.completed => 'Session complete',
    };

    return Scaffold(
      appBar: AppBar(title: const Text('Focus')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Text(
                  statusLabel,
                  key: ValueKey(timer.phase),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: Center(
                  child: _CountdownRing(
                    progress: timer.progress,
                    phase: timer.phase,
                    label: _formatClock(timer.remainingSeconds),
                  ),
                ),
              ),
              if (timer.phase == FocusPhase.idle) ...[
                _PresetRow(
                  selectedMinutes: timer.selectedMinutes,
                  onSelect: controller.selectMinutes,
                ),
                const SizedBox(height: 24),
                AuraButton(
                  label: 'Start focus',
                  icon: Icons.play_arrow_rounded,
                  expand: false,
                  onPressed: controller.start,
                ),
              ] else if (timer.phase == FocusPhase.completed) ...[
                Text(
                  '${timer.selectedMinutes} minutes logged.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AuraButton(
                  label: 'Start another',
                  icon: Icons.replay_rounded,
                  expand: false,
                  onPressed: controller.acknowledge,
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AuraButton(
                      label: timer.phase == FocusPhase.paused
                          ? 'Resume'
                          : 'Pause',
                      icon: timer.phase == FocusPhase.paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      expand: false,
                      onPressed: timer.phase == FocusPhase.paused
                          ? controller.start
                          : controller.pause,
                    ),
                    const SizedBox(width: 12),
                    AuraButton(
                      label: 'Reset',
                      icon: Icons.refresh_rounded,
                      variant: AuraButtonVariant.ghost,
                      expand: false,
                      onPressed: controller.reset,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatClock(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({required this.selectedMinutes, required this.onSelect});

  final int selectedMinutes;
  final ValueChanged<int> onSelect;

  static const List<int> _presets = [25, 50];

  @override
  Widget build(BuildContext context) {
    final isCustom = !_presets.contains(selectedMinutes);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final minutes in _presets) ...[
          _PresetChip(
            label: '$minutes',
            selected: selectedMinutes == minutes,
            onTap: () => onSelect(minutes),
          ),
          const SizedBox(width: 10),
        ],
        _PresetChip(
          label: isCustom ? '$selectedMinutes min' : 'Custom',
          selected: isCustom,
          onTap: () => _pickCustomMinutes(context),
        ),
      ],
    );
  }

  Future<void> _pickCustomMinutes(BuildContext context) async {
    final minutes = await AuraBottomSheet.show<int>(
      context,
      title: 'Custom length',
      child: _CustomMinutesSheet(initial: selectedMinutes),
    );
    if (minutes != null) onSelect(minutes);
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : scheme.outline.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? AppColors.primary : null,
            fontWeight: selected ? FontWeight.w600 : null,
          ),
        ),
      ),
    );
  }
}

class _CustomMinutesSheet extends HookWidget {
  const _CustomMinutesSheet({required this.initial});

  final int initial;

  @override
  Widget build(BuildContext context) {
    final input = useTextEditingController(text: '$initial');
    final error = useState<String?>(null);

    void submit() {
      final minutes = int.tryParse(input.text.trim());
      if (minutes == null || minutes < 5 || minutes > 120) {
        error.value = 'Enter a number between 5 and 120.';
        return;
      }
      Navigator.of(context).pop(minutes);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuraTextField(
          controller: input,
          hint: 'Minutes (5–120)',
          prefixIcon: Icons.timer_outlined,
          autofocus: true,
          onSubmitted: (_) => submit(),
        ),
        if (error.value != null) ...[
          const SizedBox(height: 8),
          Text(
            error.value!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        AuraButton(label: 'Set length', onPressed: submit),
      ],
    );
  }
}

/// Large circular countdown ring with the AURA primary→accent sweep.
class _CountdownRing extends StatelessWidget {
  const _CountdownRing({
    required this.progress,
    required this.phase,
    required this.label,
  });

  final double progress;
  final FocusPhase phase;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 250,
      height: 250,
      child: CustomPaint(
        painter: _RingPainter(progress: progress),
        child: Center(
          child: phase == FocusPhase.completed
              ? const Icon(
                  Icons.check_rounded,
                  size: 64,
                  color: AppColors.success,
                )
              : Text(
                  label,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 9;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = AppColors.border;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        colors: [AppColors.primary, AppColors.accent],
      ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
