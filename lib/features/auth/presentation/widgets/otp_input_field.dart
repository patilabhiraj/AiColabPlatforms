import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    this.length = 5,
    required this.onChanged,
    required this.onCompleted,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());

    for (int i = 0; i < widget.length; i++) {
      final index = i;
      _nodes[index].onKeyEvent = (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _controllers[index].text.isEmpty &&
            index > 0) {
          _controllers[index - 1].clear();
          _nodes[index - 1].requestFocus();
          _notify();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _nodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _notify() {
    final code = _code;
    widget.onChanged(code);
    if (code.length == widget.length) widget.onCompleted(code);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: List.generate(widget.length, (i) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < widget.length - 1 ? 10 : 0),
            child: SizedBox(
              height: 56,
              child: TextField(
                controller: _controllers[i],
                focusNode: _nodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: BorderSide(color: cs.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.borderMd,
                    borderSide: const BorderSide(
                      color: AppColors.landingPrimary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  if (val.length == 1) {
                    if (i < widget.length - 1) {
                      _nodes[i + 1].requestFocus();
                    } else {
                      _nodes[i].unfocus();
                    }
                  }
                  _notify();
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
