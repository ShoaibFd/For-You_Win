import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class TicketsSearchPage extends StatelessWidget {
  TicketsSearchPage({super.key});

  // Controller!
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Custom Drawer
      drawer: AppDrawer(),
      // AppBar
      appBar: AppBar(title: AppText('Royal 6 Game', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            Center(child: AppText('Royal-6 Ticket Search', fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            // Search Field
            SizedBox(
              height: 55.h,
              child: TextFormField(
                controller: searchController,
                cursorColor: secondaryColor,
                decoration: InputDecoration(
                  suffixIcon: Container(
                    height: 50.h,
                    width: 80.w,
                    decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(8.r)),
                    child: Center(child: AppText('Search', fontWeight: FontWeight.bold)),
                  ),
                  filled: true,
                  fillColor: primaryColor,
                  hintText: 'Enter Ticket Number or Order Number',
                  hintStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide.none),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
