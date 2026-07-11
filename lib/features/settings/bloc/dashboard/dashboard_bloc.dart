import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummaryUseCase _getDashboardSummaryUseCase;

  DashboardBloc(this._getDashboardSummaryUseCase) : super(DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    final result = await _getDashboardSummaryUseCase();
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (summary) => emit(DashboardLoaded(summary)),
    );
  }
}
