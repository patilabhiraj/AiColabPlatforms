import 'package:google_sign_in/google_sign_in.dart';

/// Thrown when the user dismisses the Google account picker. Callers should
/// treat this as a silent no-op (not an error to surface).
class GoogleSignInCancelled implements Exception {
  const GoogleSignInCancelled();
}

/// Wraps the native Google Sign-In SDK (google_sign_in v7) and returns the
/// Google **ID token** that the backend exchanges at `/api/auth/google/mobile`.
///
/// The ID token must be audienced to the backend's OAuth **Web** client, so
/// [serverClientId] is required — without it the backend rejects the token.
class GoogleAuthService {
  GoogleAuthService();

  bool _initialized = false;

  /// Backend's Google OAuth **Web** client ID (…apps.googleusercontent.com).
  /// The `idToken` is issued for this audience so the backend can verify it.
  //
  // TODO(auth): replace with the real Web client ID from the backend dev /
  // Google Cloud Console. Leaving this blank makes sign-in fail fast with a
  // clear error rather than returning a token the backend can't verify.
  static const String _serverClientId = '900657622558-424gbu77lha48ch6n66kjh9hb3jvspoe.apps.googleusercontent.com';

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(serverClientId: _serverClientId);
    _initialized = true;
  }

  /// Runs the interactive sign-in flow and returns the Google ID token.
  ///
  /// Throws [GoogleSignInCancelled] if the user dismisses the picker, and a
  /// generic [Exception] if no ID token comes back.
  Future<String> signInAndGetIdToken() async {
    await _ensureInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const GoogleSignInCancelled();
      }
      rethrow;
    }

    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google did not return an ID token.');
    }
    return idToken;
  }

  /// Clears the cached Google session so the next sign-in shows the picker.
  Future<void> signOut() async {
    if (!_initialized) return;
    await GoogleSignIn.instance.signOut();
  }
}
