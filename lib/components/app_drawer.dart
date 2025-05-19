import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/auth/login_page.dart';
import 'package:for_u_win/pages/products/products_page.dart';
import 'package:get/get.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _showGameOptions = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 100.h,
            width: double.maxFinite,
            color: primaryColor,
            child: Image.asset('assets/images/logo.png', height: 50.h),
          ),
          ListTile(
            onTap: () {},
            leading: Image.asset('assets/images/dashboard.png', height: 26.h),
            title: AppText('Dashboard', fontSize: 16.sp),
          ),
          ListTile(
            onTap: () {
              Get.to(() => ProductsPage());
            },
            leading: Image.asset('assets/images/products.png', height: 26.h),
            title: AppText('All Products', fontSize: 16.sp),
          ),
          // My Games - expandable
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
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: ListTile(
                onTap: () {},
                leading: Image.asset('assets/images/premium.png', height: 30.h),
                title: AppText('Royal-6', fontSize: 14.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: ListTile(
                onTap: () {},
                leading: Image.asset('assets/images/trophy.png', height: 30.h),
                title: AppText('Mega-3', fontSize: 14.sp),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 50.w),
              child: ListTile(
                onTap: () {},
                leading: Image.asset('assets/images/star.png', height: 30.h),
                title: AppText('Thrill-3', fontSize: 14.sp),
              ),
            ),
          ],
          ListTile(
            onTap: () {},
            leading: Image.asset('assets/images/invoice.png', height: 26.h),
            title: AppText('Invoice.', fontSize: 16.sp),
          ),
          ListTile(
            onTap: () {
              _showLogoutDialog(context);
            },
            leading: Image.asset('assets/images/logout.png', height: 26.h),
            title: AppText('LogOut.', fontSize: 16.sp),
          ),
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
          title: AppText('Confirm Logout', fontSize: 18.sp, fontWeight: FontWeight.w600),
          content: AppText('Are you sure you want to logout?', fontSize: 15.sp),
          actions: [
            TextButton(onPressed: () => Get.back(), child: AppText('Cancel', fontSize: 14.sp, color: Colors.grey)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
              ),
              onPressed: () {
                Get.to(() => LoginPage());
              },
              child: AppText('Logout', fontSize: 14.sp, color: Colors.white),
            ),
          ],
        );
      },
    );
  }
}
