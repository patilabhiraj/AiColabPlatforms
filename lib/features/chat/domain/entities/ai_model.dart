import 'package:equatable/equatable.dart';

/// An AI model available for selection in the chat composer.
///
/// Mirrors the `/api/models` response used by the web frontend so the model
/// picker (single / multi select + capability filtering) behaves identically.
class AiModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String externalId;
  final List<String> capabilities;
  final List<String> defaultForCapabilities;
  final bool isActive;
  final String? providerName;

  const AiModel({
    required this.id,
    required this.name,
    this.description,
    this.externalId = '',
    this.capabilities = const [],
    this.defaultForCapabilities = const [],
    this.isActive = true,
    this.providerName,
  });

  /// Whether this model supports the given capability. Models with no declared
  /// capabilities are treated as STANDARD-only (matches the web behaviour).
  bool supportsCapability(String capability) {
    if (capabilities.isEmpty) return capability == 'STANDARD';
    return capabilities.contains(capability);
  }

  bool get supportsVision => capabilities.contains('VISION');

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        externalId,
        capabilities,
        defaultForCapabilities,
        isActive,
        providerName,
      ];
}
