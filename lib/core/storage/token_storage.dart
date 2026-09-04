import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the access/refresh pair in the platform keystore/keychain.
class TokenStorage {
  TokenStorage(this._store);

  final FlutterSecureStorage _store;

  static const _kAccess = 'racha.access_token';
  static const _kRefresh = 'racha.refresh_token';

  Future<String?> readAccess() => _store.read(key: _kAccess);
  Future<String?> readRefresh() => _store.read(key: _kRefresh);

  Future<void> save({required String access, required String refresh}) async {
    await _store.write(key: _kAccess, value: access);
    await _store.write(key: _kRefresh, value: refresh);
  }

  Future<void> saveAccess(String access) =>
      _store.write(key: _kAccess, value: access);

  Future<void> clear() async {
    await _store.delete(key: _kAccess);
    await _store.delete(key: _kRefresh);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
});
