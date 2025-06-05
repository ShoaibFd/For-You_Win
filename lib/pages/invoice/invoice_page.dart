import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/invoice/invoice_services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  String reportType = 'weekly';
  DateTime? startDate;
  DateTime? endDate;

  final Map<String, String> reportTypeOptions = {'Weekly': 'weekly', 'Daily': 'daily'};

  @override
  void initState() {
    super.initState();
    _setDefaultDates();
  }

  void _setDefaultDates() {
    final now = DateTime.now();
    if (reportType == 'weekly') {
      startDate = now.subtract(Duration(days: now.weekday - 1));
      endDate = startDate!.add(Duration(days: 6));
    } else if (reportType == 'daily') {
      startDate = now;
      endDate = now;
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (startDate ?? DateTime.now()) : (endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return 'AED 0.00';
    return 'AED ${double.tryParse(amount.toString())?.toStringAsFixed(2) ?? '0.00'}';
  }

  Future<void> _generatePDF() async {
    final invoice = Provider.of<InvoiceServices>(context, listen: false);
    final data = invoice.earningData;

    if (data == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Invoice Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                data['user_name'] != null ? "Report for ${data['user_name']}" : "Report for User",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                "Date Range: ${_formatDate(startDate)} to ${_formatDate(endDate)}",
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey),
                columnWidths: {0: pw.FlexColumnWidth(3), 1: pw.FlexColumnWidth(2)},
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Total Tickets Sold')),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${data['totalTickets'] ?? 0}')),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Total Sales Amount')),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(_formatCurrency(data['totalSalesAmount'])),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Commission')),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_formatCurrency(data['commission']))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Total Paid Amount')),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(_formatCurrency(data['totalPaidAmount'])),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Total Revenue')),
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_formatCurrency(data['totalRevenue']))),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Company Paid Amount')),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(_formatCurrency(data['companyPaidAmount'])),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text('Company Payment', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          _formatCurrency(data['companyPayment']),
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Text(
                'Generated on: ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
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
                        reportTypeOptions.entries
                            .map((entry) => DropdownMenuItem(value: entry.value, child: AppText(entry.key)))
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          reportType = value;
                          _setDefaultDates();
                        });
                      }
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Consumer<InvoiceServices>(
                  builder: (context, invoice, child) {
                    return PrimaryButton(
                      isLoading: invoice.isLoading,
                      onTap: () async {
                        final success = await invoice.postEarning(reportType, startDate: startDate, endDate: endDate);
                        if (success) {
                          setState(() {}); // Refresh UI after successful API call
                        }
                        print('Report Type: $reportType');
                        print('Start Date: $startDate');
                        print('End Date: $endDate');
                      },
                      height: 50.h,
                      width: 100.h,
                      title: 'Check',
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Date Selection Section
            if (reportType == 'weekly')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText("Date Range", fontWeight: FontWeight.bold),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, true),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16.sp),
                                SizedBox(width: 8.w),
                                AppText(startDate != null ? _formatDate(startDate) : 'Start Date', fontSize: 14.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _selectDate(context, false),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16.sp),
                                SizedBox(width: 8.w),
                                AppText(endDate != null ? _formatDate(endDate) : 'End Date', fontSize: 14.sp),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),

            SizedBox(height: 30.h),

            // Report Table Section - Dynamic Data
            Consumer<InvoiceServices>(
              builder: (context, invoice, child) {
                final data = invoice.earningData;

                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: secondaryColor, width: 2.w),
                  ),
                  padding: EdgeInsets.all(8.r),
                  margin: EdgeInsets.symmetric(vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        data?['user_name'] != null ? "Report for ${data!['user_name']}" : "Report for User",
                        fontWeight: FontWeight.bold,
                      ),
                      SizedBox(height: 4.h),
                      AppText("Date Range: ${_formatDate(startDate)} to ${_formatDate(endDate)}", fontSize: 12.sp),
                      SizedBox(height: 10.h),
                      Table(
                        border: TableBorder.all(color: primaryColor, borderRadius: BorderRadius.circular(6.r)),
                        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2)},
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText("Total Tickets Sold", fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText("${data?['totalTickets'] ?? 0}", textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText("Total Sales Amount", fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText(_formatCurrency(data?['totalSalesAmount']), textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText("Commission", fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText(_formatCurrency(data?['commission']), textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText("Total Paid Amount", fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText(_formatCurrency(data?['totalPaidAmount']), textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText("Total Revenue", fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText(_formatCurrency(data?['totalRevenue']), textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText("Company Paid Amount", fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText(_formatCurrency(data?['companyPaidAmount']), textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText("Company Payment", fontWeight: FontWeight.bold),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: AppText(_formatCurrency(data?['companyPayment']), textAlign: TextAlign.right),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            // Print Invoice Button
            Consumer<InvoiceServices>(
              builder: (context, invoice, child) {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: invoice.earningData != null ? _generatePDF : null,
                    child: Opacity(
                      opacity: invoice.earningData != null ? 1.0 : 0.5,
                      child: Ink(
                        height: 50.h,
                        width: 120.w,
                        decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(8.r)),
                        child: Center(child: AppText('Print Invoice', fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
