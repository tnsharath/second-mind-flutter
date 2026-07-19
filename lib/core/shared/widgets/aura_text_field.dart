import 'package:flutter/material.dart';

/// Styled text field matching the AURA input decoration theme.
class AuraTextField extends StatelessWidget {
  const AuraTextField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffix,
    this.autofocus = false,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      enabled: enabled,
      textInputAction: TextInputAction.send,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
        suffixIcon: suffix,
      ),
    );
  }
}
