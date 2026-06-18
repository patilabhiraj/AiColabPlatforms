import '../../domain/entities/assistant.dart';

class AssistantModel extends Assistant {
  const AssistantModel({
    required super.id,
    required super.name,
    super.description,
    super.icon,
    super.defaultModelId,
    super.suggestedPrompts,
    super.isActive,
    super.bgFrom,
    super.bgVia,
    super.bgTo,
    super.bgFromDark,
    super.bgViaDark,
    super.bgToDark,
  });

  factory AssistantModel.fromJson(Map<String, dynamic> json) {
    return AssistantModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Assistant',
      description: json['description']?.toString(),
      icon: json['icon']?.toString() ?? 'Bot',
      defaultModelId: (json['defaultModelId'] as num?)?.toInt(),
      suggestedPrompts: _stringList(json['suggestedPrompts']),
      isActive: json['isActive'] as bool? ?? true,
      bgFrom: json['bgFrom']?.toString(),
      bgVia: json['bgVia']?.toString(),
      bgTo: json['bgTo']?.toString(),
      bgFromDark: json['bgFromDark']?.toString(),
      bgViaDark: json['bgViaDark']?.toString(),
      bgToDark: json['bgToDark']?.toString(),
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}
