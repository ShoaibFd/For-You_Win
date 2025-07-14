// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/dashboard/dashboard_services.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.pageName});
  final String pageName;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardServices>();
      provider.fetchHistory(widget.pageName);
    });
  }

  bool hasTicketsData(DashboardServices product) {
    return product.ticketHistoryData != null && product.ticketHistoryData!.tickets.isNotEmpty;
  }

  String _safeToString(dynamic value) {
    if (value == null) return 'N/A';

    // Check if it's a DateTime or looks like one
    if (value is DateTime) {
      return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    }

    if (value is String && value.contains('T')) {
      try {
        final date = DateTime.parse(value);
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } catch (_) {
        return value;
      }
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: AppText('Tickets History', fontSize: 16.sp, fontWeight: FontWeight.w600)),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
        child: Consumer<DashboardServices>(
          builder: (context, product, child) {
            if (product.isLoading) {
              return const Center(child: AppLoading());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText('Your Tickets for ${widget.pageName}', fontSize: 18),
                SizedBox(height: 10.h),

                hasTicketsData(product)
                    ? Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () => _printAllTicketDetails(context, product),
                        child: Container(
                          height: 30.h,
                          width: 70.w,
                          decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(20.r)),
                          child: Center(child: AppText('Print All', fontSize: 13.sp)),
                        ),
                      ),
                    )
                    : SizedBox.shrink(),

                SizedBox(height: 10.h),

                Expanded(
                  child:
                      !hasTicketsData(product)
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, color: Colors.redAccent.withOpacity(0.7), size: 40.sp),
                                SizedBox(height: 16.h),
                                AppText(
                                  'Oops! No Data Found',
                                  color: Colors.redAccent.withOpacity(0.8),
                                  fontSize: 15.sp,
                                ),
                                SizedBox(height: 8.h),
                                AppText(
                                  'Please check back later or contact support if this issue persists.',
                                  color: Colors.grey,
                                  fontSize: 13.sp,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                          : SingleChildScrollView(
                            child: Column(
                              children: [
                                ...product.ticketHistoryData!.tickets.reversed.toList().asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final ticket = entry.value;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                                        decoration: BoxDecoration(
                                          color: secondaryColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8.r),
                                          border: Border.all(color: secondaryColor.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            AppText(
                                              'Ticket ${index + 1}',
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            GestureDetector(
                                              onTap: () => _printSingleTicketDetails(context, ticket, index + 1),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                                decoration: BoxDecoration(
                                                  color: secondaryColor,
                                                  borderRadius: BorderRadius.circular(15.r),
                                                ),
                                                child: AppText('Print', fontSize: 12.sp),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      // Ticket Table!!
                                      ticketTable(ticket),
                                      SizedBox(height: 16.h),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                ),

                SizedBox(height: 16.h),

                hasTicketsData(product)
                    ? AppText(
                      'Showing Results 1 to ${product.ticketHistoryData!.tickets.length} of ${product.ticketHistoryData!.tickets.length} Entries',
                    )
                    : SizedBox.shrink(),

                SizedBox(height: 16.h),

                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.keyboard_double_arrow_left_outlined),
                      label: AppText('Back to Products'),
                      style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, foregroundColor: Colors.black),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget ticketTable(dynamic ticket) {
    final isAnnounced = ticket.isAnnounced == true;
    final isPaid = ticket.orderStatus == 1;

    final List<MapEntry<String, Widget>> rows = [
      MapEntry('Order Number', AppText(_safeToString(ticket.orderNumber))),
      MapEntry('Order Date', AppText(_safeToString(ticket.orderDate))),
      MapEntry('Draw Date', AppText(_safeToString(ticket.drawDate))),
      MapEntry('Status', AppText(isPaid ? 'Paid' : 'Purchased', color: isPaid ? Colors.blue : secondaryColor)),
      MapEntry('Prize', AppText(_safeToString(ticket.raffleDrawPrize))),
      MapEntry('Numbers', AppText(_safeToString(ticket.numbers))),
      MapEntry('Straight', AppText(_safeToString(ticket.straight))),
      MapEntry('Rumble', AppText(_safeToString(ticket.rumble))),
      MapEntry('Chance', AppText(_safeToString(ticket.chance))),
      MapEntry(
        'Ticket Announced',
        AppText(isAnnounced ? 'Announced' : 'Not Announced', color: isAnnounced ? Colors.blue : secondaryColor),
      ),
    ];

    return Table(
      border: TableBorder.all(color: secondaryColor, width: 1.5, borderRadius: BorderRadius.circular(8.r)),
      columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
      children: List.generate(rows.length ~/ 2, (index) {
        return TableRow(
          children: [
            tableCell(rows[index * 2].key, rows[index * 2].value),
            tableCell(rows[index * 2 + 1].key, rows[index * 2 + 1].value),
          ],
        );
      }),
    );
  }

  Widget tableCell(String label, Widget child) {
    return Container(
      height: 90.h,
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [AppText(label, fontWeight: FontWeight.normal), SizedBox(height: 4.h), child],
      ),
    );
  }

  Future<void> _printSingleTicketDetails(BuildContext context, dynamic ticket, int ticketNumber) async {
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => _generateSingleTicketPdf(ticket, ticketNumber),
        name: 'Ticket_${ticketNumber}_${_safeToString(ticket.orderNumber)}',
      );
    } catch (e) {
      AppSnackbar.showErrorSnackbar('Error printing: $e');
    }
  }

  Future<void> _printAllTicketDetails(BuildContext context, DashboardServices product) async {
    if (!hasTicketsData(product)) {
      AppSnackbar.showErrorSnackbar('No ticket data to print');
      return;
    }

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => _generateAllTicketsPdf(product.ticketHistoryData!.tickets),
        name: 'All_Tickets_${widget.pageName}',
      );
    } catch (e) {
      AppSnackbar.showErrorSnackbar('Error printing: $e');
    }
  }

  Future<Uint8List> _generateSingleTicketPdf(dynamic ticket, int ticketNumber) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(color: PdfColors.grey300, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Ticket $ticketNumber Details for ${widget.pageName}',
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Generated on: ${DateTime.now().toString().split('.')[0]}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey600, width: 1),
                columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
                children: [
                  tableRow('Order Number', _safeToString(ticket.orderNumber)),
                  tableRow('Order Date', _safeToString(ticket.orderDate)),
                  tableRow('Draw Date', _safeToString(ticket.drawDate)),
                  tableRow('Status', _safeToString(ticket.orderStatus)),
                  tableRow('Prize', _safeToString(ticket.raffleDrawPrize)),
                  tableRow('Numbers', _safeToString(ticket.numbers)),
                  tableRow('Straight', _safeToString(ticket.straight)),
                  tableRow('Rumble', _safeToString(ticket.rumble)),
                  tableRow('Chance', _safeToString(ticket.chance)),
                  tableRow('Is Announced', _safeToString(ticket.isAnnounced)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Text(
                  'This is an official ticket record generated from the system.',
                  style: const pw.TextStyle(fontSize: 10),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> _generateAllTicketsPdf(List<dynamic> tickets) async {
    final pdf = pw.Document();

    for (int i = 0; i < tickets.length; i++) {
      final ticket = tickets[i];

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(color: PdfColors.grey300, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Ticket ${i + 1} of ${tickets.length} - ${widget.pageName}',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Generated on: ${DateTime.now().toString().split('.')[0]}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey600, width: 1),
                  columnWidths: const {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
                  children: [
                    tableRow('Order Number', _safeToString(ticket.orderNumber)),
                    tableRow('Order Date', _safeToString(ticket.orderDate)),
                    tableRow('Draw Date', _safeToString(ticket.drawDate)),
                    tableRow('Status', _safeToString(ticket.orderStatus)),
                    tableRow('Prize', _safeToString(ticket.raffleDrawPrize)),
                    tableRow('Numbers', _safeToString(ticket.numbers)),
                    tableRow('Straight', _safeToString(ticket.straight)),
                    tableRow('Rumble', _safeToString(ticket.rumble)),
                    tableRow('Chance', _safeToString(ticket.chance)),
                    tableRow('Is Announced', _safeToString(ticket.isAnnounced)),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Text(
                    'This is an official ticket record generated from the system.',
                    style: const pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  pw.TableRow tableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 23)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 23)),
        ),
      ],
    );
  }
}
