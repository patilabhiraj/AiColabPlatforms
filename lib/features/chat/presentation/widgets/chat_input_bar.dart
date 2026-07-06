import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../bloc/chat_bloc.dart';
import '../../domain/entities/ai_model.dart';
import '../../domain/repositories/chat_repository.dart';
import 'catalog_visuals.dart';

/// Chat composer with model selection, capabilities and single/multi mode —
/// mirroring the web frontend's input bar.
///
/// Layout:
/// - Capability pill + selected-model chips (when relevant)
/// - Multi-line text field
/// - Bottom row: "+" menu · Single/Multi toggle · mic / send
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSend, this.enabled = true});
  final ValueChanged<String> onSend;
  final bool enabled;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar>
    with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _isFocused = false;
  bool _isEnhancing = false;
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      final has = _ctrl.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    _animCtrl.forward().then((_) => _animCtrl.reverse());
    _ctrl.clear();
    widget.onSend(text);
  }

  /// Rewrites the current draft into a clearer prompt via the backend and
  /// replaces the text field with the result. No-op when empty or busy.
  Future<void> _enhance() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _isEnhancing || !widget.enabled) return;

    setState(() => _isEnhancing = true);
    final result = await sl<ChatRepository>().enhancePrompt(text);
    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not enhance: ${failure.message}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (enhanced) {
        _ctrl.text = enhanced;
        // Keep the caret at the end so the user can keep typing naturally.
        _ctrl.selection =
            TextSelection.collapsed(offset: _ctrl.text.length);
      },
    );

    setState(() => _isEnhancing = false);
  }

  void _openComposerMenu() {
    if (!widget.enabled) return;
    final bloc = context.read<ChatBloc>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const _ComposerMenu(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(color: context.cBg),
      padding:
          EdgeInsets.fromLTRB(16, 12, 16, bottomPad > 0 ? bottomPad + 8 : 16),
      child: Container(
        decoration: BoxDecoration(
          color: context.cCard.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isFocused
                ? context.cBorder.withValues(alpha: 0.55)
                : context.cBorder.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Capability pill + selected model chips ───────────────────────
            const _SelectionPreview(),

            // ── Text field ───────────────────────────────────────────────────
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                enabled: widget.enabled,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(color: context.cFg, fontSize: 15, height: 1.4),
                decoration: InputDecoration(
                  hintText: widget.enabled ? 'Ask anything...' : 'AI is thinking…',
                  hintStyle: TextStyle(
                    color: context.cMuted.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                ),
              ),
            ),

            // ── Bottom action row ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  // "+" menu (attach / capabilities / models)
                  _IconButton(
                    icon: Icons.add_rounded,
                    onTap: widget.enabled ? _openComposerMenu : null,
                  ),
                  // const SizedBox(width: 4),

                  // Single / Multi toggle
                  const _ModeToggle(),

                 const Spacer(),
                  // Enhance prompt — only shown once the user has typed a draft.
                  if (_hasText) ...[
                    _EnhanceButton(
                      isEnhancing: _isEnhancing,
                      onTap: widget.enabled ? _enhance : null,
                    ),
                    const SizedBox(width: 4),
                  ],
                  // Voice / Send button
                  if (!_hasText)
                    _IconButton(
                      icon: Icons.graphic_eq_rounded,
                      onTap: widget.enabled ? () {} : null,
                    )
                  else 
                    ScaleTransition(
                      scale: _scaleAnim,
                      child: GestureDetector(
                        onTap: _send,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.cFg,
                          ),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: context.cBg,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Capability pill + selected model chips ────────────────────────────────────
class _SelectionPreview extends StatelessWidget {
  const _SelectionPreview();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (a, b) => b is ChatLoaded,
      builder: (context, state) {
        if (state is! ChatLoaded) return const SizedBox.shrink();

        final accent = AppColors.landingPrimary;
        final chips = <Widget>[];

        // Capability pill (when not standard)
        if (state.capability != 'STANDARD') {
          chips.add(_Pill(
            icon: CatalogVisuals.capabilityIcon(state.capability),
            label: CatalogVisuals.capabilityLabel(state.capability),
            color: accent,
            onClose: () =>
                context.read<ChatBloc>().add(ChatSetCapability('STANDARD')),
          ));
        }

        // Selected model chips (only meaningful in multi mode)
        if (state.multiMode && state.selectedModelIds.length > 1) {
          for (final id in state.selectedModelIds) {
            // NB: `availableModels` may hold `AiModelModel` (a subtype) at
            // runtime, so `firstWhere(orElse: …)` reifies the orElse return
            // type as that subtype and throws if we return a plain `AiModel`.
            // A nullable lookup avoids that covariance trap entirely.
            AiModel? found;
            for (final m in state.availableModels) {
              if (m.id == id) {
                found = m;
                break;
              }
            }
            if (found == null) continue;
            final model = found;
            chips.add(_Pill(
              icon: CatalogVisuals.modelIcon(model.externalId),
              iconColor: CatalogVisuals.modelColor(model.externalId),
              label: model.name,
              color: accent,
              onClose: () =>
                  context.read<ChatBloc>().add(ChatToggleModel(model.id)),
            ));
          }
        }

        if (chips.isEmpty) return const SizedBox.shrink();

        // A single horizontally-scrolling row keeps the composer height fixed
        // no matter how many models are selected — the chips scroll sideways
        // instead of wrapping into taller and taller rows.
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: SizedBox(
            height: 34,
            child: ShaderMask(
              // Fade the right edge so it's obvious more chips lie off-screen.
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: const [Colors.white, Colors.white, Colors.transparent],
                stops: const [0.0, 0.92, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                itemCount: chips.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (_, i) => Center(child: chips[i]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    this.iconColor,
    this.onClose,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color? iconColor;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? color),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.cFg.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onClose,
              child: Icon(Icons.close_rounded,
                  size: 14, color: context.cMuted.withValues(alpha: 0.8)),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Single / Multi toggle ─────────────────────────────────────────────────────
class _ModeToggle extends StatelessWidget {
  const _ModeToggle();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (a, b) => b is ChatLoaded,
      builder: (context, state) {
        final multi = state is ChatLoaded && state.multiMode;
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: context.cCard.withValues(alpha: context.isDark ? 0.6 : 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.cBorder.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ModeChip(
                label: 'Single',
                active: !multi,
                onTap: () =>
                    context.read<ChatBloc>().add(ChatSetMultiMode(false)),
              ),
              _ModeChip(
                label: 'Multi',
                active: multi,
                onTap: () =>
                    context.read<ChatBloc>().add(ChatSetMultiMode(true)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? context.cBg : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active
                ? context.cFg
                : context.cMuted.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

// ── Composer menu (bottom sheet) ──────────────────────────────────────────────
class _ComposerMenu extends StatelessWidget {
  const _ComposerMenu();

  void _comingSoon(BuildContext context, String what) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$what — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: context.cBorder.withValues(alpha: 0.4)),
      ),
      child: BlocBuilder<ChatBloc, ChatState>(
        buildWhen: (a, b) => b is ChatLoaded,
        builder: (context, state) {
          if (state is! ChatLoaded) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final models = state.modelsForCapability;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.cMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                  children: [
                    // ── Attach file ───────────────────────────────────────────
                    _SectionLabel('Attach File'),
                    _MenuRow(
                      icon: Icons.photo_camera_outlined,
                      label: 'Capture Photo',
                      onTap: () => _comingSoon(context, 'Capture photo'),
                    ),
                    _MenuRow(
                      icon: Icons.image_outlined,
                      label: 'Upload a Photo',
                      onTap: () => _comingSoon(context, 'Photo upload'),
                    ),
                    _MenuRow(
                      icon: Icons.attach_file_rounded,
                      label: 'Upload a File',
                      onTap: () => _comingSoon(context, 'File upload'),
                    ),

                    _Divider(),

                    // ── Capabilities ─────────────────────────────────────────
                    _SectionLabel('Capabilities'),
                    _CapabilityRow(
                      capability: 'STANDARD',
                      active: state.capability == 'STANDARD',
                    ),
                    _CapabilityRow(
                      capability: 'WEB_SEARCH',
                      active: state.capability == 'WEB_SEARCH',
                    ),
                    _CapabilityRow(
                      capability: 'IMAGE_GENERATION',
                      active: state.capability == 'IMAGE_GENERATION',
                    ),

                    _Divider(),

                    // ── Models ───────────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionLabel('Models'),
                        if (state.multiMode &&
                            state.selectedModelIds.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: Text(
                              '${state.selectedModelIds.length} selected',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: context.cMuted,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (models.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No models available for this capability.',
                          style: TextStyle(color: context.cMuted, fontSize: 13),
                        ),
                      )
                    else
                      ...models.map((m) => _ModelRow(
                            model: m,
                            selected: state.selectedModelIds.contains(m.id),
                            singleMode: !state.multiMode,
                          )),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: context.cMuted.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      child: Divider(height: 1, color: context.cBorder.withValues(alpha: 0.4)),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: context.cMuted),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(color: context.cFg, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.capability, required this.active});
  final String capability;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () =>
            context.read<ChatBloc>().add(ChatSetCapability(capability)),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                child: active
                    ? Icon(Icons.check_rounded,
                        size: 18, color: AppColors.landingPrimary)
                    : null,
              ),
              const SizedBox(width: 8),
              Icon(CatalogVisuals.capabilityIcon(capability),
                  size: 19, color: context.cMuted),
              const SizedBox(width: 12),
              Text(
                CatalogVisuals.capabilityLabel(capability),
                style: TextStyle(color: context.cFg, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  const _ModelRow({
    required this.model,
    required this.selected,
    required this.singleMode,
  });

  final AiModel model;
  final bool selected;
  final bool singleMode;

  @override
  Widget build(BuildContext context) {
    final color = CatalogVisuals.modelColor(model.externalId);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<ChatBloc>().add(ChatToggleModel(model.id));
          // Single mode is a pick-and-go selection.
          if (singleMode) Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.check_rounded,
                            size: 18, color: AppColors.landingPrimary),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(CatalogVisuals.modelIcon(model.externalId),
                    size: 17, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.name,
                      style: TextStyle(
                        color: context.cFg,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (model.description != null &&
                        model.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          model.description!,
                          style: TextStyle(
                            color: context.cMuted.withValues(alpha: 0.9),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Enhance prompt button ─────────────────────────────────────────────────────
class _EnhanceButton extends StatelessWidget {
  const _EnhanceButton({required this.isEnhancing, this.onTap});

  final bool isEnhancing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.landingPrimary;
    final enabled = onTap != null && !isEnhancing;

    return GestureDetector(
      onTap: isEnhancing ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: enabled
              ? accent.withValues(alpha: 0.12)
              : context.cCard.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: enabled
                ? accent.withValues(alpha: 0.35)
                : context.cBorder.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEnhancing)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 1.8, color: accent),
              )
            else
              Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: enabled ? accent : context.cMuted.withValues(alpha: 0.5),
              ),
            const SizedBox(width: 5),
            Text(
              'Enhance',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: enabled
                    ? context.cFg
                    : context.cMuted.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Icon button ───────────────────────────────────────────────────────────────
class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(
            shape: BoxShape.circle, color: Colors.transparent),
        child: Icon(
          icon,
          color: context.cMuted.withValues(alpha: onTap != null ? 0.75 : 0.35),
          size: 24,
        ),
      ),
    );
  }
}
