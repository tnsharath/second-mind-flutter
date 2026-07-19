import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/env.dart';
import '../../../core/shared/widgets/aura_button.dart';
import '../../../core/shared/widgets/aura_card.dart';
import '../../../core/shared/widgets/aura_dialog.dart';
import '../../../routes/app_router.dart';
import '../../auth/application/auth_controller.dart';
import '../application/settings_controller.dart';
import '../domain/app_settings.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  static const Map<String, String> _languages = {
    'en': 'English',
    'es': 'Español',
    'hi': 'हिन्दी',
    'ja': '日本語',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final controller = ref.read(settingsProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          const _SectionTitle('Appearance'),
          AuraCard(
            child: Row(
              children: [
                Expanded(
                  child: Text('Theme', style: theme.textTheme.bodyMedium),
                ),
                SegmentedButton<AppThemeMode>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: AppThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: AppThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined, size: 16),
                    ),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (selection) =>
                      controller.setThemeMode(selection.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Voice & language'),
          AuraCard(
            child: Column(
              children: [
                _DropdownRow<String>(
                  title: 'Voice',
                  value: settings.voiceName,
                  items: const {
                    'AURA': 'AURA (default)',
                    'Calm': 'Calm',
                    'Bright': 'Bright',
                  },
                  onChanged: (v) => controller.setVoiceName(v!),
                ),
                const Divider(height: 24),
                _DropdownRow<String>(
                  title: 'Language',
                  value: settings.languageCode,
                  items: _languages,
                  onChanged: (v) => controller.setLanguageCode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Notifications'),
          AuraCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable notifications'),
                  value: settings.notificationsEnabled,
                  onChanged: controller.setNotificationsEnabled,
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Morning briefing'),
                  subtitle: const Text('A calm summary to start the day'),
                  value: settings.morningBriefingEnabled,
                  onChanged: controller.setMorningBriefingEnabled,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('Developer'),
          AuraCard(
            child: Column(
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Developer mode'),
                  value: settings.developerMode,
                  onChanged: controller.setDeveloperMode,
                ),
                if (settings.developerMode) ...[
                  const Divider(height: 24),
                  _InfoRow(label: 'API base URL', value: Env.apiBaseUrl),
                  _InfoRow(
                    label: 'Mock mode',
                    value: Env.useMockApi ? 'on' : 'off',
                  ),
                  const _InfoRow(
                    label: 'Build',
                    value: '${AppConfig.appVersion} (Phase 1)',
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const _SectionTitle('About'),
          AuraCard(
            child: Column(
              children: [
                const _InfoRow(label: 'Version', value: AppConfig.appVersion),
                InkWell(
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppConfig.appName,
                    applicationVersion: AppConfig.appVersion,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Open source licenses',
                              style: theme.textTheme.bodyMedium),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AuraButton(
            label: 'Sign out',
            variant: AuraButtonVariant.ghost,
            icon: Icons.logout_rounded,
            onPressed: () async {
              final confirmed = await AuraDialog.showConfirm(
                context,
                title: 'Sign out?',
                message: 'Your local session on this device will be cleared.',
                confirmLabel: 'Sign out',
                destructive: true,
              );
              if (confirmed == true) {
                await ref.read(authStateProvider.notifier).signOut();
                if (context.mounted) context.go(AppRoutes.auth);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownRow<T> extends StatelessWidget {
  const _DropdownRow({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String title;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
        DropdownButton<T>(
          value: value,
          underline: const SizedBox.shrink(),
          borderRadius: BorderRadius.circular(14),
          items: [
            for (final entry in items.entries)
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
