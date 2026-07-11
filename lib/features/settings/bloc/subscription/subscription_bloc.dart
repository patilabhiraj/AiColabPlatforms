import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/subscription_usecases.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetCurrentSubscriptionUseCase _getCurrentSubscriptionUseCase;
  final GetPlansUseCase _getPlansUseCase;
  final CancelSubscriptionUseCase _cancelSubscriptionUseCase;

  SubscriptionBloc(
    this._getCurrentSubscriptionUseCase,
    this._getPlansUseCase,
    this._cancelSubscriptionUseCase,
  ) : super(SubscriptionInitial()) {
    on<SubscriptionLoadRequested>(_onLoadRequested);
    on<SubscriptionCancelRequested>(_onCancelRequested);
  }

  Future<void> _onLoadRequested(
    SubscriptionLoadRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(SubscriptionLoading());
    final summaryResult = await _getCurrentSubscriptionUseCase();
    final plansResult = await _getPlansUseCase();

    String? errorMessage;
    SubscriptionSummaryEntity? summary;
    List<PlanEntity> plans = const [];

    summaryResult.fold(
      (failure) => errorMessage = failure.message,
      (value) => summary = value,
    );
    plansResult.fold(
      (failure) => errorMessage ??= failure.message,
      (value) => plans = value,
    );

    if (summary == null && errorMessage != null) {
      emit(SubscriptionError(errorMessage!));
      return;
    }

    emit(SubscriptionLoaded(
      summary: summary ??
          const SubscriptionSummaryEntity(
            subscription: null,
            freePlanTaken: false,
          ),
      plans: plans,
    ));
  }

  Future<void> _onCancelRequested(
    SubscriptionCancelRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    final current = state;
    if (current is! SubscriptionLoaded) return;

    emit(current.copyWith(cancelling: true));
    final result = await _cancelSubscriptionUseCase();
    result.fold(
      (failure) => emit(current.copyWith(
        cancelling: false,
        cancelError: failure.message,
      )),
      (_) => add(SubscriptionLoadRequested()),
    );
  }
}
