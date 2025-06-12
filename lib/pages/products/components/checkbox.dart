import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class CustomCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CustomCheckbox({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CupertinoCheckbox(
              value: value,
              onChanged: onChanged,
              activeColor: secondaryColor,
              checkColor: primaryColor,
            ),
            Flexible(child: AppText(label, fontSize: 11.sp, color: whiteColor, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
