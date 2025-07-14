import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';

class Header extends StatelessWidget {
  final bool isPrinting;
  final VoidCallback onClose;

  const Header({super.key, required this.isPrinting, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            isPrinting ? 'Printing...' : 'Invoice',
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isPrinting ? Colors.orange[600] : null,
          ),
          isPrinting
              ? Icon(Icons.print, size: 24.sp, color: Colors.orange[600])
              : GestureDetector(onTap: onClose, child: Icon(Icons.close, size: 24.sp, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
