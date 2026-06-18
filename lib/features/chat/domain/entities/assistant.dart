import 'package:equatable/equatable.dart';

/// A configurable AI assistant (e.g. Software Engineer, Legal Advisor).
///
/// Each assistant carries its own gradient background colours (light + dark)
/// served by `/api/assistants`, so every assistant screen looks distinct —
/// matching the web app.
class Assistant extends Equatable {
  final int id;
  final String name;
  final String? description;

  /// Lucide icon name from the backend (e.g. "Code", "PenLine"). Mapped to a
  /// Material icon on the Flutter side.
  final String icon;

  final int? defaultModelId;
  final List<String> suggestedPrompts;
  final bool isActive;

  // ── Gradient background (hex strings like "#f3e8ff") ──────────────────────
  final String? bgFrom;
  final String? bgVia;
  final String? bgTo;
  final String? bgFromDark;
  final String? bgViaDark;
  final String? bgToDark;

  const Assistant({
    required this.id,
    required this.name,
    this.description,
    this.icon = 'Bot',
    this.defaultModelId,
    this.suggestedPrompts = const [],
    this.isActive = true,
    this.bgFrom,
    this.bgVia,
    this.bgTo,
    this.bgFromDark,
    this.bgViaDark,
    this.bgToDark,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        icon,
        defaultModelId,
        suggestedPrompts,
        isActive,
        bgFrom,
        bgVia,
        bgTo,
        bgFromDark,
        bgViaDark,
        bgToDark,
      ];
}
