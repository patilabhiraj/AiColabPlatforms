import '../../domain/entities/shared_chat.dart';

/// Shared chat model - data layer representation with JSON serialization
class SharedChatModel extends SharedChat {
  const SharedChatModel({
    required super.status,
    required super.message,
    super.data,
  });

  /// Create model from JSON response
  factory SharedChatModel.fromJson(Map<String, dynamic> json) {
    return SharedChatModel(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null
          ? SharedChatDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data != null ? (data as SharedChatDataModel).toJson() : null,
    };
  }
}

/// Shared chat data model
class SharedChatDataModel extends SharedChatData {
  const SharedChatDataModel({
    required super.additionalInput,
  });

  /// Create data model from JSON
  factory SharedChatDataModel.fromJson(Map<String, dynamic> json) {
    return SharedChatDataModel(
      additionalInput: json['additionalInput'] as List<dynamic>? ?? [],
    );
  }

  /// Convert data model to JSON
  Map<String, dynamic> toJson() {
    return {
      'additionalInput': additionalInput,
    };
  }
}
