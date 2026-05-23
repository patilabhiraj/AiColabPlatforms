import 'package:equatable/equatable.dart';

/// Shared chat entity - represents a publicly shared chat conversation
class SharedChat extends Equatable {
  final bool status;
  final String message;
  final SharedChatData? data;

  const SharedChat({
    required this.status,
    required this.message,
    this.data,
  });

  @override
  List<Object?> get props => [status, message, data];
}

/// Shared chat data containing conversation details
class SharedChatData extends Equatable {
  final List<dynamic> additionalInput; // Can be empty or contain additional metadata

  const SharedChatData({
    required this.additionalInput,
  });

  @override
  List<Object?> get props => [additionalInput];
}
