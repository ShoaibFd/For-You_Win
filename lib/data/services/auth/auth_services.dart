import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/data/app_urls.dart';
import 'package:for_u_win/pages/auth/login_page.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:for_u_win/storage/shared_prefs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthServices with ChangeNotifier {
  // Variables
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final SharedPrefs _sharedPrefs = SharedPrefs();

  // To Register User
  Future<void> createAccount(String name, String email, String phone, String address) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await http.post(
        Uri.parse(registerUrl),
        body: {'name': name, 'email': email, 'phone': phone, 'address': address},
      );

      log('Create Account Response: ${response.statusCode} ${response.body}');
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.showSuccessSnackbar(responseData['message'], duration: 8);
        Get.offAll(() => LoginPage());
      } else {
        AppSnackbar.showErrorSnackbar(responseData['message']);
      }
    } catch (e) {
      log('Create Account Error: $e');
      // AppSnackbar.showErrorSnackbar('An error occurred. Please check your credentials.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // To Login User
  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await http.post(Uri.parse(loginUrl), body: {'email': email, 'password': password});

      log('Login Response: ${response.statusCode} ${response.body}');
      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _sharedPrefs.saveToken(responseData['token']);

        Get.offAll(() => BottomNavigationBarPage());
        AppSnackbar.showSuccessSnackbar(responseData['message']);
      } else {
        AppSnackbar.showInfoSnackbar(responseData['message']);
      }
    } catch (e) {
      log('Login Error: $e');
      AppSnackbar.showErrorSnackbar('An error occurred. Please check your credentials.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // To Logout User
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _sharedPrefs.removeToken();
      Get.offAll(() => LoginPage());
      AppSnackbar.showSuccessSnackbar('Logout successfully!');
    } catch (e) {
      log('Logout Error: $e');
      AppSnackbar.showErrorSnackbar('An error occurred. Please check your connection.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
