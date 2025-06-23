import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.title,
    this.backgroundColor,
    this.titleColor,
    this.onTap,
    this.isLoading = false,
    this.height,
    this.width,
  });

  final String title;
  final void Function()? onTap;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool isLoading;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height ?? 50.h,
        width: width ?? Get.width,
        decoration: BoxDecoration(color: backgroundColor ?? primaryColor, borderRadius: BorderRadius.circular(12.r)),
        child: Center(
          child:
              isLoading
                  ? AppLoading()
                  : AppText(title, color: titleColor ?? Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
