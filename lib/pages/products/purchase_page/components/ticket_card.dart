

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/pages/products/components/checkbox.dart';

class PurchaseTicketCard extends StatelessWidget {
  final int ticketIndex;
  final int numberOfField;

  const PurchaseTicketCard({
    super.key,
    required this.ticketIndex,
    required this.numberOfField,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText("Ticket #${ticketIndex + 1}", color: whiteColor, fontWeight: FontWeight.bold),
                GestureDetector(
                  onTap: () {}, // TODO: Connect to quickPick logic
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Center(child: AppText('Quick Pick', color: whiteColor)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Number Input Fields
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10.w,
            children: List.generate(numberOfField, (index) {
              return SizedBox(
                width: 42.w,
                height: 50.w,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  maxLength: numberOfField == 6 ? 2 : 1,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: secondaryColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 16.h),

          // Game Type Checkboxes
          if (numberOfField != 6)
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: whiteColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomCheckbox(label: 'Straight', value: false, onChanged: (_) {}),
                  CustomCheckbox(label: 'Rumble', value: false, onChanged: (_) {}),
                  CustomCheckbox(label: 'Chance', value: false, onChanged: (_) {}),
                ],
              ),
            ),
        ],
      ),
    );
  }
}


