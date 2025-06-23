import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class TicketNumbersWidget extends StatelessWidget {
  final List<dynamic> numbers;

  const TicketNumbersWidget({super.key, required this.numbers});

  Widget numbersInRow(List<dynamic> numbers) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children:
          numbers.map((number) {
            return Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor, width: 2),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: AppText(number.toString(), fontSize: 14.sp, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> ticketWidgets = [];

    for (int ticketIndex = 0; ticketIndex < numbers.length; ticketIndex++) {
      List<dynamic> ticketNumbers = numbers[ticketIndex];

      ticketWidgets.add(
        Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8.r)),
                child: AppText(
                  'Ticket #${ticketIndex + 1}',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 12.h),
              numbersInRow(ticketNumbers),
            ],
          ),
        ),
      );
    }

    return Column(children: ticketWidgets);
  }
}
