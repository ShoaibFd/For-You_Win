// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/bottom_navbar/dashboard/dashboard_page.dart';
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

  List<Widget> get pages {
    return [
      const ProductsPage(),
      if (currentIndex == 1) const ScannerPage() else const SizedBox.shrink(),
      const DashboardPage(),
    ];
  }

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;

    if (!Get.isRegistered<NavigationController>()) {
      Get.put(NavigationController());
    }
    navigationController = Get.find<NavigationController>();
    navigationController.changeIndex(widget.initialIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
    navigationController.changeIndex(index);
  }

  Future<bool> _showExitDialog() async {
    final TextEditingController passwordController = TextEditingController();
    ValueNotifier<bool> errorNotifier = ValueNotifier<bool>(false);

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              elevation: 16,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              titlePadding: EdgeInsets.only(top: 28.h, left: 24.w, right: 24.w, bottom: 0),
              contentPadding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 8.h),
              actionsPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
              title: Column(
                children: [
                  Icon(Icons.lock_outline, color: Colors.redAccent, size: 42.sp),
                  SizedBox(height: 16.h),
                  Text(
                    'Confirm Exit',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              content: SizedBox(
                width: 330.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter password to exit",
                      style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ValueListenableBuilder<bool>(
                      valueListenable: errorNotifier,
                      builder: (context, hasError, child) {
                        return TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            hintText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14.r),
                              borderSide: BorderSide(color: hasError ? Colors.red : Colors.deepPurpleAccent, width: 2),
                            ),
                            errorText: hasError ? 'Incorrect Password' : null,
                            suffixIcon: Icon(
                              Icons.vpn_key_rounded,
                              color: hasError ? Colors.red : Colors.grey[400],
                              size: 22.sp,
                            ),
                          ),
                          style: TextStyle(fontSize: 17.sp, color: Colors.black87, letterSpacing: 1.1),
                          onChanged: (_) {
                            if (hasError) errorNotifier.value = false;
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        foregroundColor: Colors.black87,
                        minimumSize: Size(110.w, 44.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text('Cancel', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        minimumSize: Size(110.w, 44.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        elevation: 0,
                      ),
                      child: Text('Exit', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        if (passwordController.text == "55555") {
                          Navigator.of(dialogContext).pop(true);
                        } else {
                          errorNotifier.value = true;
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex != 0) {
          _onItemTapped(0);
          return false;
        } else {
          return await _showExitDialog();
        }
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
              IconButton(
                onPressed: () => _onItemTapped(0),
                icon: Image.asset(
                  'assets/images/home.png',
                  color: currentIndex == 0 ? primaryColor : whiteColor,
                  height: 24.h,
                ),
              ),
              SizedBox(width: 48.w),
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
        floatingActionButton: SizedBox(
          height: 70.h,
          width: 70.w,
          child: FloatingActionButton(
            onPressed: () => _onItemTapped(1),
            backgroundColor: blackColor,
            elevation: 6,
            shape: const CircleBorder(side: BorderSide(color: primaryColor, width: 4)),
            child: Image.asset('assets/images/scanner.png', height: 30.h, width: 30.w, color: primaryColor),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
