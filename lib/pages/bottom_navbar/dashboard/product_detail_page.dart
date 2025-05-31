import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, this.productId});
  final int? productId;

  @override
  Widget build(BuildContext context) {
    final headers = [
      'Order Number\n67912',
      'Draw Date\n2025-05-06',
      'Order Date\n2025-05-06',
      'Status\nAnnounced',
      'Prize\nAED 35,000',
      'Numbers\n0,0,1,4',
      'Straight\n1',
      'Rumble\n0',
      'Chance\n0',
      'Created At\n2025-05-06 10:20',
    ];

    return Scaffold(
      appBar: AppBar(title: AppText('Scanner', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Your Tickets for Thrill-3', fontWeight: FontWeight.bold, fontSize: 18),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              children: [
                for (final title in ['Copy', 'CSV', 'Exel', 'PDF', 'Print'])
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryColor,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: AppText(title, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Table(
              border: TableBorder.all(color: Colors.black, width: 1),
              columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
              children: List.generate(headers.length ~/ 2, (index) {
                return TableRow(children: [tableCell(headers[index * 2]), tableCell(headers[index * 2 + 1])]);
              }),
            ),
            SizedBox(height: 16.h),
            AppText('Showing Results 1 to 1 of 1 Entries'),
            SizedBox(height: 16.h),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.keyboard_double_arrow_left_outlined),
                  label: AppText('Back to Products'),
                  style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, foregroundColor: Colors.black),
                ),
                const Spacer(),
                AppText('Previous'),
                SizedBox(width: 8.w),
                CircleAvatar(radius: 14.r, backgroundColor: secondaryColor, child: AppText('1')),
                SizedBox(width: 8.w),
                AppText('Next'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget tableCell(String text) {
    return Container(
      padding: EdgeInsets.all(12.r),
      color: primaryColor,
      child: AppText(text, fontWeight: FontWeight.bold),
    );
  }
}
