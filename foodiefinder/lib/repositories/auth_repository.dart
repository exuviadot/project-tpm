import '../services/api_service.dart';
import '../models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthResult {
  final String token;
  final User user;
  AuthResult(this.token, this.user);
}

class AuthRepository {
  final ApiService _api = ApiService();
  final _storage = const FlutterSecureStorage();

  Future<void> register(String name, String email, String password) async {
    await _api.post('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<AuthResult> login(String email, String password) async {
    final response = await _api.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    final token = response['token'];
    final user = User.fromJson(response['user']);
    
    await _storage.write(key: 'jwt_token', value: token);
    final box = await Hive.openBox('user');
    await box.put('data', user.toJson());
    
    return AuthResult(token, user);
  }

  Future<User?> getProfile() async {
    try {
      final response = await _api.get('/api/auth/profile');
      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
    final box = await Hive.openBox('user');
    await box.clear();
  }
}
