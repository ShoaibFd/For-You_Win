import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void showSuccessSnackbar(String message, {int duration = 3}) {
    Get.snackbar(
      "Success",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: Duration(seconds: duration),
    );
  }

  static void showErrorSnackbar(String message, {int duration = 3}) {
    Get.snackbar(
      "Error",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: Duration(seconds: duration),
    );
  }

  static void showInfoSnackbar(String message, {int duration = 3}) {
    Get.snackbar(
      "Info",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      icon: const Icon(Icons.info, color: Colors.white),
      duration: Duration(seconds: duration),
    );
  }
}
