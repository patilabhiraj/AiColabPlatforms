abstract final class ApiConstants {
  static const String baseUrl = 'https://ai-colab-chat-manan-backend.onrender.com';

  // Auth
  static const String login            = '/api/auth/login';
  static const String register         = '/api/auth/register';
  static const String googleStart      = '/api/auth/google/start';
  static const String googleCallback   = '/api/auth/google/callback';
  static const String verifyEmailOtp   = '/api/auth/verify-email-otp';
  static const String resendEmailOtp   = '/api/auth/resend-email-otp';
  static const String forgotPassword   = '/api/auth/forgot-password';
  static const String resetPassword    = '/api/auth/reset-password';

  // Chats / Attachments
  static const String sharedChat       = '/api/chats/shared'; // append /{shareId}
  static const String downloadAttachment = '/api/attachments'; // append /{id}/download

  // Subscription
  static const String cashfreeWebhook  = '/api/subscription/webhooks/cashfree';
}
