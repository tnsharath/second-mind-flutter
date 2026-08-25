import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/shared/widgets/aura_button.dart';
import '../application/voice_controller.dart';
import '../domain/voice_session_state.dart';
import 'widgets/voice_orb.dart';
import 'widgets/waveform_bars.dart';

class VoiceModeScreen extends HookConsumerWidget {
  const VoiceModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(voiceControllerProvider);
    final controller = ref.read(voiceControllerProvider.notifier);
    final theme = Theme.of(context);

    useEffect(() {
      WakelockPlus.enable();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (ref.read(voiceControllerProvider).phase == VoicePhase.idle) {
          ref.read(voiceControllerProvider.notifier).start();
        }
      });
      return () {
        WakelockPlus.disable();
      };
    }, const []);

    ref.listen<VoiceSessionState>(voiceControllerProvider, (previous, next) {
      if (previous?.phase == VoicePhase.speaking && next.phase == VoicePhase.idle) {
        if (context.mounted) {
          context.pop();
        }
      }
    });

    final statusLabel = switch (session.phase) {
      VoicePhase.idle => 'Tap the orb to talk',
      VoicePhase.listening => 'Listening…',
      VoicePhase.thinking => 'Thinking…',
      VoicePhase.speaking => 'Speaking…',
    };

    final detailText = switch (session.phase) {
      VoicePhase.listening when session.transcript.isNotEmpty =>
        session.transcript,
      VoicePhase.thinking => session.transcript,
      VoicePhase.speaking => session.response,
      _ => '',
    };

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  controller.interrupt();
                  context.pop();
                },
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: controller.toggle,
                      child: VoiceOrb(phase: session.phase),
                    ),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        statusLabel,
                        key: ValueKey(session.phase),
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (session.phase == VoicePhase.listening ||
                        session.phase == VoicePhase.speaking)
                      const WaveformBars()
                    else
                      const SizedBox(height: 44),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 72,
                      child: Text(
                        detailText,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (session.phase == VoicePhase.speaking ||
                        session.phase == VoicePhase.listening)
                      AuraButton(
                        label: 'Interrupt',
                        variant: AuraButtonVariant.ghost,
                        expand: false,
                        icon: Icons.stop_rounded,
                        onPressed: controller.interrupt,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
