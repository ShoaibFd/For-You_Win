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
    final provider = context.read<DashboardServices>();
    final name = provider.dashboardData?.data?.products?.data.last.name;
    Provider.of<DashboardServices>(context).fetchHistory(name ?? "");
    super.initState();
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
                AppText('Your Tickets for ${widget.pageName}', fontWeight: FontWeight.bold, fontSize: 18),
                SizedBox(height: 10.h),
                Align(
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
                ),
                SizedBox(height: 10.h),
                Builder(
                  builder: (context) {
                    final tickets = product.ticketHistoryData?.tickets;
                    if (tickets == null || tickets.isEmpty) {
                      return const Center(child: AppText('No ticket data found'));
                    }
                    final List<MapEntry<String, String>> rows = [
                      MapEntry('Order Number', tickets.first.orderNumber.toString()),
                      MapEntry('Order Date', tickets.first.orderDate.toString()),
                      MapEntry('Draw Date', tickets.first.drawDate.toString()),
                      MapEntry('Status', tickets.first.orderStatus.toString()),
                      MapEntry('Prize', tickets.first.raffleDrawPrize.toString()),
                      MapEntry('Numbers', tickets.first.numbers.toString()),
                      MapEntry('Straight', tickets.first.straight.toString()),
                      MapEntry('Rumble', tickets.first.rumble.toString()),
                      MapEntry('Chance', tickets.first.chance.toString()),
                      MapEntry('Is Announced', tickets.first.isAnnounced.toString()),
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
                SizedBox(height: 16.h),
                AppText('Showing Results 1 to 1 of 1 Entries'),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.keyboard_double_arrow_left_outlined),
                      label: AppText('Back to Products'),
                      style: ElevatedButton.styleFrom(backgroundColor: secondaryColor, foregroundColor: Colors.black),
                    ),
                    // const Spacer(),
                    // AppText('Previous'),
                    // SizedBox(width: 8.w),
                    // CircleAvatar(radius: 14.r, backgroundColor: secondaryColor, child: AppText('1')),
                    // SizedBox(width: 8.w),
                    // AppText('Next'),
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
    final tickets = product.ticketHistoryData?.tickets;

    if (tickets == null || tickets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No ticket data to print')));
      return;
    }

    final ticket = tickets.first;

    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => _generatePdf(ticket),
        name: 'Ticket_${ticket.orderNumber}',
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
                  tableRow('Order Number', ticket.orderNumber.toString()),
                  tableRow('Order Date', ticket.orderDate.toString()),
                  tableRow('Draw Date', ticket.drawDate.toString()),
                  tableRow('Status', ticket.orderStatus.toString()),
                  tableRow('Prize', ticket.raffleDrawPrize.toString()),
                  tableRow('Numbers', ticket.numbers.toString()),
                  tableRow('Straight', ticket.straight.toString()),
                  tableRow('Rumble', ticket.rumble.toString()),
                  tableRow('Chance', ticket.chance.toString()),
                  tableRow('Is Announced', ticket.isAnnounced.toString()),
                ],
              ),

              pw.SizedBox(height: 30),

              // Message!!
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

  // Table Row Component!!
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
