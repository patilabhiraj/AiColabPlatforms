import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

/// CashfreeService — SDK चा Wrapper Class
///
/// 🧠 Wrapper pattern का वापरतो? (Interview answer)
/// - SDK directly BLoC/UI मध्ये ठेवला नाही
/// - जर उद्या Cashfree बदलून Razorpay वापरायचा झाला,
///   फक्त हा एकच file बदलावा लागेल — बाकी सगळा code तसाच राहतो
/// - Unit testing साठी हा class mock करता येतो
///
/// SDK v2.4.0+52 — CFWebCheckoutPayment वापरतो (current recommended approach)
/// CFDropCheckoutPayment deprecated झाला आहे.
class CashfreeService {
  // 🔑 Environment switch: SANDBOX = test mode, PRODUCTION = live पैसे
  // Production ला deploy करताना हे बदल!
  static final CFEnvironment _env = CFEnvironment.SANDBOX;

  /// Payment initiate करतो
  ///
  /// [orderId]          - Backend कडून आलेला unique Cashfree order ID
  /// [paymentSessionId] - Cashfree ने generate केलेला session ID (backend मार्गे)
  /// [onSuccess]        - Payment successful झाल्यावर, orderId मिळतो
  /// [onFailure]        - Payment failed/cancelled झाल्यावर, error info मिळतो
  Future<void> initiatePayment({
    required String orderId,
    required String paymentSessionId,
    required Function(Map<dynamic, dynamic>) onSuccess,
    required Function(Map<dynamic, dynamic>) onFailure,
  }) async {
    // ── Step 1: CFSession बनव ─────────────────────────────────────────────────
    // Session = "हे payment कोणत्या order साठी आहे" हे SDK ला सांगतो
    // CFSessionBuilder — SDK v2.4.0+ मधला correct builder
    final session = CFSessionBuilder()
        .setEnvironment(_env)
        .setOrderId(orderId)
        .setPaymentSessionId(paymentSessionId)
        .build();

    // ── Step 2: CFWebCheckoutPayment बनव ─────────────────────────────────────
    // WebCheckout = Cashfree चा full-featured payment page (WebView मध्ये उघडतो)
    // UPI, Cards, NetBanking, Wallets — सगळं automatically available असतं
    // हे CFDropCheckoutPayment चा replacement आहे (जो deprecated आहे)
    final payment = CFWebCheckoutPaymentBuilder()
        .setSession(session)
        .build();

    // ── Step 3: Callbacks register कर ────────────────────────────────────────
    // CFPaymentGatewayService() — Factory constructor (singleton pattern)
    // Note: .instance नाही — CFPaymentGatewayService() असं call करतो
    //
    // Callback signatures (exact SDK types):
    //   onVerify: Function(String orderId)     ← success
    //   onError:  Function(CFErrorResponse, String orderId)  ← failure
    CFPaymentGatewayService().setCallback(
      // ✅ Success callback — orderId string येतो
      (String verifiedOrderId) {
        onSuccess({'orderId': verifiedOrderId});
      },
      // ❌ Failure callback — CFErrorResponse + orderId येतो
      (CFErrorResponse errorResponse, String failedOrderId) {
        onFailure({
          'orderId': failedOrderId,
          'message': errorResponse.getMessage() ?? 'Payment failed. Please try again.',
          'code': errorResponse.getCode() ?? '',
          'type': errorResponse.getType() ?? '',
        });
      },
    );

    // ── Step 4: Payment launch कर ─────────────────────────────────────────────
    // WebView मध्ये Cashfree payment page उघडतो
    // User payment complete केल्यावर SDK automatically callbacks trigger करतो
    CFPaymentGatewayService().doPayment(payment);
  }
}
