/// Compile-time configuration. Override with
/// `--dart-define=API_BASE_URL=https://...` for staging/production builds.
class Env {
  const Env._();

  /// Default targets a local backend. `10.0.2.2` is the host loopback from the
  /// Android emulator; iOS simulators can reach `localhost` directly, so pass a
  /// dart-define there.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
}
