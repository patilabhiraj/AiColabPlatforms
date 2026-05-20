import '../models/chat_conversation_model.dart';
import '../models/chat_message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ChatConversationModel>> getConversations();
  Future<List<ChatMessageModel>> getMessages(String conversationId);
  Future<ChatMessageModel> sendMessage(String conversationId, String content);
  Future<ChatConversationModel> createConversation(String firstMessage);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  // TODO: inject ApiClient here when integrating the real API
  // final ApiClient apiClient;
  // ChatRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ChatConversationModel>> getConversations() async {
    // TODO: GET /api/chats
    await Future.delayed(const Duration(milliseconds: 400));
    return _stubConversations;
  }

  @override
  Future<List<ChatMessageModel>> getMessages(String conversationId) async {
    // TODO: GET /api/chats/{conversationId}/messages
    await Future.delayed(const Duration(milliseconds: 300));
    return _stubMessages[conversationId] ?? [];
  }

  @override
  Future<ChatMessageModel> sendMessage(String conversationId, String content) async {
    // TODO: POST /api/chats/{conversationId}/messages  {content}
    await Future.delayed(const Duration(milliseconds: 1200));
    return ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: 'This is a stub response. Real AI integration coming soon.',
      isUser: false,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<ChatConversationModel> createConversation(String firstMessage) async {
    // TODO: POST /api/chats  {title}
    await Future.delayed(const Duration(milliseconds: 300));
    final title = firstMessage.length > 40
        ? '${firstMessage.substring(0, 40)}...'
        : firstMessage;
    return ChatConversationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      lastMessage: firstMessage,
      updatedAt: DateTime.now(),
    );
  }

  // ── Stub data (remove once API is integrated) ─────────────────────────────

  static final _stubConversations = [
    ChatConversationModel(
      id: 'c1',
      title: 'Flutter BLoC pattern',
      lastMessage: 'Can you show me an example?',
      updatedAt: DateTime.now().subtract(const Duration(minutes: 3)),
    ),
    ChatConversationModel(
      id: 'c2',
      title: 'AI concepts explained',
      lastMessage: 'What is a transformer model?',
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ChatConversationModel(
      id: 'c3',
      title: 'Clean architecture guide',
      lastMessage: 'Explain the repository pattern',
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  static final _stubMessages = <String, List<ChatMessageModel>>{
    'c1': [
      ChatMessageModel(
        id: 'm1',
        content: 'How do I use BLoC pattern in Flutter?',
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
      ChatMessageModel(
        id: 'm2',
        content:
            'BLoC (Business Logic Component) separates UI from business logic using Events and States.\n\nYou define:\n• **Events** — things that happen (button taps, data loads)\n• **States** — what the UI renders\n• **Bloc** — maps events → states',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessageModel(
        id: 'm3',
        content: 'Can you show me an example?',
        isUser: true,
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessageModel(
        id: 'm4',
        content:
            'Here\'s a simple counter BLoC:\n\n```dart\nclass CounterBloc extends Bloc<CounterEvent, int> {\n  CounterBloc() : super(0) {\n    on<Increment>((e, emit) => emit(state + 1));\n    on<Decrement>((e, emit) => emit(state - 1));\n  }\n}```',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ],
  };
}
