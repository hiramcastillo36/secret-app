/// Compile-time configuration.
///
/// The default is the production API over HTTPS, so a release build made
/// without any `--dart-define` is still safe to ship. For local development
/// point it at the backend explicitly:
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080   # Android emulator
///   flutter run --dart-define=API_BASE_URL=http://localhost:8080  # iOS simulator
///
/// Cleartext (`http://`) only works in debug builds — see
/// `android/app/src/debug/res/xml/network_security_config.xml`. A release build
/// pointed at an `http://` URL will fail every request by design.
class Env {
  const Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.racha.app',
  );

  /// Whether [apiBaseUrl] is a plaintext URL. Release builds assert against
  /// this in [assertReleaseConfig].
  static bool get isCleartext => apiBaseUrl.startsWith('http://');

  /// Fails fast in release builds configured to talk cleartext, which the
  /// platform would silently block anyway. No-op in debug/profile.
  static void assertReleaseConfig() {
    const isRelease = bool.fromEnvironment('dart.vm.product');
    if (isRelease && isCleartext) {
      throw StateError(
        'Release build configured with a cleartext API_BASE_URL ($apiBaseUrl). '
        'Pass --dart-define=API_BASE_URL=https://... for release builds.',
      );
    }
  }
}
