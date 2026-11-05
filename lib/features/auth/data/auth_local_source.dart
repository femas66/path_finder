import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user_model.dart';

class AuthLocalSource {
  AuthLocalSource([this._preferencesInstance]);

  final SharedPreferences? _preferencesInstance;

  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyRememberMe = 'auth_remember_me';

  Future<SharedPreferences> _getPrefs() async {
    return _preferencesInstance ?? await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keyToken, token);
  }

  Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keyToken);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> deleteToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyToken);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_keyUser, jsonString);
  }

  Future<UserModel?> getUser() async {
    final prefs = await _getPrefs();
    final jsonString = prefs.getString(_keyUser);
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUser() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyUser);
  }

  Future<void> saveSession({
    required String token,
    required UserModel user,
  }) async {
    await saveToken(token);
    await saveUser(user);
  }

  Future<void> clearSession() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  Future<void> setRememberMe(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyRememberMe, value);
  }

  Future<bool> getRememberMe() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyRememberMe) ?? false;
  }
}
