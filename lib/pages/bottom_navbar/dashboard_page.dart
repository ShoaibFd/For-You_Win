import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final List<Map<String, dynamic>> data = [
    {"image": "assets/images/premium.png", "title": "Royal-6"},
    {"image": "assets/images/trophy.png", "title": "Mega-4"},
    {"image": "assets/images/star.png", "title": "Thrill-3"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: AppText('Dashboard', fontSize: 16.sp, fontWeight: FontWeight.w600),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(10.r)),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Stack(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Stack(
                              children: [
                                Image.asset('assets/images/badge.png', height: 70.h),
                                Padding(
                                  padding: EdgeInsets.only(left: 18.w, top: 20.h),
                                  child: Image.asset(data[index]['image'], height: 40.h),
                                ),
                              ],
                            ),
                            AppText(data[index]['title'], fontSize: 16.sp),
                          ],
                        ),
                        Padding(padding: EdgeInsets.only(top: 60.h), child: Divider(thickness: 2, color: blackColor)),
                        Padding(
                          padding: EdgeInsets.only(top: 80),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [AppText('Entry Prize', fontSize: 16.sp), AppText('AED 4.75', fontSize: 16.sp)],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
