import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_loading.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/components/primary_button.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:for_u_win/data/services/tickets/ticket_services.dart';
import 'package:for_u_win/pages/products/invoice_page/components/info_row.dart';
import 'package:for_u_win/pages/tickets/royal_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

class ThrillPage extends StatefulWidget {
  const ThrillPage({super.key});

  @override
  State<ThrillPage> createState() => _ThrillPageState();
}

class _ThrillPageState extends State<ThrillPage> with TickerProviderStateMixin {
  final searchController = TextEditingController();

  // Animation controllers for invoice functionality
  late AnimationController slideController;
  late AnimationController fadeController;
  late AnimationController printController;
  late Animation<Offset> slideAnimation;
  late Animation<double> fadeAnimation;
  late Animation<Offset> printSlideAnimation;

  bool isVisible = false;
  bool isPrinting = false;
  bool showInvoice = false;
  Map<String, dynamic>? invoiceData;
  String? paidTicketId;

  final GlobalKey invoiceKey = GlobalKey();

  @override
  void initState() {
    super.initState();

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
  }

  void showInvoiceAnimation() {
    setState(() {
      isVisible = true;
      showInvoice = true;
    });
    slideController.forward();
    fadeController.forward();
  }

  void hideInvoice() {
    setState(() {
      showInvoice = false;
      isVisible = false;
    });
    slideController.reset();
    fadeController.reset();
    printController.reset();
  }

  Future<void> handlePayment(TicketServices ticket, Map<String, dynamic> matchedTicket) async {
    // Process payment through ticket service, converting matched_price to String
    final ticketId = ticket.thrillTicketData!['tickets']['id'];
    await ticket.payTicket(ticketId, matchedTicket['matched_price'].toString());
    log('Ticket Id in Thrill Page: $ticketId');
    // Prepare invoice data
    invoiceData = {
      'ticket': matchedTicket,
      'orderNumber': ticket.thrillTicketData!['order_number'],
      'status': ticket.thrillTicketData!['status'],
      'hasWinners': ticket.thrillTicketData!['has_winners'],
    };

    showInvoiceAnimation();
    await handlePrint(matchedTicket);

    // Mark ticket as paid
    setState(() {
      paidTicketId = matchedTicket['ticket_id'].toString();
    });
  }

