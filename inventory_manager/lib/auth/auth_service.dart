import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveSession(Map<String, dynamic> user, String password) async {
    await _storage.write(key: 'name', value: user['name']);
    await _storage.write(key: 'email', value: user['email']);
    await _storage.write(key: 'id', value: user['_id']);
    await _storage.write(key: 'password', value: password);
  }

  Future<Map<String, String>> getCredentials() async {
    if (!await isLoggedIn()) {
      throw Exception('User is not logged in');
    }

    String? email = await _storage.read(key: 'email');
    String? password = await _storage.read(key: 'password');

    return {
      'email': email!,
      'password': password!,
    };
  }

  Future<Map<String, String>> getSession() async {
    if (!await isLoggedIn()) {
      throw Exception('User is not logged in');
    }

    String? name = await _storage.read(key: 'name');
    String? email = await _storage.read(key: 'email');
    String? id = await _storage.read(key: 'id');
    String? password = await _storage.read(key: 'password');

    return {
      'name': name!,
      'email': email!,
      'id': id!,
      'password': password!,
    };
  }

  Future<void> deleteSession() async {
    await _storage.deleteAll();
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'id');
  }

  Future<String?> getPassword() async {
    return await _storage.read(key: 'password');
  }

  Future<bool> isLoggedIn() async {
    return await _storage.read(key: 'id') != null;
  }
}
