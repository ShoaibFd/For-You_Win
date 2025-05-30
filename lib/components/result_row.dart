import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class ResultRow extends StatelessWidget {
  final String title;
  final Color mainCircleColor;
  final Color textColor;
  final int mainNumber;
  final int count;

  const ResultRow({
    super.key,
    required this.title,
    required this.mainCircleColor,
    required this.textColor,
    required this.mainNumber,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(color: blackColor, borderRadius: BorderRadius.circular(3.r)),
          padding: const EdgeInsets.all(6.0),
          child: AppText(title, fontWeight: FontWeight.bold, color: secondaryColor),
        ),
        SizedBox(width: 10.w),
        CircleAvatar(
          radius: 15,
          backgroundColor: mainCircleColor,
          child: AppText('$mainNumber', fontWeight: FontWeight.bold, color: textColor),
        ),
        SizedBox(width: 10.w),
        Row(
          children: List.generate(count, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: whiteColor,
                child: AppText('${index + 1}', fontWeight: FontWeight.bold),
              ),
            );
          }),
        ),
      ],
    );
  }
}
