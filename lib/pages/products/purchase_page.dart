import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class ChooseNumberPage extends StatefulWidget {
  const ChooseNumberPage({super.key});

  @override
  State<ChooseNumberPage> createState() => _ChooseNumberPageState();
}

class _ChooseNumberPageState extends State<ChooseNumberPage> {
  List<TextEditingController> numberControllers = List.generate(6, (_) => TextEditingController());

  final double basePrice = 4.9875;
  final double vatPercent = 5.0;

  void _quickPick() {
    Random random = Random();
    setState(() {
      for (var controller in numberControllers) {
        controller.text = (random.nextInt(90) + 10).toString(); // Two digit (10-99)
      }
    });
  }

  @override
  void dispose() {
    for (var c in numberControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double vatAmount = basePrice * vatPercent / 100;

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: AppText('Buy Now', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText("Choose Your Number", fontSize: 18.sp, fontWeight: FontWeight.bold),
            Divider(thickness: 2, height: 24.h),
            AppText("Total Amount: AED ${basePrice.toStringAsFixed(4)}", fontSize: 16.sp),
            AppText("VAT (${vatPercent.toStringAsFixed(2)}%): AED ${vatAmount.toStringAsFixed(4)}", fontSize: 16.sp),
            SizedBox(height: 20.h),

            Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(16.r)),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText("Ticket #1", color: Colors.red, fontWeight: FontWeight.bold),
                        AppText("Quick Pick", color: Colors.red, fontWeight: FontWeight.bold),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10.w,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 45.w,
                        height: 45.w,
                        child: TextFormField(
                          controller: numberControllers[index],
                          textAlign: TextAlign.center,
                          maxLength: 2,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: secondaryColor,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _quickPick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: AppText("Quick Pick"),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
            PrimaryButton(
              onTap: () {
                AppSnackbar.showSuccessSnackbar('Purchase confimed!');
              },
              title: 'Confirm Purchase',
            ),
          ],
        ),
      ),
    );
  }
}
