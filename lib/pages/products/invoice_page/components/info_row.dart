import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';

Widget infoRow(String label, String value, {bool isHighlighted = false}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 4.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, fontSize: 14.sp, color: Colors.grey[700]),
        Expanded(
          child: AppText(
            value,
            fontSize: 14.sp,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            color: isHighlighted ? Colors.green : Colors.black,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    ),
  );
}
