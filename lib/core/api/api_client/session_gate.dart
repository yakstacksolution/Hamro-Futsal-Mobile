/// Single switch that decides whether authenticated HTTP traffic is allowed.
///
/// Screens tear down asynchronously, timers fire once more, and blocs finish
/// in-flight work — all of which can call an API *after* logout has already
/// revoked the token server-side. Those calls can only ever come back 401, so
/// the gate closes the moment the session is cleared and every authenticated
/// request is refused locally instead of being put on the wire. Storing a token
/// (login, OTP verify, biometric unlock, token refresh) reopens it.
class SessionGate {
  SessionGate._();

  static bool _closed = false;

  /// Endpoints that must keep working with no session: they either establish
  /// one or are genuinely unauthenticated.
  static const List<String> _publicPaths = <String>[
    '/auth/login',
    '/auth/google-login',
    '/auth/register',
    '/auth/verify-otp',
    '/auth/resend-otp',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/refresh-token',
    '/app-version',
  ];

  /// True once the session has been cleared and no new one has been stored.
  static bool get isClosed => _closed;

  /// Called when the session ends (logout, revoked/expired token).
  static void close() => _closed = true;

  /// Called whenever a fresh token is persisted.
  static void open() => _closed = false;

  /// Whether a request to [url] must be refused without hitting the network.
  static bool blocks(String? url) {
    if (!_closed) return false;
    if (url == null || url.isEmpty) return true;
    return !_publicPaths.any(url.contains);
  }
}
