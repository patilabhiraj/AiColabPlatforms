import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/usage_log_entity.dart';
import '../../domain/usecases/get_usage_logs_usecase.dart';

part 'usage_event.dart';
part 'usage_state.dart';

class UsageBloc extends Bloc<UsageEvent, UsageState> {
  final GetUsageLogsUseCase _getUsageLogsUseCase;

  static const int _pageSize = 10;
  String _userId = '';

  UsageBloc(this._getUsageLogsUseCase) : super(UsageInitial()) {
    on<UsageLoadRequested>(_onLoadRequested);
    on<UsagePageRequested>(_onPageRequested);
  }

  Future<void> _onLoadRequested(
    UsageLoadRequested event,
    Emitter<UsageState> emit,
  ) async {
    _userId = event.userId;
    emit(UsageLoading());
    await _fetchPage(1, emit);
  }

  Future<void> _onPageRequested(
    UsagePageRequested event,
    Emitter<UsageState> emit,
  ) async {
    final current = state;
    if (current is UsageLoaded) {
      emit(current.copyWith(loading: true));
    }
    await _fetchPage(event.page, emit);
  }

  Future<void> _fetchPage(int page, Emitter<UsageState> emit) async {
    final result = await _getUsageLogsUseCase(
      page: page,
      pageSize: _pageSize,
      userId: _userId,
    );
    result.fold(
      (failure) => emit(UsageError(failure.message)),
      (paginated) => emit(UsageLoaded(
        logs: paginated.items,
        page: page,
        totalPages: paginated.totalPages,
        totalRecords: paginated.totalRecords,
      )),
    );
  }
}
