import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AppLoading extends StatelessWidget {
  final double size;
  final Color color;

  const AppLoading({super.key, this.size = 30, this.color = secondaryColor});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.threeRotatingDots(color: color, size: size.sp);
  }
}
