import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static const String _tokenKey = 'auth_token';
  static const String _nameKey = 'nameKey';

  // Function to Save Token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    log('Token saved in SharedPrefs: $token');
  }

  // Function to Get Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Function to Remove Token
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Function to Save Token
  Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    log('Name saved in SharedPrefs: $name');
  }

  // Function to Get Token
  Future<String?> getName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  // Function to Remove Token
  Future<void> removeName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
  }
}
