import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';

class MotivationalQuote extends StatelessWidget {
  const MotivationalQuote({super.key, required this.content});
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: AppText(
       content,
        fontSize: 14.sp,
        color: Colors.red[700],
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
