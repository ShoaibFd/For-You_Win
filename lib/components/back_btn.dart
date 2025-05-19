import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget backButton() {
  return IconButton(
    onPressed: () {
      Get.back();
    },
    icon: Icon(Icons.arrow_back_ios),
  );
}
