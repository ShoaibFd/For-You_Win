import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class LotteryPrintService {
  static const MethodChannel _channel = MethodChannel('sunmi_printer');

  /// Print consolidated lottery invoice with total amount and ticket count
  static Future<bool> printLotteryInvoice({
    required String orderNumber,
    required String purchasedBy,
    required String amount,
    required String drawDate,
    String? additionalInfo, // ✅ NEW: For ticket count info
    int? ticketCount, // ✅ NEW: Number of winning tickets
    List<Map<String, dynamic>>? individualTickets, // ✅ NEW: Individual ticket details
  }) async {
    try {
      log('Starting consolidated lottery invoice print...');

      // Check if running on Sunmi device
      bool isSunmiDevice = await _checkSunmiDevice();
      if (!isSunmiDevice) {
        log('Not a Sunmi device, skipping print');
        return true;
      }

      // Initialize printer
      await _initPrinter();

      // Print header
      await _printHeader(ticketCount: ticketCount);

      // Print lottery invoice content
      await _printLotteryContent(
        orderNumber: orderNumber,
        purchasedBy: purchasedBy,
        amount: amount,
        drawDate: drawDate,
        additionalInfo: additionalInfo,
        ticketCount: ticketCount,
        individualTickets: individualTickets,
      );

      // Print footer
      await _printFooter();

      // Cut paper
      await _cutPaper();

      log('Consolidated lottery invoice printed successfully');
      return true;
    } catch (e) {
      log('Lottery print error: $e');
      return false;
    }
  }

  /// Generate PDF for consolidated lottery invoice
  static Future<String> generateLotteryPdfInvoice({
    required String orderNumber,
    required String purchasedBy,
    required String amount,
    required String drawDate,
    String? additionalInfo,
    int? ticketCount,
    List<Map<String, dynamic>>? individualTickets,
  }) async {
    try {
      log('Generating consolidated lottery PDF invoice...');
      final pdf = pw.Document();

      // Load image from assets
      final ByteData bytes = await rootBundle.load('assets/images/logo.png');
      final Uint8List imageBytes = bytes.buffer.asUint8List();
      final pw.ImageProvider image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header with logo
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Image(image, height: 60),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        ticketCount != null && ticketCount > 1 ? 'CONSOLIDATED WINNING VOUCHER' : 'WINNING VOUCHER',
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.green),
                      ),
                      if (ticketCount != null && ticketCount > 1)
                        pw.Text(
                          '($ticketCount Winning Tickets)',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.blue),
                        ),
                      pw.SizedBox(height: 10),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // ✅ NEW: Summary section for multiple tickets
                if (ticketCount != null && ticketCount > 1) ...[
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50,
                      border: pw.Border.all(color: PdfColors.blue200),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'CONSOLIDATED SUMMARY',
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                        ),
                        pw.SizedBox(height: 10),
                        lotteryPdfRow('Total Winning Tickets:', '$ticketCount', bold: true),
                        pw.SizedBox(height: 5),
                        lotteryPdfRow('Total Prize Amount:', amount, bold: true, highlight: true),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                ],

                // Order information
                pw.Container(
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('ORDER DETAILS', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 15),
                      lotteryPdfRow('Order Number:', orderNumber, bold: true),
                      pw.SizedBox(height: 10),
                      lotteryPdfRow('Draw Date:', drawDate),
                      pw.SizedBox(height: 10),
                      lotteryPdfRow('Agent Name:', purchasedBy),
                      pw.SizedBox(height: 10),
                      lotteryPdfRow('Total Prize Amount:', amount, bold: true, highlight: true),
                      pw.SizedBox(height: 10),
                      lotteryPdfRow('Payment Date:', DateTime.now().toString().split(' ')[0]),
                      if (additionalInfo != null) ...[
                        pw.SizedBox(height: 10),
                        lotteryPdfRow('Additional Info:', additionalInfo),
                      ],
                    ],
                  ),
                ),

                // ✅ NEW: Individual ticket breakdown (if multiple tickets)
                if (individualTickets != null && individualTickets.isNotEmpty && ticketCount! > 1) ...[
                  pw.SizedBox(height: 20),
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(15),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'INDIVIDUAL TICKET BREAKDOWN',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.SizedBox(height: 15),
                        ...individualTickets.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ticket = entry.value;
                          final ticketAmount = ticket['matched_price']?.toString() ?? '0';

                          return pw.Container(
                            margin: pw.EdgeInsets.only(bottom: 8),
                            padding: pw.EdgeInsets.all(8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              border: pw.Border.all(color: PdfColors.grey200),
                              borderRadius: pw.BorderRadius.circular(4),
                            ),
                            child: pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'Ticket #${index + 1}:',
                                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.Text(
                                  'AED $ticketAmount',
                                  style: pw.TextStyle(fontSize: 12, color: PdfColors.green700),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                pw.SizedBox(height: 30),

                // ✅ ENHANCED: Congratulations message
                pw.Container(
                  width: double.infinity,
                  padding: pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(color: PdfColors.green100, borderRadius: pw.BorderRadius.circular(8)),
                  child: pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          '🎉 CONGRATULATIONS! YOU ARE A WINNER! 🎉',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                          textAlign: pw.TextAlign.center,
                        ),
                        if (ticketCount != null && ticketCount > 1) ...[
                          pw.SizedBox(height: 8),
                          pw.Text(
                            'You have won on $ticketCount tickets!',
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green700,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Keep playing for more chances to win!',
                          style: pw.TextStyle(fontSize: 12, color: PdfColors.green600),
                          textAlign: pw.TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(height: 20),

                // Footer info
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'For You Win - Your Gateway to Fortune',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Website: https://foryouwin.com/user/login',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final fileName =
          ticketCount != null && ticketCount > 1
              ? 'consolidated_lottery_receipt_$orderNumber.pdf'
              : 'lottery_receipt_$orderNumber.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      log('Consolidated lottery PDF generated: ${file.path}');
      return file.path;
    } catch (e) {
      log('Lottery PDF generation error: $e');
      return '';
    }
  }

  // Private helper methods
  static Future<bool> _checkSunmiDevice() async {
    try {
      final result = await _channel.invokeMethod('checkSunmiDevice');
      return result == true;
    } catch (e) {
      log('Device check error: $e');
      return false;
    }
  }

  static Future<void> _initPrinter() async {
    try {
      await _channel.invokeMethod('initPrinter');
      log('Lottery printer initialized');
    } catch (e) {
      log('Lottery printer init error: $e');
      throw Exception('Failed to initialize printer');
    }
  }

  // ✅ ENHANCED: Header with ticket count info
  static Future<void> _printHeader({int? ticketCount}) async {
    try {
      await _channel.invokeMethod('printText', {'text': 'FOR YOU WIN', 'size': 24, 'align': 'center', 'bold': true});

      if (ticketCount != null && ticketCount > 1) {
        await _channel.invokeMethod('printText', {
          'text': 'CONSOLIDATED WINNING RECEIPT',
          'size': 16,
          'align': 'center',
          'bold': true,
        });
        await _channel.invokeMethod('printText', {
          'text': '($ticketCount Winning Tickets)',
          'size': 14,
          'align': 'center',
          'bold': true,
        });
      } else {
        await _channel.invokeMethod('printText', {
          'text': 'WINNING RECEIPT',
          'size': 18,
          'align': 'center',
          'bold': true,
        });
      }

      await _channel.invokeMethod('printLine');
      await _channel.invokeMethod('printNewLine');
    } catch (e) {
      log('Header print error: $e');
    }
  }

  // ✅ ENHANCED: Content with consolidated information
  static Future<void> _printLotteryContent({
    required String orderNumber,
    required String purchasedBy,
    required String amount,
    required String drawDate,
    String? additionalInfo,
    int? ticketCount,
    List<Map<String, dynamic>>? individualTickets,
  }) async {
    try {
      // Print summary for multiple tickets
      if (ticketCount != null && ticketCount > 1) {
        await _channel.invokeMethod('printText', {
          'text': '=== CONSOLIDATED SUMMARY ===',
          'size': 14,
          'align': 'center',
          'bold': true,
        });
        await _printLotteryRow('Total Winning Tickets:', '$ticketCount');
        await _printLotteryRow('Total Prize Amount:', amount);
        await _channel.invokeMethod('printLine');
        await _channel.invokeMethod('printNewLine');
      }

      // Print order details
      await _channel.invokeMethod('printText', {
        'text': '=== ORDER DETAILS ===',
        'size': 14,
        'align': 'center',
        'bold': true,
      });

      await _printLotteryRow('Order Number:', orderNumber);
      await _printLotteryRow('Purchased By:', purchasedBy);
      await _printLotteryRow('Total Prize Amount:', amount);
      await _printLotteryRow('Draw Date:', drawDate);
      await _printLotteryRow('Payment Date:', DateTime.now().toString().split(' ')[0]);

      if (additionalInfo != null) {
        await _printLotteryRow('Info:', additionalInfo);
      }

      await _channel.invokeMethod('printNewLine');

      // Print individual ticket breakdown for multiple tickets
      if (individualTickets != null && individualTickets.isNotEmpty && ticketCount! > 1) {
        await _channel.invokeMethod('printText', {
          'text': '=== TICKET BREAKDOWN ===',
          'size': 16,
          'align': 'center',
          'bold': true,
        });

        for (int i = 0; i < individualTickets.length; i++) {
          final ticket = individualTickets[i];
          final ticketAmount = ticket['matched_price']?.toString() ?? '0';
          await _printLotteryRow('Ticket #${i + 1}:', 'AED $ticketAmount');
        }
        await _channel.invokeMethod('printNewLine');
      }

      // Print congratulations message
      await _channel.invokeMethod('printText', {
        'text': '🎉 CONGRATULATIONS! 🎉',
        'size': 22,
        'align': 'center',
        'bold': true,
      });

      if (ticketCount != null && ticketCount > 1) {
        await _channel.invokeMethod('printText', {
          'text': 'YOU WON ON $ticketCount TICKETS!',
          'size': 20,
          'align': 'center',
          'bold': true,
        });
      } else {
        await _channel.invokeMethod('printText', {
          'text': 'YOU ARE A WINNER!',
          'size': 20,
          'align': 'center',
          'bold': true,
        });
      }

      await _channel.invokeMethod('printText', {
        'text': 'Keep playing for more wins!',
        'size': 16,
        'align': 'center',
        'bold': false,
      });

      await _channel.invokeMethod('printNewLine');
    } catch (e) {
      log('Lottery content print error: $e');
    }
  }

  static Future<void> _printLotteryRow(String label, String value) async {
    try {
      await _channel.invokeMethod('printText', {'text': '$label $value', 'size': 18, 'align': 'left', 'bold': false});
    } catch (e) {
      log('Row print error: $e');
    }
  }

  static Future<void> _printFooter() async {
    try {
      await _channel.invokeMethod('printLine');
      await _channel.invokeMethod('printText', {
        'text': 'For You Win - Your Gateway to Fortune',
        'size': 16,
        'align': 'center',
        'bold': false,
      });
      await _channel.invokeMethod('printText', {
        'text': 'Website: https://foryouwin.com/user/login',
        'size': 16,
        'align': 'center',
        'bold': false,
      });
      await _channel.invokeMethod('printNewLine');
      await _channel.invokeMethod('printText', {
        'text': 'Thank you for playing!',
        'size': 16,
        'align': 'center',
        'bold': false,
      });
      await _channel.invokeMethod('printNewLine');
    } catch (e) {
      log('Footer print error: $e');
    }
  }

  static Future<void> _cutPaper() async {
    try {
      await _channel.invokeMethod('cutPaper');
      log('Paper cut completed');
    } catch (e) {
      log('Paper cut error: $e');
    }
  }

  // ✅ ENHANCED: PDF row with highlighting option
  static pw.Widget lotteryPdfRow(String title, String value, {bool bold = false, bool highlight = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 30, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 30,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: highlight ? PdfColors.green700 : PdfColors.black,
          ),
        ),
      ],
    );
  }
}