  Future<void> handlePrint(Map<String, dynamic> matchedTicket) async {
    setState(() {
      isPrinting = true;
    });

    try {
      HapticFeedback.lightImpact();
      final pdfData = await generatePdf(matchedTicket);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/thrill${matchedTicket['ticket_id']}.pdf');
      await file.writeAsBytes(pdfData);

      printController.forward();
      await Future.delayed(const Duration(milliseconds: 2000));

      if (mounted) {
        AppSnackbar.showSuccessSnackbar('Thrill ticket receipt printed successfully!');
      }
    } catch (e) {
      log('Error preparing print: $e');
      if (mounted) {
        AppSnackbar.showErrorSnackbar('Error preparing print: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isPrinting = false;
        });
        // Hide invoice after printing
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            hideInvoice();
          }
        });
      }
    }
  }

  String generateQRData(Map<String, dynamic> matchedTicket) {
    return 'TicketID:${matchedTicket['ticket_id']}|Product:${matchedTicket['product_name']}|DrawDate:${matchedTicket['draw_date']}|Prize:${matchedTicket['matched_price']}';
  }

  pw.Widget invoiceRow(String title, String value, {bool bold = false, double fontSize = 14}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(fontSize: fontSize, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  pw.Widget buildNumbersGrid(List<dynamic> numbers) {
    List<pw.Widget> rows = [];

    for (int i = 0; i < numbers.length; i += 6) {
      List<dynamic> rowNumbers = numbers.skip(i).take(6).toList();

      rows.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children:
              rowNumbers.map((number) {
                return pw.Container(
                  width: 35,
                  height: 35,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      number.toString().padLeft(2, '0'),
                      style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
        ),
      );

      if (i + 6 < numbers.length) {
        rows.add(pw.SizedBox(height: 6));
      }
    }

    return pw.Column(children: rows);
  }

  Future<Uint8List> generatePdf(Map<String, dynamic> matchedTicket) async {
    final bytes = await rootBundle.load('assets/images/logo.png');
    final image = pw.MemoryImage(bytes.buffer.asUint8List());

    // Convert numbers and matched_numbers from String to List if necessary
    List<dynamic> numbers =
        matchedTicket['numbers'] is String
            ? (matchedTicket['numbers'] as String).split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList()
            : (matchedTicket['numbers'] as List<dynamic>? ?? []);
    List<dynamic> matchedNumbers =
        matchedTicket['matched_numbers'] is String
            ? (matchedTicket['matched_numbers'] as String).split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList()
            : (matchedTicket['matched_numbers'] as List<dynamic>? ?? []);

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // Header
            pw.Center(child: pw.Image(image, height: 60, width: 120)),
            pw.SizedBox(height: 20),

            // Title
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Center(
                child: pw.Text(
                  'Thrill-3 Winning Ticket Receipt',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Ticket Information
            pw.Container(
              width: double.infinity,
              child: pw.Column(
                children: [
                  invoiceRow('Ticket ID:', matchedTicket['ticket_id'].toString(), fontSize: 14),
                  invoiceRow('Product Name:', matchedTicket['product_name'].toString(), fontSize: 14),
                  invoiceRow('Candidate:', matchedTicket['candidate'].toString(), fontSize: 14),
                  invoiceRow('Order Date:', matchedTicket['order_date'].toString(), fontSize: 14),
                  invoiceRow('Draw Date:', matchedTicket['draw_date'].toString(), fontSize: 14),
                  invoiceRow('Prize Amount:', 'AED ${matchedTicket['matched_price']}', bold: true, fontSize: 16),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Original Numbers
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(color: PdfColors.grey200, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(
                children: [
                  pw.Text('Your Numbers', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  buildNumbersGrid(numbers),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Matched Numbers
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(color: PdfColors.green100, borderRadius: pw.BorderRadius.circular(8)),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Winning Numbers',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                  ),
                  pw.SizedBox(height: 8),
                  buildNumbersGrid(matchedNumbers),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Congratulations message
            pw.Container(
              width: double.infinity,
              child: pw.Text(
                "🎉 Congratulations! You are a winner! 🎉",
                style: pw.TextStyle(fontSize: 18, color: PdfColors.red, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.SizedBox(height: 20),

            // QR Code
            pw.Center(
              child: pw.Column(
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: generateQRData(matchedTicket),
                    width: 120,
                    height: 120,
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    matchedTicket['ticket_id'].toString(),
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
          ];
        },
        footer:
            (context) => pw.Column(
              children: [
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                    "Thrill-3 - Your Gateway to Fortune",
                    style: pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  child: pw.Text(
                    "Website: https://foryouwin.com/user/login",
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.blue),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
      ),
    );

    return pdf.save();
  }

  @override
  void dispose() {
    slideController.dispose();
    fadeController.dispose();
    printController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: AppText('Thrill-3', fontSize: 16.sp, fontWeight: FontWeight.bold)),
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Consumer<TicketServices>(
              builder: (context, ticket, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Center(child: AppText('Thrill-3 Ticket Search', fontSize: 20.sp)),
                    SizedBox(height: 10.h),

                    // Search Field
                    SizedBox(
                      height: 55.h,
                      child: TextFormField(
                        controller: searchController,
                        cursorColor: secondaryColor,
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                            onTap: () {
                              final order = searchController.text.trim();
                              if (order.isNotEmpty) {
                                ticket.thrillTicketSearch(order);
                                log('Order number: $order');
                                // Reset paid ticket when searching new ticket
                                setState(() {
                                  paidTicketId = null;
                                });
                              }
                              searchController.clear();
                            },
                            child: Container(
                              width: 80.w,
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(child: AppText('Search', fontWeight: FontWeight.bold)),
                            ),
                          ),
                          filled: true,
                          fillColor: primaryColor,
                          hintText: 'Enter Order Number',
                          hintStyle: TextStyle(fontSize: 11.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Loading Indicator
                    if (ticket.isLoading) Center(child: AppLoading()),

                    // Display API data
                    if (ticket.thrillTicketData != null && !ticket.isLoading)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10.h),
                              AppText('Ticket Result:', fontSize: 18.sp),
                              SizedBox(height: 10.h),
                              dataRow(
                                'Status',
                                ticket.thrillTicketData!['status'].toString(),
                                valueColor: Colors.green,
                              ),
                              Divider(),
                              dataRow('Order Number', ticket.thrillTicketData!['order_number'].toString()),
                              Divider(),
                              dataRow('Has Winners', ticket.thrillTicketData!['has_winners'].toString()),

                              SizedBox(height: 20.h),
                              AppText('Matched Tickets:', fontSize: 18.sp),
                              SizedBox(height: 10.h),

                              ...ticket.thrillTicketData!['tickets']?.map<Widget>((matched) {
                                    // final ticketId = matched['id'].toString();
                                    final isPaid = matched['paid_by'] != null;

                                    final rows = [
                                      MapEntry('Candidate', matched['candidate']['name'].toString()),
                                      MapEntry('Ticket ID', matched['id'].toString()),
                                      MapEntry('Product', matched['product_name'].toString()),
                                      MapEntry('Order Number', matched['order_number'].toString()),
                                      MapEntry('Status', matched['order_status'].toString()),
                                      MapEntry('Winning Numbers', matched['numbers'].toString()),
                                      MapEntry('Matched Numbers', matched['matched_numbers'].toString()),
                                      MapEntry('Raffle Draw Prize', matched['raffle_draw_prize'].toString()),
                                      MapEntry('Matched Prize', matched['matched_prize'].toString()),
                                      MapEntry('Straight', matched['straight'].toString()),
                                      MapEntry('Rumble', matched['rumble'].toString()),
                                      MapEntry('Chance', matched['chance'].toString()),

                                      MapEntry('Draw Date', matched['draw_date'].toString()),
                                      MapEntry('Order Date', matched['order_date'].toString()),
                                    ];

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Table(
                                          border: TableBorder.all(
                                            color: isPaid ? Colors.green : secondaryColor,
                                            width: 1.2,
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(1)},
                                          children: List.generate((rows.length / 2).ceil(), (index) {
                                            final first = rows[index * 2];
                                            final second = index * 2 + 1 < rows.length ? rows[index * 2 + 1] : null;
                                            return TableRow(
                                              children: [
                                                tableCell('${first.key}\n${first.value}', isPaid: isPaid),
                                                tableCell(
                                                  second != null ? '${second.key}\n${second.value}' : '',
                                                  isPaid: isPaid,
                                                ),
                                              ],
                                            );
                                          }),
                                        ),
                                        SizedBox(height: 16.h),

                                        // Pay Now Button or Paid Status
                                        if (isPaid ||
                                            matched['order_status']?.toString().toLowerCase() == '1' ||
                                            matched['payment_status']?.toString().toLowerCase() == 'completed')
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.all(16.w),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12.r),
                                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
                                                SizedBox(width: 12.w),
                                                AppText(
                                                  'Payment Completed',
                                                  fontSize: 16.sp,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          PrimaryButton(
                                            isLoading: ticket.isLoading,
                                            onTap: () async {
                                              await handlePayment(ticket, matched);
                                            },
                                            title: 'Pay Now',
                                          ),

                                        SizedBox(height: 24.h),
                                      ],
                                    );
                                  }).toList() ??
                                  [AppText("No matched tickets found")],
                            ],
                          ),
                        ),
                      ),

                    if (!ticket.isLoading && ticket.thrillTicketData == null) SizedBox(),
                  ],
                );
              },
            ),
          ),

          // Invoice overlay
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
                                    AppText('Winning Receipt', fontSize: 20.sp, fontWeight: FontWeight.bold),
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
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Image.asset('assets/images/logo.png', height: 80.h),
                                        SizedBox(height: 16.h),
                                        Container(
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                            color: Colors.green[100],
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: AppText(
                                            '🎉 Thrill-3 Winner! 🎉',
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            textAlign: TextAlign.center,
                                            color: Colors.green[800],
                                          ),
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
                                              infoRow(
                                                'Candidate:',
                                                invoiceData!['ticket']['candidate']['name'].toString(),
                                              ),
                                              Divider(),
                                              infoRow('Ticket ID:', invoiceData!['ticket']['ticket_id'].toString()),
                                              Divider(),
                                              infoRow('Product:', invoiceData!['ticket']['product_name'].toString()),
                                              Divider(),

                                              infoRow(
                                                'Prize Amount:',
                                                'AED ${invoiceData!['ticket']['matched_price']}',
                                                isHighlighted: true,
                                              ),
                                              Divider(),
                                              infoRow('Order Date:', invoiceData!['ticket']['order_date'].toString()),
                                              Divider(),
                                              infoRow('Draw Date:', invoiceData!['ticket']['draw_date'].toString()),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 24.h),

                                        // Show numbers
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Column(
                                            children: [
                                              AppText('Your Numbers', fontSize: 16.sp, fontWeight: FontWeight.bold),
                                              SizedBox(height: 8.h),
                                              Wrap(
                                                spacing: 8.w,
                                                runSpacing: 8.h,
                                                children:
                                                    (invoiceData!['ticket']['numbers'] is String
                                                            ? (invoiceData!['ticket']['numbers'] as String)
                                                                .split(',')
                                                                .map((e) => int.tryParse(e.trim()) ?? 0)
                                                                .toList()
                                                            : (invoiceData!['ticket']['numbers'] as List<dynamic>? ??
                                                                []))
                                                        .map((number) {
                                                          return Container(
                                                            width: 35.w,
                                                            height: 35.h,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              border: Border.all(color: Colors.grey),
                                                            ),
                                                            child: Center(
                                                              child: AppText(
                                                                number.toString().padLeft(2, '0'),
                                                                fontSize: 12.sp,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          );
                                                        })
                                                        .toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 16.h),

                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Column(
                                            children: [
                                              AppText(
                                                'Winning Numbers',
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[800],
                                              ),
                                              SizedBox(height: 8.h),
                                              Wrap(
                                                spacing: 8.w,
                                                runSpacing: 8.h,
                                                children:
                                                    (invoiceData!['ticket']['matched_numbers'] is String
                                                            ? (invoiceData!['ticket']['matched_numbers'] as String)
                                                                .split(',')
                                                                .map((e) => int.tryParse(e.trim()) ?? 0)
                                                                .toList()
                                                            : (invoiceData!['ticket']['matched_numbers']
                                                                    as List<dynamic>? ??
                                                                []))
                                                        .map((number) {
                                                          return Container(
                                                            width: 35.w,
                                                            height: 35.h,
                                                            decoration: BoxDecoration(
                                                              shape: BoxShape.circle,
                                                              color: Colors.green,
                                                            ),
                                                            child: Center(
                                                              child: AppText(
                                                                number.toString().padLeft(2, '0'),
                                                                fontSize: 12.sp,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          );
                                                        })
                                                        .toList(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 24.h),

                                        // Congratulations message
                                        Container(
                                          padding: EdgeInsets.all(16.w),
                                          decoration: BoxDecoration(
                                            color: Colors.orange[50],
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: AppText(
                                            "🎉 Congratulations! You are a winner! Keep playing for more chances to win! 🎉",
                                            fontSize: 14.sp,
                                            color: Colors.orange[800],
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(height: 16.h),

                                        AppText(
                                          'Website: https://foryouwin.com/user/login',
                                          fontSize: 12.sp,
                                          color: Colors.blue,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 24.h),

                                        // Show printing status
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
                                                  'Printing receipt...',
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
}
