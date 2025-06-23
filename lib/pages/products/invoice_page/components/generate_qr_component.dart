// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQrComponent extends StatefulWidget {
  const GenerateQrComponent({super.key, required this.orderNumber, required this.productName, required this.orderDate});
  final String orderNumber;
  final String productName;
  final String orderDate;

  @override
  State<GenerateQrComponent> createState() => _GenerateQrComponentState();
}

class _GenerateQrComponentState extends State<GenerateQrComponent> {
  String generateQRData() {
    return 'Order:${widget.orderNumber}|Product:${widget.productName}|Date:${widget.orderDate}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          AppText(
            'Scan QR Code for Invoice Details',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          QrImageView(
            data: generateQRData(),
            version: QrVersions.auto,
            size: 150.w,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
