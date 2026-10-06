class SessionGate {
  SessionGate._();

  static bool _closed = false;

  static const List<String> _publicPaths = <String>[
    '/auth/login',
    '/auth/google-login',
    '/auth/apple-login',
    '/auth/register',
    '/auth/verify-otp',
    '/auth/resend-otp',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/refresh-token',
    '/app-version',
  ];

  static bool get isClosed => _closed;

  static void close() => _closed = true;

  static void open() => _closed = false;

  static bool blocks(String? url) {
    if (!_closed) return false;
    if (url == null || url.isEmpty) return true;
    return !_publicPaths.any(url.contains);
  }
}
