import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_snackbar.dart';
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

class _InvoicePageState extends State<InvoicePage> with TickerProviderStateMixin {
  String reportType = 'weekly';
  DateTime? startDate;
  DateTime? endDate;
  bool showInvoice = false;
  bool isPrinting = false;
  Map<String, dynamic>? invoiceData;

  final Map<String, String> reportTypeOptions = {'Weekly': 'weekly', 'Daily': 'daily'};
  late AnimationController slideController;
  late AnimationController fadeController;
  late AnimationController printController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<Offset> printSlideAnimation;

  final GlobalKey invoiceKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _setDefaultDates();

    // Initialize animation controllers
    slideController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    fadeController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    printController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOutCubic));

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: fadeController, curve: Curves.easeIn));

    printSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -1.0),
    ).animate(CurvedAnimation(parent: printController, curve: Curves.easeInOut));

    // Initialize the printing plugin
    // Printing.initialize();
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
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

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return '';
      return '${parsed.day}/${parsed.month}/${parsed.year}';
    }
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return '';
  }

  String _formatCurrency(dynamic amount, {int? number}) {
    if (amount == null) return 'AED 0.00';
    return 'AED ${double.tryParse(amount.toString())?.toStringAsFixed(number ?? 2) ?? '0.00'}';
  }

  void showInvoiceAnimation() {
    setState(() {
      showInvoice = true;
    });
    slideController.forward();
    fadeController.forward();
  }

  void hideInvoice() {
    setState(() {
      showInvoice = false;
    });
    slideController.reset();
    fadeController.reset();
    printController.reset();
  }

  Future<void> _generatePDF() async {
    final invoice = Provider.of<InvoiceServices>(context, listen: false);
    final data = invoice.earningData;

    if (data == null) {
      AppSnackbar.showErrorSnackbar('No invoice data available');
      return;
    }

    setState(() {
      invoiceData = data;
    });

    showInvoiceAnimation();

    setState(() {
      isPrinting = true;
    });

    try {
      HapticFeedback.lightImpact();
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
                  data['candidate']?['name'] != null ? "Report for ${data['candidate']['name']}" : "Report for User",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Date Range: ${_formatDate(data['startDate'])} to ${_formatDate(data['endDate'])}",
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
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Tickets Sold')),
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('${data['totalTickets'] ?? 0}')),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Sales Amount')),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatCurrency(data['totalSalesAmount'])),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Commission')),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatCurrency(data['commission'])),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Paid Amount')),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatCurrency(data['totalPaidAmount'])),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Total Revenue')),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatCurrency(data['totalRevenue'])),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text('Company Paid Amount')),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(_formatCurrency(data['companyPaidAmount'])),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Company Payment', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
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

      // Get available printers with error handling
      final printers = await Printing.listPrinters().catchError((e) {
        log('Error listing printers: $e');
        return <Printer>[]; // Return empty list if plugin fails
      });
      final printer = printers.isNotEmpty ? printers.first : null;

      if (printer == null) {
        throw Exception('No printer available. Please connect a printer or test on a physical device.');
      }

      // Directly print the PDF
      await Printing.directPrintPdf(
        printer: printer,
        format: PdfPageFormat.a4,
        onLayout: (PdfPageFormat format) => pdf.save(),
      );
      printController.forward();
      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        AppSnackbar.showSuccessSnackbar('Invoice printed successfully!');
      }
    } catch (e) {
      log('Error preparing print: $e');
      if (mounted) {
        AppSnackbar.showErrorSnackbar(
          e is MissingPluginException
              ? 'Printing is not supported on this device/emulator. Test on a physical device with a printer.'
              : 'Error preparing print: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isPrinting = false;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            hideInvoice();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    slideController.dispose();
    fadeController.dispose();
    printController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: AppText('Invoice', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        icon: const Icon(Icons.keyboard_arrow_down_outlined),
                        value: reportType,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: primaryColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
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
                            final success = await invoice.postEarning(
                              reportType,
                              startDate: startDate,
                              endDate: endDate,
                            );
                            if (success) {
                              setState(() {});
                            }
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
                              child: _dateBox(_formatDate(startDate), 'Start Date'),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(context, false),
                              child: _dateBox(_formatDate(endDate), 'End Date'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                Consumer<InvoiceServices>(
                  builder: (context, invoice, child) {
                    final data = invoice.earningData;

                    return data == null
                        ? const SizedBox.shrink()
                        : Container(
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
                                "Report for ${data['candidate']?['name'] ?? 'User'}",
                                fontWeight: FontWeight.bold,
                              ),
                              SizedBox(height: 4.h),
                              AppText(
                                "Date Range: ${_formatDate(data['startDate'])} to ${_formatDate(data['endDate'])}",
                                fontSize: 12.sp,
                              ),
                              SizedBox(height: 10.h),
                              Table(
                                border: TableBorder.all(color: primaryColor, borderRadius: BorderRadius.circular(6.r)),
                                columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(2)},
                                children: [
                                  tableRow("Total Tickets Sold", "${data['totalTickets'] ?? 0}"),
                                  tableRow("Total Sales Amount", _formatCurrency(data['totalSalesAmount'], number: 0)),
                                  tableRow("Commission", _formatCurrency(data['commission'])),
                                  tableRow("Total Paid Amount", _formatCurrency(data['totalPaidAmount'])),
                                  tableRow("Total Revenue", _formatCurrency(data['totalRevenue'])),
                                  tableRow("Company Paid Amount", _formatCurrency(data['companyPaidAmount'])),
                                  tableRow("Company Payment", _formatCurrency(data['companyPayment'])),
                                ],
                              ),
                              SizedBox(height: 10.h),
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
                                          decoration: BoxDecoration(
                                            color: secondaryColor,
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Center(child: AppText('Print Invoice', fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
          if (showInvoice && invoiceData != null)
            GestureDetector(
              onTap: hideInvoice,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
                child: SlideTransition(
                  position: printSlideAnimation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: FadeTransition(
                      opacity: fadeAnimation,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.r),
                              topRight: Radius.circular(24.r),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 12.h),
                                width: 40.w,
                                height: 4.h,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(20.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText('Invoice Report', fontSize: 20.sp, fontWeight: FontWeight.bold),
                                    GestureDetector(
                                      onTap: hideInvoice,
                                      child: Icon(Icons.close, size: 24.sp, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: RepaintBoundary(
                                  key: invoiceKey,
                                  child: SingleChildScrollView(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 16.h),
                                        AppText(
                                          "Report for ${invoiceData!['candidate']?['name'] ?? 'User'}",
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        SizedBox(height: 8.h),
                                        AppText(
                                          "Date Range: ${_formatDate(invoiceData!['startDate'])} to ${_formatDate(invoiceData!['endDate'])}",
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(height: 16.h),
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey[300]!),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Column(
                                            children: [
                                              _infoRow('Total Tickets Sold', '${invoiceData!['totalTickets'] ?? 0}'),
                                              Divider(),
                                              _infoRow(
                                                'Total Sales Amount',
                                                _formatCurrency(invoiceData!['totalSalesAmount']),
                                              ),
                                              Divider(),
                                              _infoRow('Commission', _formatCurrency(invoiceData!['commission'])),
                                              Divider(),
                                              _infoRow(
                                                'Total Paid Amount',
                                                _formatCurrency(invoiceData!['totalPaidAmount']),
                                              ),
                                              Divider(),
                                              _infoRow('Total Revenue', _formatCurrency(invoiceData!['totalRevenue'])),
                                              Divider(),
                                              _infoRow(
                                                'Company Paid Amount',
                                                _formatCurrency(invoiceData!['companyPaidAmount']),
                                              ),
                                              Divider(),
                                              _infoRow(
                                                'Company Payment',
                                                _formatCurrency(invoiceData!['companyPayment']),
                                                isHighlighted: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 24.h),
                                        AppText(
                                          'Generated on: ${DateTime.now().toString().split('.')[0]}',
                                          fontSize: 12.sp,
                                          color: Colors.grey[600],
                                        ),
                                        SizedBox(height: 24.h),
                                        if (isPrinting) ...[
                                          Container(
                                            padding: EdgeInsets.all(16.w),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12.r),
                                              border: Border.all(color: primaryColor.withOpacity(0.3)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 20.w,
                                                  height: 20.h,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                                  ),
                                                ),
                                                SizedBox(width: 12.w),
                                                AppText(
                                                  'Printing invoice...',
                                                  fontSize: 16.sp,
                                                  color: primaryColor,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 24.h),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dateBox(String text, String placeholder) {
    return Container(
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
          AppText(text.isNotEmpty ? text : placeholder, fontSize: 14.sp),
        ],
      ),
    );
  }

  TableRow tableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: AppText(label, fontWeight: FontWeight.bold)),
        Padding(padding: const EdgeInsets.all(8.0), child: AppText(value, textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, fontSize: 14.sp, fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal),
          AppText(
            value,
            fontSize: 14.sp,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            color: isHighlighted ? Colors.green[800] : null,
          ),
        ],
      ),
    );
  }
}
