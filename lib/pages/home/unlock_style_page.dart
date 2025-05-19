import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';

class UnlockStylePage extends StatelessWidget {
  const UnlockStylePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
        decoration: BoxDecoration(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/prize.png', height: 200.h),
              SizedBox(height: 30.h),
              AppText('Unlock Style & Purpose', fontWeight: FontWeight.bold, fontSize: 24.sp),
              SizedBox(height: 10.h),
              AppText('Shop Smart, Win Big,\nMake a Difference.', fontSize: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}
