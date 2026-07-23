# 💳 Cashfree Payment Integration — Complete Guide

> **Project**: CoLab Platforms AI Flutter App  
> **SDK**: `flutter_cashfree_pg_sdk: ^2.4.0+52`  
> **Architecture**: Clean Architecture (Data → Domain → Presentation)  
> **Date**: July 2026

---

## 📋 Table of Contents

1. [Cashfree म्हणजे काय?](#cashfree-म्हणजे-काय)
2. [Flow कसा काम करतो?](#flow-कसा-काम-करतो)
3. [Step-by-Step Process](#step-by-step-process)
4. [Kay Kay Use Kela (Tools & Technologies)](#kay-kay-use-kela)
5. [Kay Kay Code Kela (Files Created/Modified)](#kay-kay-code-kela)
6. [Challenges & Solutions](#challenges--solutions)
7. [Without AI — Next Time kasa karu?](#without-ai--next-time-kasa-karu)
8. [Interview मध्ये कसं Explain करायचं?](#interview-मध्ये-कसं-explain-करायचं)
9. [Quick Reference Cheatsheet](#quick-reference-cheatsheet)

---

## Cashfree म्हणजे काय?

Cashfree एक Indian **Payment Gateway** आहे.

- Users तुझ्या app मधून **UPI, Credit/Debit Card, NetBanking, Wallet** ने पैसे pay करू शकतात
- Cashfree Flutter SDK एक **Native Payment Sheet** उघडतो
- तुला payment UI manually बनवायची गरज नाही — SDK सगळं handle करतो
- Cashfree **Sandbox (Test) Mode** देतो जेणेकरून real पैसे न वापरता test करता येतं

---

## Flow कसा काम करतो?

```
👤 User → "Subscribe" Button tap करतो
         ↓
📱 Flutter App (Client Side)
   BLoC → CreateSubscriptionUseCase → DataSource → HTTP POST
         ↓
🖥️ तुझा Backend Server
   /api/payments/subscribe-one-time/create
   Backend → Cashfree API (SECRET KEY वापरून) → Order Create करतो
         ↓
📦 Cashfree Response
   { orderId: "order_xxx", paymentSessionId: "session_yyy" }
         ↓
📱 Flutter App (Client Side) — paymentSessionId मिळाला
   CashfreeService.initiatePayment() → SDK Payment Sheet उघडतो
         ↓
💳 User Payment करतो (UPI / Card / Wallet)
         ↓
✅ SDK Callback येतो
   onSuccess(orderId) → BLoC → PaymentSuccess State → SnackBar
   onFailure(error)   → BLoC → PaymentFailure State → Error SnackBar
         ↓
🔔 Backend Webhook (Server-to-Server) — Cashfree → Backend ला notify करतो
   Backend → User ला plan activate करतो
```

### Security Rule (महत्त्वाचं!)
> ❌ **Cashfree Secret Key कधीही Flutter app मध्ये ठेवू नका!**  
> ✅ **Secret Key फक्त Backend Server वर असावी.**  
> Flutter app फक्त `paymentSessionId` वापरतो — हा short-lived असतो.

---

## Step-by-Step Process

### Step 1: pubspec.yaml — Package Add

```yaml
dependencies:
  flutter_cashfree_pg_sdk: ^2.4.0+52
```

```bash
flutter pub get
```

**का?** Official Cashfree Flutter SDK — payment UI, UPI redirect, callbacks सगळं handle करतो.

---

### Step 2: iOS Info.plist — URL Schemes

`ios/Runner/Info.plist` मध्ये add करा:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>phonepe</string>
  <string>tez</string>
  <string>paytmmp</string>
  <string>bhim</string>
  <string>amazonpay</string>
  <string>credpay</string>
</array>
```

**का?** iOS ला सांगावं लागतं की "माझी app या UPI apps ला open करू शकते". नाही केलं तर Google Pay, PhonePe काम करणार नाहीत.

---

### Step 3: API Constant Add

`lib/core/constants/api_constants.dart` मध्ये:

```dart
static const String subscriptionCreate =
    '/api/payments/subscribe-one-time/create';
```

**का?** Magic strings (hardcoded URLs) avoid करतो. एकाच जागी URL असल्यावर change सोपं होतं — DRY Principle.

---

### Step 4: DataSource — HTTP Call

`settings_remote_data_source.dart` मध्ये:

```dart
// Abstract class मध्ये signature:
Future<Map<String, dynamic>> createSubscription(int planId);

// Implementation:
Future<Map<String, dynamic>> createSubscription(int planId) async {
  final response = await dio.post(
    ApiConstants.subscriptionCreate,
    data: {'planId': planId},
  );
  return (response.data['data'] as Map<String, dynamic>?) ?? {};
}
```

**का?** DataSource layer फक्त HTTP calls करतो. Single Responsibility Principle.

---

### Step 5: Repository Interface + Implementation

`settings_repository.dart` (Domain — Abstract):
```dart
Future<Either<Failure, Map<String, dynamic>>> createSubscription(int planId);
```

`settings_repository_impl.dart` (Data — Implementation):
```dart
Future<Either<Failure, Map<String, dynamic>>> createSubscription(int planId) async {
  try {
    final data = await remoteDataSource.createSubscription(planId);
    return Right(data);
  } catch (e) {
    return _handleError(e);
  }
}
```

**का?** Repository pattern — Domain layer ला माहित नाही data कुठून येतो. Abstract interface असल्यामुळे testing easy होतं.

---

### Step 6: UseCase

`subscription_usecases.dart` मध्ये:

```dart
class CreateSubscriptionUseCase {
  final SettingsRepository repository;
  CreateSubscriptionUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(int planId) {
    return repository.createSubscription(planId);
  }
}
```

**का?** UseCase = एक specific business action. BLoC → UseCase → Repository. Single Responsibility Principle.

---

### Step 7: CashfreeService (SDK Wrapper) — Core File

`lib/features/settings/cashfree_service.dart`:

```dart
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';

class CashfreeService {
  static final CFEnvironment _env = CFEnvironment.SANDBOX; // PRODUCTION for live

  Future<void> initiatePayment({
    required String orderId,
    required String paymentSessionId,
    required Function(Map<dynamic, dynamic>) onSuccess,
    required Function(Map<dynamic, dynamic>) onFailure,
  }) async {
    // Step 1: Session बनव
    final session = CFSessionBuilder()
        .setEnvironment(_env)
        .setOrderId(orderId)
        .setPaymentSessionId(paymentSessionId)
        .build();

    // Step 2: Payment object बनव
    final payment = CFWebCheckoutPaymentBuilder()
        .setSession(session)
        .build();

    // Step 3: Callbacks register कर
    CFPaymentGatewayService().setCallback(
      (String verifiedOrderId) {
        onSuccess({'orderId': verifiedOrderId});
      },
      (CFErrorResponse errorResponse, String failedOrderId) {
        onFailure({
          'orderId': failedOrderId,
          'message': errorResponse.getMessage() ?? 'Payment failed',
        });
      },
    );

    // Step 4: Payment launch कर
    CFPaymentGatewayService().doPayment(payment);
  }
}
```

**का?** SDK directly BLoC मध्ये वापरत नाही. Wrapper pattern — SDK बदलला तर फक्त हा file बदलावा.

---

### Step 8: BLoC Events, States, Bloc

**Events:**
```dart
class SubscriptionPurchaseRequested extends SubscriptionEvent {
  final int planId;
  SubscriptionPurchaseRequested(this.planId);
}
class SubscriptionPaymentSuccess extends SubscriptionEvent {
  final Map<dynamic, dynamic> orderData;
  SubscriptionPaymentSuccess(this.orderData);
}
class SubscriptionPaymentFailure extends SubscriptionEvent {
  final Map<dynamic, dynamic> orderData;
  SubscriptionPaymentFailure(this.orderData);
}
```

**States:**
```dart
class PaymentSuccess extends SubscriptionState {
  final String orderId;
  PaymentSuccess(this.orderId);
}
class PaymentFailure extends SubscriptionState {
  final String message;
  PaymentFailure(this.message);
}
```

**BLoC handler:**
```dart
Future<void> _onPurchaseRequested(
  SubscriptionPurchaseRequested event,
  Emitter<SubscriptionState> emit,
) async {
  // 1. Loading state
  emit(current.copyWith(paymentInitiating: true));

  // 2. Backend ला call करा → orderId + sessionId मिळव
  final result = await _createSubscriptionUseCase(event.planId);

  result.fold(
    (failure) => emit(PaymentFailure(failure.message)),
    (data) async {
      final orderId = data['orderId']?.toString() ?? '';
      final sessionId = data['paymentSessionId']?.toString() ?? '';

      // 3. SDK launch करा
      await _cashfreeService.initiatePayment(
        orderId: orderId,
        paymentSessionId: sessionId,
        onSuccess: (orderData) => add(SubscriptionPaymentSuccess(orderData)),
        onFailure: (orderData) => add(SubscriptionPaymentFailure(orderData)),
      );
    },
  );
}
```

---

### Step 9: DI Registration

`injection.dart` मध्ये:

```dart
sl.registerLazySingleton(() => CreateSubscriptionUseCase(sl()));
sl.registerLazySingleton(() => CashfreeService());

// BLoC ला 5 dependencies
sl.registerFactory(() => SubscriptionBloc(sl(), sl(), sl(), sl(), sl()));
```

**`LazySingleton` vs `Factory`:**
- `LazySingleton` → एकदाच बनतो, पुढे तोच वापरतो (Service, Repository साठी)
- `Factory` → प्रत्येकवेळी नवा instance बनतो (BLoC साठी — state conflict टाळायला)

---

### Step 10: UI Update

`subscription_page.dart` मध्ये:

```dart
// Button:
ElevatedButton(
  onPressed: isPurchasing ? null : () {
    context.read<SubscriptionBloc>().add(
      SubscriptionPurchaseRequested(plan.id),
    );
  },
  child: isPurchasing
      ? CircularProgressIndicator(color: Colors.white)
      : Text('Subscribe with Cashfree'),
)

// BlocConsumer listener:
if (state is PaymentSuccess) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('🎉 Payment Successful! Order: ${state.orderId}')),
  );
}
if (state is PaymentFailure) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('❌ ${state.message}')),
  );
}
```

---

## Kay Kay Use Kela

| Technology | Purpose |
|-----------|---------|
| `flutter_cashfree_pg_sdk ^2.4.0+52` | Official Cashfree Flutter SDK |
| `dio` | HTTP calls (backend API) |
| `flutter_bloc` | State management |
| `get_it` | Dependency Injection |
| `dartz` | Either (Left = Error, Right = Success) |
| `CFSessionBuilder` | Cashfree session तयार करतो |
| `CFWebCheckoutPaymentBuilder` | Payment object बनवतो |
| `CFPaymentGatewayService()` | Payment launch + callbacks |
| `CFErrorResponse` | SDK error response class |
| `CFEnvironment.SANDBOX` | Test mode |

---

## Kay Kay Code Kela

### 🆕 New Files Created

| File | Purpose |
|------|---------|
| `lib/features/settings/cashfree_service.dart` | SDK Wrapper — Core payment class |

### ✏️ Modified Files

| File | काय बदललं |
|------|----------|
| `pubspec.yaml` | SDK package add केला |
| `ios/Runner/Info.plist` | UPI URL schemes whitelist |
| `lib/core/constants/api_constants.dart` | `subscriptionCreate` endpoint |
| `lib/features/settings/data/datasources/settings_remote_data_source.dart` | `createSubscription()` method |
| `lib/features/settings/data/repositories/settings_repository_impl.dart` | `createSubscription()` impl |
| `lib/features/settings/domain/repositories/settings_repository.dart` | Abstract signature |
| `lib/features/settings/domain/usecases/subscription_usecases.dart` | `CreateSubscriptionUseCase` |
| `lib/features/settings/bloc/subscription/subscription_event.dart` | 3 नवीन events |
| `lib/features/settings/bloc/subscription/subscription_state.dart` | 3 नवीन states |
| `lib/features/settings/bloc/subscription/subscription_bloc.dart` | Payment flow handlers |
| `lib/app/injection.dart` | DI registrations |
| `lib/features/settings/presentation/pages/subscription_page.dart` | UI — Subscribe button |

---

## Challenges & Solutions

### Challenge 1: Wrong Package Import Name
**Problem:**
```dart
import 'package:cashfree_pg/cashfree_pg.dart'; // ❌ Package exists नाही!
```
**Solution:**
```dart
// SDK file structure बघून exact imports लिहिले:
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
// etc.
```
**Lesson:** Package name आणि import path वेगळे असू शकतात. `pubspec.yaml` मध्ये package name आणि actual import path pub cache मध्ये बघा.

---

### Challenge 2: SDK Deprecated API (Breaking Change)
**Problem:** `CFDropCheckoutPayment` deprecated झाला होता. Old docs / tutorials चुकीचे होते.
```dart
CFDropCheckoutPayment.builder()   // ❌ Deprecated
CFSession.builder()               // ❌ Old API
CFPaymentGatewayService.instance  // ❌ instance नाही
```
**Solution:** SDK source code pub cache मधून direct वाचलं!
```
C:\Users\<user>\AppData\Local\Pub\Cache\hosted\pub.dev\flutter_cashfree_pg_sdk-2.4.0+52\lib\
```
Correct API:
```dart
CFWebCheckoutPaymentBuilder()     // ✅ Current
CFSessionBuilder()                // ✅ Current
CFPaymentGatewayService()         // ✅ Factory constructor
```
**Lesson:** SDK update होतात — always source code वाचा, documentation outdated असू शकते.

---

### Challenge 3: `static const` vs `static final`
**Problem:**
```dart
static const _env = CFEnvironment.SANDBOX; // ❌ Error: not a constant
```
**Solution:**
```dart
static final CFEnvironment _env = CFEnvironment.SANDBOX; // ✅
```
**Lesson:** `const` = compile-time constant (only primitives/literals). `final` = runtime initialization.

---

### Challenge 4: Null-aware Map Syntax (Dart 3.x)
**Problem:**
```dart
?'phoneNumber': phoneNumber,  // ❌ Key ला ? — KEY never null असतो
```
**Solution:**
```dart
'phoneNumber': ?phoneNumber,  // ✅ Value ला ? — null असेल तर entry skip
```
**Lesson:** Dart 3.x मध्ये `'key': ?nullableValue` — value null असेल तर map entry येत नाही.

---

### Challenge 5: SDK Callback Signatures
**Problem:** Generic `Function(Map)` callbacks SDK च्या actual signatures शी match नव्हत्या.

**Solution:** SDK source code मधून exact signatures वाचल्या:
```dart
// Correct signatures:
setCallback(
  void Function(String orderId) onVerify,          // Success
  void Function(CFErrorResponse, String) onError,  // Failure
)
```

---

## Without AI — Next Time kasa karu?

### 🗺️ Roadmap (Follow this order!)

```
Step 1: pub.dev वर package शोधा
   → https://pub.dev/packages/flutter_cashfree_pg_sdk

Step 2: pubspec.yaml मध्ये add करा + flutter pub get

Step 3: iOS Info.plist configure करा (UPI schemes)

Step 4: Clean Architecture layers बनवा (Bottom to Top)
   Data Layer:
     a. DataSource मध्ये HTTP method लिहा
     b. Repository impl मध्ये implement करा
   Domain Layer:
     c. Repository abstract मध्ये signature लिहा
     d. UseCase बनवा
   Presentation Layer:
     e. BLoC Events, States लिहा
     f. BLoC handlers लिहा
     g. UI update करा

Step 5: CashfreeService (SDK Wrapper) बनवा
   → SDK pub cache मधून source code वाचा
   → Exact class names आणि method signatures confirm करा

Step 6: DI (GetIt) मध्ये register करा

Step 7: flutter analyze करा — errors fix करा

Step 8: Sandbox mode मध्ये test करा
```

### 📁 SDK Source Code Location (Windows)
```
C:\Users\<YourUsername>\AppData\Local\Pub\Cache\hosted\pub.dev\
flutter_cashfree_pg_sdk-<version>\lib\
```

### 🔍 SDK मध्ये काय बघायचं?
```
api/cfsession/cfsession.dart          → CFSessionBuilder
api/cfpayment/cfwebcheckoutpayment.dart → CFWebCheckoutPaymentBuilder
api/cfpaymentgateway/cfpaymentgatewayservice.dart → CFPaymentGatewayService
utils/cfenums.dart                    → CFEnvironment, CFPaymentModes
api/cferrorresponse/cferrorresponse.dart → CFErrorResponse
```

### ✅ Quick Code Template (Copy-paste करा)
```dart
// 1. Session
final session = CFSessionBuilder()
    .setEnvironment(CFEnvironment.SANDBOX) // or PRODUCTION
    .setOrderId(orderId)
    .setPaymentSessionId(paymentSessionId)
    .build();

// 2. Payment
final payment = CFWebCheckoutPaymentBuilder()
    .setSession(session)
    .build();

// 3. Callbacks
CFPaymentGatewayService().setCallback(
  (String orderId) { /* success */ },
  (CFErrorResponse err, String orderId) { /* failure */ },
);

// 4. Launch
CFPaymentGatewayService().doPayment(payment);
```

---

## Interview मध्ये कसं Explain करायचं?

### Q1: "Payment integration कसं केलं?"

**Answer Structure (STAR method):**

> "आमच्या app मध्ये Subscription Plans साठी **Cashfree payment gateway** integrate केलं.  
> आम्ही **Clean Architecture** follow केली — Data, Domain, आणि Presentation असे 3 layers.  
>
> **Flow असा आहे:**
> 1. User plan निवडतो → BLoC ला event जातो
> 2. BLoC → UseCase → Repository → DataSource → Backend API call होतो
> 3. Backend Cashfree ला call करतो (Secret Key वापरून) → `orderId + paymentSessionId` मिळतो
> 4. Flutter app हा `paymentSessionId` Cashfree SDK ला देतो
> 5. SDK native WebView payment page उघडतो — UPI, Cards, Wallets सगळं automatically
> 6. User pays → SDK callback → BLoC state update → UI SnackBar दाखवतो"

---

### Q2: "Secret Key app मध्ये का ठेवत नाही?"

> "Cashfree Secret Key Flutter app मध्ये ठेवणं **security risk** आहे. APK/IPA reverse engineer करून key चोरता येते.  
> म्हणून **Order creation नेहमी Backend वर** होतं — Secret Key फक्त server वर असते.  
> Flutter app फक्त `paymentSessionId` वापरतो जो **short-lived** आणि single-use असतो."

---

### Q3: "Clean Architecture का वापरला?"

> "Clean Architecture मध्ये **3 layers** असतात:
> - **Data Layer**: HTTP calls, JSON parsing (framework dependent)
> - **Domain Layer**: Business logic, UseCases, Entities (framework independent)
> - **Presentation**: UI, BLoC (user interaction)
>
> **Benefit**: SDK बदलायचा असला (Cashfree → Razorpay) तर फक्त Data Layer बदलतो.  
> Domain आणि Presentation तसेच राहतात. **Unit testing** सोपं होतं."

---

### Q4: "BLoC मध्ये payment का handle केलं?"

> "Payment एक complex async flow आहे — loading, success, failure, network error.  
> **BLoC reactive state management** देतो.  
> - UI → Event पाठवतो  
> - BLoC process करतो → State emit करतो  
> - UI reactively update होतो  
>
> एक important pattern: SDK callbacks async असतात, त्यामुळे `add()` वापरलं (Emitter directly नाही).  
> `add()` → नवा Event queue मध्ये जातो → BLoC process करतो — हे thread-safe आहे."

---

### Q5: "Sandbox आणि Production मध्ये फरक काय?"

> "Sandbox = Test Mode — real पैसे नाहीत.  
> Test UPI: `testsuccess@gocash` → success येतो  
> Test UPI: `testfailure@gocash` → failure येतो  
>
> Production → `CFEnvironment.PRODUCTION` — real payments.  
> आम्ही development मध्ये Sandbox वापरलं, deployment आधी PRODUCTION ला switch करतो."

---

### Q6: "DI (Dependency Injection) मध्ये `LazySingleton` vs `Factory` काय फरक?"

> - `registerLazySingleton` → एकदाच object बनतो, पुढे तोच वापरतो.  
>   **Repository, Service, UseCase** साठी — कारण state नसतो.
> - `registerFactory` → **प्रत्येकवेळी नवा** object बनतो.  
>   **BLoC** साठी — कारण BLoC मध्ये state असतो. जुना BLoC dispose व्हायला हवा."

---

## Quick Reference Cheatsheet

### SDK Classes (v2.4.0+52)
| Class | Purpose |
|-------|---------|
| `CFSessionBuilder()` | Session बनवतो |
| `CFWebCheckoutPaymentBuilder()` | Payment object (recommended) |
| `CFPaymentGatewayService()` | SDK entry point (factory) |
| `CFEnvironment.SANDBOX` | Test mode |
| `CFEnvironment.PRODUCTION` | Live mode |
| `CFErrorResponse` | Error details |

### Test Credentials (Sandbox)
| Method | Value | Result |
|--------|-------|--------|
| UPI | `testsuccess@gocash` | ✅ Success |
| UPI | `testfailure@gocash` | ❌ Failure |
| Card | `4111 1111 1111 1111` | ✅ Success |
| Card CVV | Any 3 digits | - |
| Card Expiry | Any future date | - |

### Production Switch
```dart
// cashfree_service.dart मध्ये फक्त हे बदल:
static final CFEnvironment _env = CFEnvironment.PRODUCTION;
```

### Important URLs
- Cashfree Docs: https://docs.cashfree.com/docs/flutter-integration
- pub.dev: https://pub.dev/packages/flutter_cashfree_pg_sdk
- GitHub SDK: https://github.com/cashfree/flutter-cashfree-pg-sdk

---

*Document Created: July 2026 | CoLab Platforms AI Project*
