import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthServices with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // To Register User
  Future<void> createAccount(String name, String email, String phone, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await http.post(
        Uri.parse('https://your-api-url.com/api/register'),
        body: {'name': name, 'email': email, 'phone': phone, 'password': password},
      );

      log('Create Account Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.showSuccessSnackbar('Account created successfully!');
        Get.offAll(() => BottomNavigationBarPage());
      } else {
        AppSnackbar.showErrorSnackbar('Something went wrong! Try again.');
      }
    } catch (e) {
      log('Create Account Error: $e');
      AppSnackbar.showErrorSnackbar('An error occurred. Please check your connection.');
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
      final response = await http.post(
        Uri.parse('https://your-api-url.com/api/login'),
        body: {'email': email, 'password': password},
      );

      log('Login Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackbar.showSuccessSnackbar('Login successfully!');
        Get.offAll(() => BottomNavigationBarPage());
      } else {
        AppSnackbar.showErrorSnackbar('Something went wrong! Try again.');
      }
    } catch (e) {
      log('Login Error: $e');
      AppSnackbar.showErrorSnackbar('An error occurred. Please check your connection.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
