import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cashfree_service.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/subscription_usecases.dart';

part 'subscription_event.dart';
part 'subscription_state.dart';

/// SubscriptionBloc — Subscription + Payment flow manage करतो
///
/// 🧠 BLoC म्हणजे काय?
/// Business Logic Component — UI आणि Business Logic वेगळे ठेवतो
/// UI → Event पाठवतो → BLoC process करतो → State emit करतो → UI update होतो
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetCurrentSubscriptionUseCase _getCurrentSubscriptionUseCase;
  final GetPlansUseCase _getPlansUseCase;
  final CancelSubscriptionUseCase _cancelSubscriptionUseCase;
  final CreateSubscriptionUseCase _createSubscriptionUseCase; // नवीन
  final CashfreeService _cashfreeService; // नवीन

  SubscriptionBloc(
    this._getCurrentSubscriptionUseCase,
    this._getPlansUseCase,
    this._cancelSubscriptionUseCase,
    this._createSubscriptionUseCase,
    this._cashfreeService,
  ) : super(SubscriptionInitial()) {
    on<SubscriptionLoadRequested>(_onLoadRequested);
    on<SubscriptionCancelRequested>(_onCancelRequested);
    on<SubscriptionPurchaseRequested>(_onPurchaseRequested); // नवीन
    on<SubscriptionPaymentSuccess>(_onPaymentSuccess); // नवीन
    on<SubscriptionPaymentFailure>(_onPaymentFailure); // नवीन
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

  /// 🎯 Payment Flow — सगळ्यात important handler
  ///
  /// Step 1: Loading state दाखव
  /// Step 2: Backend ला planId पाठव → orderId + sessionId मिळव
  /// Step 3: CashfreeService ने payment sheet launch कर
  /// Step 4: SDK callback येतो → success/failure event add करतो
  Future<void> _onPurchaseRequested(
    SubscriptionPurchaseRequested event,
    Emitter<SubscriptionState> emit,
  ) async {
    final current = state;
    if (current is! SubscriptionLoaded) return;

    // UI ला दाखव: "हा plan process होतोय"
    emit(current.copyWith(
      paymentInitiating: true,
      purchasingPlanId: event.planId,
    ));

    // Backend ला call कर → Cashfree order create होतो
    final result = await _createSubscriptionUseCase(event.planId);

    result.fold(
      // ❌ Backend call fail झाला
      (failure) => emit(PaymentFailure(failure.message)),

      // ✅ orderId + sessionId मिळाले — SDK launch कर
      (data) async {
        final orderId = data['orderId']?.toString() ?? '';
        final sessionId = data['paymentSessionId']?.toString() ?? '';

        if (orderId.isEmpty || sessionId.isEmpty) {
          emit(PaymentFailure('Invalid payment session received.'));
          return;
        }

        // SDK ला payment sheet उघडायला सांग
        // emit नाही करत कारण SDK async callback देतो
        await _cashfreeService.initiatePayment(
          orderId: orderId,
          paymentSessionId: sessionId,
          onSuccess: (orderData) {
            // SDK callback → BLoC ला नवा event पाठव
            // 🧠 का add()? कारण Emitter<S> async callback मध्ये directly emit करत नाही
            add(SubscriptionPaymentSuccess(orderData));
          },
          onFailure: (orderData) {
            add(SubscriptionPaymentFailure(orderData));
          },
        );
      },
    );
  }

  void _onPaymentSuccess(
    SubscriptionPaymentSuccess event,
    Emitter<SubscriptionState> emit,
  ) {
    final orderId = event.orderData['orderId']?.toString() ?? 'unknown';
    emit(PaymentSuccess(orderId));
    // Fresh subscription data reload कर
    add(SubscriptionLoadRequested());
  }

  void _onPaymentFailure(
    SubscriptionPaymentFailure event,
    Emitter<SubscriptionState> emit,
  ) {
    final msg = event.orderData['message']?.toString() ?? 'Payment failed.';
    emit(PaymentFailure(msg));
  }
}
