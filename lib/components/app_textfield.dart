import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
   AppTextField({
    super.key,
    this.controller,
    this.keyboardType,
    this.hint,
    this.label,
    this.suffixIcon,
    this.validator,
    this.obscureText = false,
    this.onSuffixIconTap,
    this.onChanged
  });

  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? hint;
  final String? label;
  final IconData? suffixIcon;
  final String? Function(String?)? validator;
  final bool obscureText;
  final VoidCallback? onSuffixIconTap;
  void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: secondaryColor,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        label: AppText(label ?? ""),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: secondaryColor)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: secondaryColor, width: 2)),
        errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
        hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey),
        suffixIcon:
            suffixIcon != null
                ? GestureDetector(onTap: onSuffixIconTap, child: Icon(suffixIcon, color: secondaryColor))
                : null,
      ),
      onChanged: onChanged,
    );
  }
}
