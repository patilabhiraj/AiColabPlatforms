import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.controller,
    this.textInputAction,
  });

  final String label;
  final String hint;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.keyboardType == TextInputType.emailAddress
              ? TextCapitalization.none
              : TextCapitalization.words,
          textInputAction: widget.textInputAction,
          style: TextStyle(color: cs.onSurface, fontSize: 15),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
            filled: true,
            fillColor: cs.surface,
            border: OutlineInputBorder(
              borderRadius: AppRadius.borderXl,
              borderSide: BorderSide(color: cs.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderXl,
              borderSide: BorderSide(color: cs.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.borderXl,
              borderSide: BorderSide(color: cs.outlineVariant, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
