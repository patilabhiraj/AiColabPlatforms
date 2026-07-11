import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/account_entity.dart';
import '../../domain/usecases/archived_chats_usecases.dart';

part 'archived_chats_event.dart';
part 'archived_chats_state.dart';

class ArchivedChatsBloc extends Bloc<ArchivedChatsEvent, ArchivedChatsState> {
  final GetArchivedChatsUseCase _getArchivedChatsUseCase;
  final UnarchiveChatUseCase _unarchiveChatUseCase;

  ArchivedChatsBloc(this._getArchivedChatsUseCase, this._unarchiveChatUseCase)
      : super(ArchivedChatsInitial()) {
    on<ArchivedChatsLoadRequested>(_onLoadRequested);
    on<ArchivedChatUnarchiveRequested>(_onUnarchiveRequested);
  }

  Future<void> _onLoadRequested(
    ArchivedChatsLoadRequested event,
    Emitter<ArchivedChatsState> emit,
  ) async {
    emit(ArchivedChatsLoading());
    final result = await _getArchivedChatsUseCase();
    result.fold(
      (failure) => emit(ArchivedChatsError(failure.message)),
      (paginated) => emit(ArchivedChatsLoaded(chats: paginated.items)),
    );
  }

  Future<void> _onUnarchiveRequested(
    ArchivedChatUnarchiveRequested event,
    Emitter<ArchivedChatsState> emit,
  ) async {
    final current = state;
    if (current is! ArchivedChatsLoaded) return;

    emit(current.copyWith(unarchivingId: event.chatId));
    final result = await _unarchiveChatUseCase(event.chatId);
    result.fold(
      (failure) => emit(current.copyWith(
        unarchivingId: null,
        error: failure.message,
      )),
      (_) => emit(current.copyWith(
        chats: current.chats.where((c) => c.id != event.chatId).toList(),
        unarchivingId: null,
        error: null,
      )),
    );
  }
}
