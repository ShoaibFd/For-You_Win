// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/bottom_navbar/dashboard_page.dart';
import 'package:for_u_win/pages/bottom_navbar/persistent_nav_wrapper.dart';
import 'package:for_u_win/pages/bottom_navbar/scanner_page.dart';
import 'package:for_u_win/pages/products/products_page.dart';
import 'package:get/get.dart';

class BottomNavigationBarPage extends StatefulWidget {
  final Widget? child;
  final int initialIndex;

  const BottomNavigationBarPage({super.key, this.child, this.initialIndex = 0});

  @override
  State<BottomNavigationBarPage> createState() => _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {
  late int currentIndex;
  late final NavigationController navigationController;

  // List Of Pages!
  final List<Widget> pages = [ProductsPage(), ScannerPage(), DashboardPage()];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    // Make sure NavigationController is initialized
    if (!Get.isRegistered<NavigationController>()) {
      Get.put(NavigationController());
    }
    navigationController = Get.find<NavigationController>();
    // Set initial index in controller
    navigationController.changeIndex(widget.initialIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    navigationController.changeIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex != 0) {
          _onItemTapped(0);
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(index: currentIndex, children: pages),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          color: Colors.black87,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home Button!
              IconButton(
                onPressed: () => _onItemTapped(0),
                icon: Image.asset(
                  'assets/images/home.png',
                  color: currentIndex == 0 ? primaryColor : whiteColor,
                  height: 24.h,
                ),
              ),
              SizedBox(width: 48.w),
              // Dashboard Button
              IconButton(
                onPressed: () => _onItemTapped(2),
                icon: Image.asset(
                  'assets/images/dashboard.png',
                  color: currentIndex == 2 ? primaryColor : whiteColor,
                  height: 24.h,
                ),
              ),
            ],
          ),
        ),
        // Scanner Button
        floatingActionButton: SizedBox(
          height: 70.h,
          width: 70.w,
          child: FloatingActionButton(
            onPressed: () => _onItemTapped(1),
            backgroundColor: secondaryColor,
            elevation: 6,
            shape: const CircleBorder(side: BorderSide(color: primaryColor, width: 2)),
            child: Image.asset('assets/images/scanner.png', height: 30.h, width: 30.w, color: primaryColor),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
