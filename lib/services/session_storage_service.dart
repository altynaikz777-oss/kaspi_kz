import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStorageService {
  SessionStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _uidKey = 'session_uid';
  static const _phoneKey = 'session_phone';
  static const _pinUnlockedKey = 'pin_unlocked';

  Future<void> persistAuthSession({
    required String uid,
    required String phoneNumber,
  }) async {
    await _storage.write(key: _uidKey, value: uid);
    await _storage.write(key: _phoneKey, value: phoneNumber);
  }

  Future<String?> readStoredUid() => _storage.read(key: _uidKey);

  Future<String?> readStoredPhone() => _storage.read(key: _phoneKey);

  Future<void> setPinUnlocked(bool unlocked) {
    return _storage.write(key: _pinUnlockedKey, value: unlocked ? '1' : '0');
  }

  Future<bool> isPinUnlocked() async {
    return (await _storage.read(key: _pinUnlockedKey)) == '1';
  }

  Future<void> clear() => _storage.deleteAll();
}
