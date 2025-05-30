import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/pages/invoice/invoice_print_page.dart';
import 'package:get/get.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  String reportType = 'Weekly';

  void _checkReport() {
    // Simulate check action
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report Checked')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: AppText('Invoice', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText("My Earnings", fontSize: 22.sp, fontWeight: FontWeight.bold),
            SizedBox(height: 16.h),
            AppText("Report Type", fontWeight: FontWeight.bold),
            const Divider(thickness: 2),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    icon: Icon(Icons.keyboard_arrow_down_outlined),
                    value: reportType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: primaryColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
                    ),
                    items:
                        ['Weekly', 'Daily'].map((type) => DropdownMenuItem(value: type, child: AppText(type))).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => reportType = value);
                      }
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () {
                    _checkReport();
                  },
                  child: Ink(
                    height: 50.h,
                    width: 100.w,
                    decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(8.r)),
                    child: Center(child: AppText('Check', fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            // Table Section!
            reportTable(),
            // Print Invoice Button
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  // _printInvoice();
                  Get.to(() => InvoicePrintPage());
                },
                child: Ink(
                  height: 50.h,
                  width: 120.w,
                  decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(8.r)),
                  child: Center(child: AppText('Print Invoice', fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Report Table Widget!
Widget reportTable() {
  return Container(
    width: double.infinity,
    decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(4.r)),
    padding: EdgeInsets.all(8.r),
    margin: EdgeInsets.symmetric(vertical: 20.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText("Report for Usama", fontWeight: FontWeight.bold),
        SizedBox(height: 4.h),
        AppText("Date Range: 2025-05-13 00:00:00 to 2025-05-17 23:59:00", fontSize: 12.sp),
        SizedBox(height: 10.h),
        Table(
          border: TableBorder.all(color: Colors.black12),
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2)},
          children: const [
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AppText("Total Tickets Sold", fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(8.0), child: AppText("0", textAlign: TextAlign.right)),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AppText("Total Tickets Sales Amount", fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(8.0), child: AppText("AED 0.00", textAlign: TextAlign.right)),
              ],
            ),
            TableRow(
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: AppText("Commission", fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.all(8.0), child: AppText("AED 0.00", textAlign: TextAlign.right)),
              ],
            ),
            TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AppText("Total Price Amount Paid", fontWeight: FontWeight.bold),
                ),
                Padding(padding: EdgeInsets.all(8.0), child: AppText("AED 0.00", textAlign: TextAlign.right)),
              ],
            ),
            TableRow(
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: AppText("Total Revenue", fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.all(8.0), child: AppText("AED 0.00", textAlign: TextAlign.right)),
              ],
            ),
            TableRow(
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: AppText("Amount Paid", fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.all(8.0), child: AppText("AED 0.00", textAlign: TextAlign.right)),
              ],
            ),
            TableRow(
              children: [
                Padding(padding: EdgeInsets.all(8.0), child: AppText("Amount to be Paid", fontWeight: FontWeight.bold)),
                Padding(padding: EdgeInsets.all(8.0), child: AppText("AED 0.00", textAlign: TextAlign.right)),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
