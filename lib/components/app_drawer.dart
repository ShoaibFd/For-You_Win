import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/auth/login_page.dart';
import 'package:for_u_win/pages/bottom_navbar/dashboard/dashboard_page.dart';
import 'package:for_u_win/pages/bottom_navbar/persistent_nav_wrapper.dart';
import 'package:for_u_win/pages/invoice/invoice_page.dart';
import 'package:for_u_win/pages/products/products_page.dart';
import 'package:for_u_win/pages/tickets/click_page.dart';
import 'package:for_u_win/pages/tickets/foryou_page.dart';
import 'package:for_u_win/pages/tickets/mega_page.dart';
import 'package:for_u_win/pages/tickets/royal_page.dart';
import 'package:for_u_win/pages/tickets/thrill_page.dart';
import 'package:for_u_win/storage/shared_prefs.dart';
import 'package:get/get.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _showGameOptions = false;
  final SharedPrefs _sharedPrefs = SharedPrefs();
  String? userName;
  @override
  void initState() {
    super.initState();
    _loadName();
  }

  void _loadName() async {
    final name = await _sharedPrefs.getName();
    setState(() {
      userName = name;
    });
  }

  Map<String, dynamic>? invoiceData;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Logo Section!
          Container(
            height: 140.h,
            width: double.maxFinite,
            color: primaryColor,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 100.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    spacing: 10.w,
                    children: [
                      CircleAvatar(
                        backgroundColor: blackColor,
                        child: Center(child: Icon(Icons.person_2_rounded, color: whiteColor)),
                      ),
                      AppText('$userName'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Dashboard Button!
          ListTile(
            onTap: () {
              Get.back(); // Close the drawer
              Get.offAll(() => PersistentNavWrapper(initialIndex: 2, child: DashboardPage()));
            },
            leading: Image.asset('assets/images/dashboard.png', height: 26.h),
            title: AppText('Dashboard', fontSize: 16.sp),
          ),
          // Product Button!
          ListTile(
            onTap: () {
              Get.back(); // Close the drawer
              Get.offAll(() => const PersistentNavWrapper(initialIndex: 0, child: ProductsPage()));
            },
            leading: Image.asset('assets/images/products.png', height: 26.h),
            title: AppText('All Products', fontSize: 16.sp),
          ),
          // My Games - expandable!
          ListTile(
            leading: Image.asset('assets/images/game.png', height: 26.h),
            title: AppText('My Games', fontSize: 16.sp),
            trailing: CircleAvatar(
              backgroundColor: secondaryColor,
              child: IconButton(
                icon: Icon(_showGameOptions ? Icons.keyboard_arrow_up_outlined : Icons.keyboard_arrow_down_outlined),
                onPressed: () {
                  setState(() {
                    _showGameOptions = !_showGameOptions;
                  });
                },
              ),
            ),
          ),
          if (_showGameOptions) ...[
            // Royal-6 Button!
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: ListTile(
                onTap: () {
                  Get.back();
                  Get.to(() => RoyalPage());
                },
                leading: Image.asset('assets/images/premium.png', height: 30.h),
                title: AppText('Royal-6', fontSize: 14.sp),
              ),
            ),
            // 4uwin Button!
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: ListTile(
                onTap: () {
                  Get.back();
                  Get.to(() => ForYouPage());
                },
                leading: Image.asset('assets/images/star.png', height: 30.h),
                title: AppText('4uwin-5', fontSize: 14.sp),
              ),
            ),
            // Mega-4 Button!
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: ListTile(
                onTap: () {
                  Get.back();
                  Get.to(() => MegaPage());
                },
                leading: Image.asset('assets/images/trophy.png', height: 30.h),
                title: AppText('Mega-4', fontSize: 14.sp),
              ),
            ),
            // Thrill-3 Button!
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: ListTile(
                onTap: () {
                  Get.back();
                  Get.to(() => ThrillPage());
                },
                leading: Image.asset('assets/images/star.png', height: 30.h),
                title: AppText('Thrill-3', fontSize: 14.sp),
              ),
            ),
            // Click-2 Button!
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: ListTile(
                onTap: () {
                  Get.back();
                  Get.to(() => ClickPage());
                },
                leading: Image.asset('assets/images/star.png', height: 30.h),
                title: AppText('Click-2', fontSize: 14.sp),
              ),
            ),
          ],
          // Invoice Button!
          ListTile(
            onTap: () {
              Get.back();
              Get.to(() => InvoicePage());
            },
            leading: Image.asset('assets/images/invoice.png', height: 26.h),
            title: AppText('Invoice.', fontSize: 16.sp),
          ),
          // Logout Button!
          ListTile(
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
            leading: Image.asset('assets/images/logout.png', height: 26.h),
            title: AppText('Logout.', fontSize: 16.sp, color: Colors.red),
          ),
          // Spacer(),
          // // Invoice Button!
          // ListTile(
          //   onTap: () {
          //     Get.back();
          //     Get.to(() => SettingsPage());
          //   },
          //   leading: Image.asset('assets/images/settings.png', height: 26.h),
          //   title: AppText('Settings.', fontSize: 16.sp),
          // ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          // title: AppText('Confirm Logout', fontSize: 18.sp, fontWeight: FontWeight.w600),
          content: AppText('Are you sure you want to logout?', fontSize: 15.sp),
          actions: [
            TextButton(onPressed: () => Get.back(), child: AppText('Cancel', fontSize: 14.sp, color: Colors.grey)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () async {
                Get.back();
                Get.dialog(const AppLoading(), barrierDismissible: false);
                await _sharedPrefs.removeToken();
                await _sharedPrefs.removeName();
                await Future.delayed(const Duration(seconds: 2));
                Get.offAll(() => LoginPage());
              },
              child: AppText('Logout', fontSize: 14.sp, color: whiteColor),
            ),
          ],
        );
      },
    );
  }
}
