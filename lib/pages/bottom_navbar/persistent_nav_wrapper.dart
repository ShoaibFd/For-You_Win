import 'package:flutter/material.dart';
import 'package:for_u_win/pages/bottom_navbar/bottom_navbar.dart';
import 'package:get/get.dart';

class PersistentNavWrapper extends StatelessWidget {
  final Widget child;
  final int initialIndex;

  const PersistentNavWrapper({super.key, required this.child, this.initialIndex = 0});

  @override
  Widget build(BuildContext context) {
    // Initialize the NavigationController if it hasn't been initialized yet
    if (!Get.isRegistered<NavigationController>()) {
      Get.put(NavigationController());
    }

    return GetBuilder<NavigationController>(
      builder: (controller) {
        return BottomNavigationBarPage(initialIndex: initialIndex);
      },
    );
  }
}

// Navigation Controller!
class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
