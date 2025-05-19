import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({super.key, this.controller, this.keyboardType, this.hint, this.label, this.suffixIcon});
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hint;
  final String? label;
  final IconData? suffixIcon;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: secondaryColor,
      controller: controller,
      keyboardType: keyboardType,
      validator: (field) {
        if (field!.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        label: AppText(label ?? ""),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: secondaryColor)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: secondaryColor, width: 2)),
        errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
        hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
        suffixIcon: Icon(suffixIcon, color: secondaryColor),
      ),
    );
  }
}
