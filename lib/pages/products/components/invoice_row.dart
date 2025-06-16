import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';

class InvoiceRow extends StatelessWidget {
  const InvoiceRow({super.key, required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [AppText(title, fontSize: 30.sp), SizedBox(width: 60.w, child: AppText(value, fontSize: 30.sp))],
    );
  }
}
