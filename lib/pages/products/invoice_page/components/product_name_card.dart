import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';

class ProductNameCard extends StatelessWidget {
  final String productName;

  const ProductNameCard(this.productName, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8.r)),
      child: AppText(productName, fontSize: 18.sp, fontWeight: FontWeight.bold, textAlign: TextAlign.center),
    );
  }
}
