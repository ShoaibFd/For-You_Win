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
      final name = provider.dashboardData?.data?.products?.data.last.name;
      if (name != null) {
        provider.fetchHistory(name);
      } else {
        AppSnackbar.showErrorSnackbar('Product name not available');
      }
    });
  }

  // To Check If Tickets Are Available
  bool _hasTicketsData(DashboardServices product) {
    return product.ticketHistoryData != null && product.ticketHistoryData!.tickets.isNotEmpty;
  }

  // To Convert Values to String!!
  String _safeToString(dynamic value) {
    if (value == null) return 'N/A';
    if (value.toString().isEmpty) return 'N/A';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: AppText('Ticket History', fontSize: 16.sp, fontWeight: FontWeight.w600)),
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

                // Show print button only if data is available
                _hasTicketsData(product)
                    ? Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () => _printTicketDetails(context, product),
                        child: Container(
                          height: 30.h,
                          width: 70.w,
                          decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(20.r)),
                          child: Center(child: AppText('Print', fontSize: 15.sp)),
                        ),
                      ),
                    )
                    : SizedBox.shrink(),

                SizedBox(height: 10.h),

                // Main content area
                Expanded(
                  child:
                      !_hasTicketsData(product)
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
                            child: Builder(
                              builder: (context) {
                                final ticket = product.ticketHistoryData!.tickets.first;

                                final List<MapEntry<String, String>> rows = [
                                  MapEntry('Order Number', _safeToString(ticket.orderNumber)),
                                  MapEntry('Order Date', _safeToString(ticket.orderDate)),
                                  MapEntry('Draw Date', _safeToString(ticket.drawDate)),
                                  MapEntry('Status', _safeToString(ticket.orderStatus)),
                                  MapEntry('Prize', _safeToString(ticket.raffleDrawPrize)),
                                  MapEntry('Numbers', _safeToString(ticket.numbers)),
                                  MapEntry('Straight', _safeToString(ticket.straight)),
                                  MapEntry('Rumble', _safeToString(ticket.rumble)),
                                  MapEntry('Chance', _safeToString(ticket.chance)),
                                  MapEntry('Is Announced', _safeToString(ticket.isAnnounced)),
                                ];

                                return Table(
                                  border: TableBorder.all(
                                    color: secondaryColor,
                                    width: 1.5,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
                                  children: List.generate(rows.length ~/ 2, (index) {
                                    return TableRow(
                                      children: [
                                        tableCell('${rows[index * 2].key}\n${rows[index * 2].value}'),
                                        tableCell('${rows[index * 2 + 1].key}\n${rows[index * 2 + 1].value}'),
                                      ],
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                ),

                SizedBox(height: 16.h),

                // Results info - only show if data is available
                _hasTicketsData(product)
                    ? AppText(
                      'Showing Results 1 to ${product.ticketHistoryData!.tickets.length} of ${product.ticketHistoryData!.tickets.length} Entries',
                    )
                    : SizedBox.shrink(),

                SizedBox(height: 16.h),

                // Back button
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

  Widget tableCell(String text) {
    // Split the text at the first newline
    final parts = text.split('\n');
    final heading = parts.isNotEmpty ? parts[0] : '';
    final value = parts.length > 1 ? parts[1] : '';

    return Container(
      height: 90.h,
      padding: EdgeInsets.all(12.r),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(heading, fontWeight: FontWeight.normal),
          SizedBox(height: 4.h),
          AppText(value, fontWeight: FontWeight.bold),
        ],
      ),
    );
  }

  // Print functionality
  Future<void> _printTicketDetails(BuildContext context, DashboardServices product) async {
    if (!_hasTicketsData(product)) {
      AppSnackbar.showErrorSnackbar('No ticket data to print');
      return;
    }

    final ticket = product.ticketHistoryData!.tickets.first;

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => _generatePdf(ticket),
        name: 'Ticket_${_safeToString(ticket.orderNumber)}',
      );
    } catch (e) {
      AppSnackbar.showErrorSnackbar('Error printing: $e');
    }
  }

  Future<Uint8List> _generatePdf(dynamic ticket) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(color: PdfColors.grey300, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Ticket Details for ${widget.pageName}',
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

              // Ticket Information Table
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

              // Footer Message
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

  // Table Row Component for PDF
  pw.TableRow tableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          child: pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
