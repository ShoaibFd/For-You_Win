import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class SunmiPrintService {
  static bool _isInitialized = false;
  static const int _maxRetries = 3;
  static const int _statusDelayMs = 1000;
  static final SunmiPrinterPlus _printer = SunmiPrinterPlus();

  static Future<bool> _isSunmiDevice() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.manufacturer.toLowerCase().contains('sunmi');
      }
      return false;
    } catch (e) {
      debugPrint('Failed to check device type: $e');
      return false;
    }
  }

  // ✅ UPDATED: Generate QR data in the format expected by ScannerPage
  static String _generateQRData({required String orderNumber, required String productName, required String orderDate}) {
    return 'Order:$orderNumber|Product:$productName|Date:$orderDate';
  }

  static Future<void> _printAssetImage(String assetPath, {int width = 120}) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();

      await _printer.printImage(bytes, align: SunmiPrintAlign.CENTER);
      await _printer.lineWrap(times: 1);
      debugPrint('Asset image printed successfully (smaller size)');
    } catch (e) {
      debugPrint('Asset image printing failed: $e');
    }
  }

  static Future<void> _printProductImage(String? productImagePath) async {
    if (productImagePath == null || productImagePath.isEmpty) {
      await _printer.printText(
        text: '[4uwin Product]',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 10),
      );
      await _printer.lineWrap(times: 1);
      return;
    }

    try {
      final ByteData data = await rootBundle.load(productImagePath);
      final Uint8List bytes = data.buffer.asUint8List();

      await _printer.printImage(bytes, align: SunmiPrintAlign.CENTER);
      await _printer.lineWrap(times: 1);
      debugPrint('Product image printed successfully');
    } catch (e) {
      debugPrint('Product image printing failed: $e');
      await _printer.printText(
        text: '[Product Image]',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 10),
      );
      await _printer.lineWrap(times: 1);
    }
  }

  // ✅ UPDATED: Print ticket numbers with individual game types
  static Future<void> _printTicketNumbers(List<dynamic> numbers, List<Map<String, bool>>? gameTypes) async {
    await _printer.lineWrap(times: 1);

    if (numbers.isEmpty) {
      await _printer.printText(
        text: 'No ticket numbers',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
      );
      return;
    }

    List<String> displayNumbers = [];
    for (int i = 0; i < numbers.length && i < 6; i++) {
      String numStr = numbers[i].toString().trim();
      if (numStr.isNotEmpty && numStr != 'null') {
        if (numStr.length == 1) {
          numStr = '0$numStr';
        }
        displayNumbers.add(numStr);
      }
    }

    for (int i = 0; i < displayNumbers.length && i < 6; i++) {
      // Print ticket number
      await _printer.printText(
        text: ' ${i + 1}: ${displayNumbers[i]}',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 11, bold: true),
      );

      // Print game types for this ticket
      if (gameTypes != null && i < gameTypes.length) {
        String straight = gameTypes[i]['straight'] == true ? 'Yes' : 'No';
        String rumble = gameTypes[i]['rumble'] == true ? 'Yes' : 'No';
        String chance = gameTypes[i]['chance'] == true ? 'Yes' : 'No';

        await _printer.printText(
          text: '  S:$straight R:$rumble C:$chance',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 9),
        );
      }

      await _printer.lineWrap(times: 1);
    }

    if (numbers.length > 6) {
      await _printer.printText(
        text: 'and ${numbers.length - 6} more numbers',
        style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 9),
      );
    }
  }

  static pw.Widget ticketNumbers(List<dynamic> numbers, List<Map<String, bool>>? gameTypes) {
    if (numbers.isEmpty) {
      return pw.Text('No ticket numbers', style: const pw.TextStyle(fontSize: 10));
    }

    List<pw.Widget> rows = [];

    for (int i = 0; i < numbers.length; i++) {
      List<String> individualNumbers = [];
      if (numbers[i] is String) {
        individualNumbers = (numbers[i] as String).split(',').map((e) => e.trim()).toList();
      } else if (numbers[i] is List) {
        individualNumbers = (numbers[i] as List).map((e) => e.toString()).toList();
      }

      // ✅ Centered row of circles
      pw.Widget numberRow = pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Wrap(
            spacing: 5,
            runSpacing: 5,
            children:
                individualNumbers.map((num) {
                  return pw.Container(
                    width: 18,
                    height: 18,
                    alignment: pw.Alignment.center,
                    decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, border: pw.Border.all(width: 1)),
                    child: pw.Text(num, style: const pw.TextStyle(fontSize: 10)),
                  );
                }).toList(),
          ),
        ],
      );

      rows.add(numberRow);

      // ✅ Add game type only if numbers < 6
      if (gameTypes != null && i < gameTypes.length && individualNumbers.length < 6) {
        rows.add(pw.SizedBox(height: 6)); // small gap before game type

        String straight = gameTypes[i]['straight'] == true ? 'Yes' : 'No';
        String rumble = gameTypes[i]['rumble'] == true ? 'Yes' : 'No';
        String chance = gameTypes[i]['chance'] == true ? 'Yes' : 'No';

        rows.add(
          pw.Row(
            children: [
              pw.Text('Straight:', style: const pw.TextStyle(fontSize: 8)),
              pw.Text(straight, style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(width: 8),
              pw.Text('Rumble:', style: const pw.TextStyle(fontSize: 8)),
              pw.Text(rumble, style: const pw.TextStyle(fontSize: 8)),
              pw.SizedBox(width: 8),
              pw.Text('Chance:', style: const pw.TextStyle(fontSize: 8)),
              pw.Text(chance, style: const pw.TextStyle(fontSize: 8)),
            ],
          ),
        );
      }

      rows.add(pw.SizedBox(height: 12));
    }

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: rows);
  }

  static Future<bool> initialize({int retryCount = 0}) async {
    if (_isInitialized) {
      debugPrint('Printer already initialized');
      return true;
    }

    if (!await _isSunmiDevice()) {
      debugPrint('Non-Sunmi device detected, skipping printer status check');
      return false;
    }

    try {
      debugPrint('Checking printer status (Attempt ${retryCount + 1})...');
      final status = await _printer.getStatus();
      debugPrint('Printer status: $status');

      await Future.delayed(Duration(milliseconds: _statusDelayMs));

      if (status == PrinterStatus.READY) {
        await _printer.printText(text: 'Printer Ready', style: SunmiTextStyle());
        await _printer.lineWrap(times: 1);
        debugPrint('Test print successful');
        _isInitialized = true;
        debugPrint('Sunmi Printer is ready');
        return true;
      } else {
        debugPrint('Printer status is not NORMAL: $status');
        if (retryCount < _maxRetries) {
          debugPrint('Retrying status check (Attempt ${retryCount + 2})...');
          await Future.delayed(Duration(milliseconds: _statusDelayMs));
          return await initialize(retryCount: retryCount + 1);
        }
        return false;
      }
    } catch (e) {
      _isInitialized = false;
      debugPrint('Printer status check failed: $e');
      if (retryCount < _maxRetries && e.toString().contains('lateinit')) {
        debugPrint('Retrying status check (Attempt ${retryCount + 2})...');
        await Future.delayed(Duration(milliseconds: _statusDelayMs));
        return await initialize(retryCount: retryCount + 1);
      }
      return false;
    }
  }

  static void reset() {
    _isInitialized = false;
    debugPrint('Printer state reset');
  }

  static bool get isReady => _isInitialized;

  static Future<bool> safePrint(Function printFunction, {required Function pdfFunction}) async {
    try {
      if (!await _isSunmiDevice()) {
        debugPrint('Non-Sunmi device, generating PDF instead...');
        await pdfFunction();
        return true;
      }

      if (!_isInitialized) {
        debugPrint('Printer not initialized, checking status...');
        final initialized = await initialize();
        if (!initialized) {
          debugPrint('Status check failed, falling back to PDF...');
          await pdfFunction();
          return true;
        }
      }

      await printFunction();
      debugPrint('Print operation completed');
      return true;
    } catch (e) {
      debugPrint('Safe print failed: $e');
      if (e.toString().contains('lateinit')) {
        debugPrint('Retrying due to initialization error...');
        reset();
        final reinitialized = await initialize();
        if (reinitialized) {
          try {
            await printFunction();
            debugPrint('Retry print successful');
            return true;
          } catch (retryError) {
            debugPrint('Retry failed: $retryError, falling back to PDF...');
            await pdfFunction();
            return true;
          }
        } else {
          debugPrint('Retry status check failed, falling back to PDF...');
          await pdfFunction();
          return true;
        }
      }

      debugPrint('Falling back to PDF due to error: $e');
      await pdfFunction();
      return true;
    }
  }

  static Future<String> generatePdfInvoice({
    required String orderNumber,
    String? productName,
    String? orderDate,
    
    required String amount,
    required String purchasedBy,
    String? vat,
    String? prize,
    String? productImg,
    String? status,
    List<dynamic>? numbers,
    String? address,
    String? drawDate,
    List<Map<String, bool>>? ticketDetail,
    String? assetImagePath,
    String? productImagePath,
  }) async {
    try {
      final pdf = pw.Document();

      final qrData = _generateQRData(
        orderNumber: orderNumber,
        productName: productName ?? "",
        orderDate: orderDate ?? "",
      );

      // ✅ Load logo image (optional fallback)
      pw.MemoryImage? logoImage;
      try {
        final imageBytes = await rootBundle.load('assets/images/logo.png');
        logoImage = pw.MemoryImage(imageBytes.buffer.asUint8List());
      } catch (e) {
        debugPrint("Failed to load logo image: $e");
      }

      // ✅ Load product image (optional fallback)
      pw.MemoryImage? productImage;
      if (productImagePath != null && productImagePath.isNotEmpty) {
        try {
          final productBytes = await rootBundle.load(productImagePath);
          productImage = pw.MemoryImage(productBytes.buffer.asUint8List());
        } catch (e) {
          debugPrint("Failed to load product image: $e");
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.roll57,
          build:
              (pw.Context context) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  if (logoImage != null) pw.Image(logoImage, height: 50),
                  pw.SizedBox(height: 16),
                  if (productName != null)
                    pw.Container(
                      width: double.maxFinite,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 0.5, style: pw.BorderStyle.solid),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Center(child: pw.Text(productName, style: pw.TextStyle(fontSize: 12))),
                    ),
                  pw.SizedBox(height: 10),

                  if (productImage != null) ...[
                    pw.Center(child: pw.Image(productImage, width: 150, height: 150)),
                    pw.SizedBox(height: 10),
                  ],

                  // Info section
                  pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        buildInfoRow('Product Name:', productName ?? ""),
                        pw.Divider(thickness: 0.5),
                        buildInfoRow('Order No#:', orderNumber),
                        pw.Divider(thickness: 0.5),
                        buildInfoRow('Order Status:', status ?? ""),
                        pw.Divider(thickness: 0.5),
                        buildInfoRow('Purchased By:', purchasedBy),
                        pw.Divider(thickness: 0.5),
                        buildInfoRow('VAT %:', vat ?? ""),
                        pw.Divider(thickness: 0.5),
                        buildInfoRow('Total Amount:', amount),
                        pw.Divider(thickness: 0.5),
                        buildInfoRow('Order Date:', orderDate ?? ""),
                        pw.Divider(thickness: 0.5),
                        buildInfoRow('Draw Date:', drawDate ?? ""),
                        pw.Divider(thickness: 0.5),
                        buildInfoRow('Raffle Prize:', prize ?? ""),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 16),

                  pw.Text('Ticket Numbers:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  ticketNumbers(numbers ?? [], ticketDetail),
                  pw.SizedBox(height: 24),

                  // QR
                  pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: qrData, width: 75, height: 75),
                  pw.SizedBox(height: 8),
                  pw.Text(orderNumber, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 10),

                  // Address
                  if (address != null && address.isNotEmpty)
                    pw.Text(address, style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.center),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Website: https://foryouwin.com/',
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
        ),
      );

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/invoice_$orderNumber.pdf');
      await file.writeAsBytes(await pdf.save());

      debugPrint('✅ PDF saved at: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('❌ PDF generation failed: $e');
      return '';
    }
  }

  static Future<bool> printInvoice({
    required String orderNumber,
    String? productName,
    required String orderDate,
    required String amount,
    String? drawDate,
    required String purchasedBy,
    String? vat,
    List<Map<String, bool>>? ticketDetail,
    String? prize,
    String? status,
    List<dynamic>? numbers,
    String? address,
    String? assetImagePath,
    String? productImagePath,
  }) async {
    return await safePrint(
      () async {
        debugPrint('Starting invoice print with individual game types...');
        try {
          await _printAssetImage('assets/images/logo.png', width: 120);
        } catch (e) {
          await _printer.printText(
            text: 'LOGO',
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 14, bold: true),
          );
          await _printer.lineWrap(times: 1);
        }

        await _printer.printText(text: '................................');
        await _printer.printText(
          text: productName ?? "",
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true, fontSize: 12),
        );
        await _printer.printText(text: '................................');
        await _printer.lineWrap(times: 2);

        await _printProductImage(productImagePath);

        await _printer.printText(
          text: 'Product Name:    $productName',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
        );
        await _printer.printText(
          text: 'Order#:          $orderNumber',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
        );
        await _printer.printText(
          text: 'Order Status:    $status',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
        );
        await _printer.printText(
          text: 'Purchased By:    $purchasedBy',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
        );
        await _printer.printText(
          text: 'VAT %:           ${vat ?? 'N/A'}',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
        );
        await _printer.printText(
          text: 'Total Amount:    $amount',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
        );
        await _printer.printText(
          text: 'Order Date:      $orderDate',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
        );
        await _printer.printText(
          text: 'Draw Date:       $drawDate',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
        );
        await _printer.printText(
          text: 'Raffle Prize:    $prize',
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT, fontSize: 10),
        );

        await _printer.lineWrap(times: 2);

        await _printer.lineWrap(times: 2);

        await _printTicketNumbers(numbers!, ticketDetail);

        await _printer.lineWrap(times: 2);

        try {
          // ✅ UPDATED: Use the new QR format
          final qrData = _generateQRData(
            orderNumber: orderNumber,
            productName: productName ?? "",
            orderDate: orderDate,
          );

          await SunmiPrinter.printQRCode(
            qrData,
            style: SunmiQrcodeStyle(qrcodeSize: 6, errorLevel: SunmiQrcodeLevel.LEVEL_H),
          );

          await _printer.lineWrap(times: 1);

          await _printer.printText(
            text: orderNumber,
            style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 10, bold: true),
          );

          await _printer.lineWrap(times: 2);
          debugPrint('QR code printed successfully');
        } catch (qrError) {
          debugPrint('QR code printing failed: $qrError');
        }

        await _printer.printText(
          text: address ?? "",
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 10),
        );
        await _printer.printText(
          text: 'Website: https://foryouwin.com/',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 10),
        );

        await _printer.lineWrap(times: 3);
        await _printer.cutPaper();

        debugPrint('Invoice print completed with individual game types');
      },
      pdfFunction: () async {
        final pdfPath = await generatePdfInvoice(
          orderNumber: orderNumber,
          productName: productName ?? "",
          orderDate: orderDate,
          productImg: productImagePath ?? "",
          amount: amount,
          drawDate: drawDate ?? "",
          purchasedBy: purchasedBy,
          vat: vat ?? "N/A",
          prize: prize ?? "",
          status: status ?? "",
          numbers: numbers ?? [],
          address: address ?? "",
          ticketDetail: ticketDetail ?? [],
          assetImagePath: assetImagePath,
          productImagePath: productImagePath,
        );

        if (pdfPath.isNotEmpty) {
          debugPrint('PDF generated successfully at: $pdfPath');
        } else {
          debugPrint('PDF generation failed');
        }
      },
    );
  }

  static Future<bool> testPrint() async {
    // ✅ UPDATED: Test with sample game types
    List<Map<String, bool>> testGameTypes = [
      {'straight': true, 'rumble': false, 'chance': true},
      {'straight': false, 'rumble': true, 'chance': false},
      {'straight': true, 'rumble': true, 'chance': true},
    ];

    return await safePrint(
      () async {
        debugPrint('Starting test print...');

        await _printer.printText(
          text: '=== TEST PRINT ===',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, bold: true, fontSize: 16),
        );
        await _printer.lineWrap(times: 1);

        await _printer.printText(
          text: 'Printer is working!',
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 12),
        );
        await _printer.printText(text: '------------------------');

        // ✅ UPDATED: Test with individual game types
        await _printTicketNumbers([11, 22, 33], testGameTypes);

        try {
          final testQrData = _generateQRData(orderNumber: 'TEST123', productName: 'Click-2', orderDate: '07 Jul 2025');

          await SunmiPrinter.printQRCode(
            testQrData,
            style: SunmiQrcodeStyle(qrcodeSize: 5, errorLevel: SunmiQrcodeLevel.LEVEL_H),
          );
          await SunmiPrinter.lineWrap(1);
          debugPrint('Test QR code printed');
        } catch (qrError) {
          debugPrint('Test QR code failed: $qrError');
        }

        await _printer.printText(text: '------------------------');
        await _printer.lineWrap(times: 2);
        await _printer.cutPaper();

        debugPrint('Test print completed');
      },
      pdfFunction: () async {
        final pdf = pw.Document();
        List<Map<String, bool>> testGameTypes = [
          {'straight': true, 'rumble': false, 'chance': true},
          {'straight': false, 'rumble': true, 'chance': false},
          {'straight': true, 'rumble': true, 'chance': true},
        ];

        // ✅ UPDATED: Use the new QR format for test PDF
        final testQrData = _generateQRData(orderNumber: 'TEST123', productName: 'Click-2', orderDate: '07 Jul 2025');

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.roll57,
            build:
                (pw.Context context) => pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('=== TEST PRINT ===', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    pw.Text('Printer is working!', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text('------------------------'),
                    pw.SizedBox(height: 10),
                    // ✅ UPDATED: Test with individual game types
                    ticketNumbers([11, 22, 33], testGameTypes),
                    pw.SizedBox(height: 10),
                    pw.BarcodeWidget(barcode: pw.Barcode.qrCode(), data: testQrData, width: 60, height: 60),
                    pw.SizedBox(height: 10),
                    pw.Text('------------------------'),
                  ],
                ),
          ),
        );

        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/test_print.pdf');
        await file.writeAsBytes(await pdf.save());

        debugPrint('Test PDF saved at: ${file.path}');
      },
    );
  }

  static Future<bool> checkPrinterAvailability() async {
    try {
      if (!await _isSunmiDevice()) {
        debugPrint('Non-Sunmi device, skipping availability check');
        return false;
      }

      if (!_isInitialized) {
        debugPrint('Checking printer status for availability...');
        final initialized = await initialize();
        if (!initialized) {
          debugPrint('Printer status check failed during availability check');
          return false;
        }
      }

      debugPrint('Printer is available');
      return true;
    } catch (e) {
      debugPrint('Printer availability check failed: $e');
      return false;
    }
  }
}

/*************  ✨ Windsurf Command ⭐  *************/
/// Build a row of text with a label and value, left-aligned and right-aligned
/// respectively, with a font size of 8.
///
/// This is used to print information in the invoice, such as the ticket number,
/// draw date, and prize amount.
/// *****  c143bc30-3218-4263-aa94-ac382ae79f38  ******
pw.Widget buildInfoRow(String label, String value) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 8)),
      pw.Text(value, style: const pw.TextStyle(fontSize: 8)),
    ],
  );
}
