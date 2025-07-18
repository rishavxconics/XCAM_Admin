import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureLocalStorage {
  static Future<void> setValue(String key, String value) async {
    const storage = FlutterSecureStorage();

    storage.write(key: key, value: value);
  }

  static Future<String> getValue(String key) async {
    const storage = FlutterSecureStorage();

    return await storage.read(key: key) ?? "";
  }

  static Future<void> deleteValue(String key) async {
    const storage = FlutterSecureStorage();

    storage.delete(key: key);
  }
}
