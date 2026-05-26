# Shared Chat API Integration

## Overview
Successfully integrated `/chats/shared/{shareId}` API endpoint following Clean Architecture principles.

## API Endpoint
```
GET /api/chats/shared/{shareId}
```

**Response Format:**
```json
{
  "status": true,
  "message": "success",
  "data": {
    "additionalInput": []
  }
}
```

## Architecture Layers

### 1. Domain Layer (`lib/features/chat/domain/`)

#### Entity
**File:** `entities/shared_chat.dart`
- `SharedChat` - Main entity representing shared chat response
- `SharedChatData` - Data entity containing additional input

#### Repository Interface
**File:** `repositories/chat_repository.dart`
```dart
Future<Either<Failure, SharedChat>> getSharedChat(String shareId);
```

#### UseCase
**File:** `usecases/get_shared_chat_usecase.dart`
```dart
class GetSharedChatUseCase {
  Future<Either<Failure, SharedChat>> call(String shareId);
}
```

### 2. Data Layer (`lib/features/chat/data/`)

#### Model
**File:** `models/shared_chat_model.dart`
- `SharedChatModel` - Data model with JSON serialization
- `SharedChatDataModel` - Data model for nested data
- Methods: `fromJson()`, `toJson()`

#### Data Source
**File:** `datasources/chat_remote_data_source.dart`
```dart
Future<SharedChatModel> getSharedChat(String shareId);
```

**Implementation:**
- Uses Dio HTTP client
- Endpoint: `${ApiConstants.sharedChat}/$shareId`
- Error handling with `ServerException`
- Returns `SharedChatModel` on success

#### Repository Implementation
**File:** `repositories/chat_repository_impl.dart`
```dart
Future<Either<Failure, SharedChat>> getSharedChat(String shareId) async {
  try {
    final sharedChat = await remoteDataSource.getSharedChat(shareId);
    return Right(sharedChat);
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  }
}
```

### 3. Dependency Injection

**File:** `lib/app/injection.dart`

Added:
```dart
// UseCase registration
sl.registerLazySingleton(() => GetSharedChatUseCase(sl()));

// Updated ChatRemoteDataSource with Dio injection
sl.registerLazySingleton<ChatRemoteDataSource>(
  () => ChatRemoteDataSourceImpl(sl<ApiClient>().dio),
);
```

## Usage Example

### In BLoC/Cubit:
```dart
class SharedChatBloc extends Bloc<SharedChatEvent, SharedChatState> {
  final GetSharedChatUseCase getSharedChatUseCase;

  SharedChatBloc(this.getSharedChatUseCase) : super(SharedChatInitial()) {
    on<FetchSharedChat>(_onFetchSharedChat);
  }

  Future<void> _onFetchSharedChat(
    FetchSharedChat event,
    Emitter<SharedChatState> emit,
  ) async {
    emit(SharedChatLoading());

    final result = await getSharedChatUseCase(event.shareId);

    result.fold(
      (failure) => emit(SharedChatError(failure.message)),
      (sharedChat) {
        if (sharedChat.status) {
          emit(SharedChatLoaded(sharedChat));
        } else {
          emit(SharedChatError(sharedChat.message));
        }
      },
    );
  }
}
```

### In Widget:
```dart
// Inject the use case
final getSharedChatUseCase = sl<GetSharedChatUseCase>();

// Call the API
final result = await getSharedChatUseCase('your-share-id');

result.fold(
  (failure) {
    // Handle error
    print('Error: ${failure.message}');
  },
  (sharedChat) {
    // Handle success
    if (sharedChat.status) {
      print('Success: ${sharedChat.message}');
      print('Additional Input: ${sharedChat.data?.additionalInput}');
    }
  },
);
```

## Error Handling

### Exception Types
- `ServerException` - Server-side errors (4xx, 5xx)
- `NetworkException` - Network connectivity issues
- `CacheException` - Local cache errors

### Failure Types
- `ServerFailure` - Mapped from ServerException
- Contains user-friendly error message

## API Constants

**File:** `lib/core/constants/api_constants.dart`
```dart
static const String sharedChat = '/api/chats/shared'; // append /{shareId}
```

## Testing

### Unit Test Example:
```dart
test('should return SharedChat when API call is successful', () async {
  // Arrange
  final shareId = 'test-share-id';
  final mockResponse = SharedChatModel(
    status: true,
    message: 'success',
    data: SharedChatDataModel(additionalInput: []),
  );
  
  when(mockRemoteDataSource.getSharedChat(shareId))
      .thenAnswer((_) async => mockResponse);

  // Act
  final result = await repository.getSharedChat(shareId);

  // Assert
  expect(result, Right(mockResponse));
  verify(mockRemoteDataSource.getSharedChat(shareId));
});
```

## Files Created/Modified

### Created:
1. `lib/features/chat/domain/entities/shared_chat.dart`
2. `lib/features/chat/data/models/shared_chat_model.dart`
3. `lib/features/chat/domain/usecases/get_shared_chat_usecase.dart`
4. `lib/core/errors/exceptions.dart`

### Modified:
1. `lib/features/chat/domain/repositories/chat_repository.dart`
2. `lib/features/chat/data/datasources/chat_remote_data_source.dart`
3. `lib/features/chat/data/repositories/chat_repository_impl.dart`
4. `lib/app/injection.dart`

## Benefits of Clean Architecture

✅ **Separation of Concerns** - Each layer has a single responsibility
✅ **Testability** - Easy to mock and test each layer independently
✅ **Maintainability** - Changes in one layer don't affect others
✅ **Scalability** - Easy to add new features following the same pattern
✅ **Dependency Rule** - Dependencies point inward (Domain ← Data ← Presentation)

## Next Steps

1. Create BLoC/Cubit for shared chat feature
2. Create UI page to display shared chat
3. Add route for `/shared/:shareId`
4. Implement error handling UI
5. Add loading states
6. Write unit tests for all layers
