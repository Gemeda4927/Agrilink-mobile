import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static TokenManager? _instance;
  late SharedPreferences _prefs;

  TokenManager._internal();

  static Future<TokenManager> getInstance() async {
    if (_instance == null) {
      _instance = TokenManager._internal();
      await _instance!._initPrefs();
    }
    return _instance!;
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  bool hasToken() {
    return _prefs.containsKey(_tokenKey);
  }
}
