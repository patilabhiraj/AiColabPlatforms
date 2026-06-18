import '../../domain/entities/ai_model.dart';

class AiModelModel extends AiModel {
  const AiModelModel({
    required super.id,
    required super.name,
    super.description,
    super.externalId,
    super.capabilities,
    super.defaultForCapabilities,
    super.isActive,
    super.providerName,
  });

  factory AiModelModel.fromJson(Map<String, dynamic> json) {
    return AiModelModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Model',
      description: json['description']?.toString(),
      externalId: json['externalId']?.toString() ?? '',
      capabilities: _stringList(json['capabilities']),
      defaultForCapabilities: _stringList(json['defaultForCapabilities']),
      isActive: json['isActive'] as bool? ?? true,
      providerName: json['modelProvider'] is Map<String, dynamic>
          ? (json['modelProvider']['name']?.toString())
          : null,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const [];
  }
}
