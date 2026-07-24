abstract final class ApiConstants {
  static const String baseUrl = 'https://98fb9zw4-5000.inc1.devtunnels.ms';
  // static const String baseUrl =
  //     'https://ai-colab-chat-manan-backend.onrender.com';

  // ── Auth ─────────────────────────────────────────────────────────────────────
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  // Native Google Sign-In: the app obtains a Google ID token via the
  // google_sign_in SDK and POSTs it here → backend returns { user, token,
  // isNewUser }. Handles both account creation and login.
  static const String googleMobile = '/api/auth/google/mobile';
  static const String verifyEmailOtp = '/api/auth/verify-email-otp';
  static const String resendEmailOtp = '/api/auth/resend-email-otp';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  // ── Chats ─────────────────────────────────────────────────────────────────────
  static const String chats = '/api/chats'; // GET list, POST create
  static String chatById(String id) =>
      '/api/chats/$id'; // GET (incl. messages), PUT, DELETE
  static String chatSend(String id) =>
      '/api/chats/$id/send'; // POST stream response
  static String chatContexts(String id) =>
      '/api/chats/$id/contexts'; // GET, PUT
  static String chatArchive(String id) =>
      '/api/chats/$id/archive'; // PATCH toggle
  static String chatPin(String id) => '/api/chats/$id/pin'; // PATCH toggle
  static String chatShare(String id) => '/api/chats/$id/share'; // PATCH toggle
  static String chatContinue(String id) =>
      '/api/chats/$id/continue'; // POST stream continue
  static String chatPrepareMulti(String id) =>
      '/api/chats/$id/prepare-multi'; // POST

  // ── Chat Messages ─────────────────────────────────────────────────────────────
  static const String messageEnhance =
      '/api/messages/enhance'; // POST { prompt } → { enhancedPrompt }
  static String messageRegenerate(String chatId, String messageId) =>
      '/api/chats/$chatId/messages/$messageId/regenerate'; // POST stream
  static String messageEdit(String chatId, String messageId) =>
      '/api/chats/$chatId/messages/$messageId/edit'; // POST stream
  static String messageEditPrepareMulti(String chatId, String messageId) =>
      '/api/chats/$chatId/messages/$messageId/edit-prepare-multi'; // POST

  // ── Chat Feedback ─────────────────────────────────────────────────────────────
  static String responseFeedback(String chatId, String responseId) =>
      '/api/chats/$chatId/responses/$responseId/feedback'; // POST

  // ── Shared Chat ───────────────────────────────────────────────────────────────
  static const String sharedChat = '/api/chats/shared'; // append /{shareId}

  // ── User Contexts ─────────────────────────────────────────────────────────────
  static const String contexts = '/api/contexts'; // GET list, POST create
  static const String contextsSidebar =
      '/api/contexts/sidebar'; // GET sidebar contexts
  static String contextById(String id) =>
      '/api/contexts/$id'; // GET, PUT, DELETE

  // ── Models & Assistants ───────────────────────────────────────────────────────
  static const String models = '/api/models'; // GET list (public)
  static const String assistants = '/api/assistants'; // GET list (auth)
  static String assistantById(String id) => '/api/assistants/$id'; // GET

  // ── Attachments ───────────────────────────────────────────────────────────────
  static const String downloadAttachment =
      '/api/attachments'; // append /{id}/download

  // ── Subscription ──────────────────────────────────────────────────────────────
  static const String cashfreeWebhook = '/api/subscription/webhooks/cashfree';
  static const String subscriptionCurrent = '/api/subscription/current';
  static const String subscriptionCancel = '/api/subscription/cancel';
  // POST body: { planId } → returns { orderId, paymentSessionId }
  static const String subscriptionCreate =
      '/api/payments/subscribe-one-time/create';

  // ── Plans ──────────────────────────────────────────────────────────────────────
  static const String plans = '/api/plans'; // GET list (public)

  // ── Dashboard ──────────────────────────────────────────────────────────────────
  static const String dashboardSummary = '/api/dashboard/summary';

  // ── Wallet ─────────────────────────────────────────────────────────────────────
  static const String wallet = '/api/wallet';
  static const String walletTransactions = '/api/wallet/transactions';

  // ── Usage Logs ─────────────────────────────────────────────────────────────────
  static const String usageLogs = '/api/usage-logs';

  // ── User Profile ───────────────────────────────────────────────────────────────
  static const String userProfile =
      '/api/users/profile'; // GET, PUT (multipart)
  static String userById(String id) => '/api/users/$id'; // DELETE (self)

  // ── User Preferences ───────────────────────────────────────────────────────────
  static const String preferences = '/api/preferences'; // GET, PUT
}
