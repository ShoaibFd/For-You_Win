// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:for_u_win/pages/products/invoice_page/generate_invoice_page.dart';
// import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';

// class PrintHelpers {
//   static Future<void> printInvoice(GenerateInvoicePage widget) async {
//     await SunmiPrinter.startTransactionPrint(true);

//     final ByteData byteData = await rootBundle.load('assets/images/logo.png');
//     final Uint8List imageBytes = byteData.buffer.asUint8List();
//     await SunmiPrinter.setAlignment(Alignment.center);
//     await SunmiPrinter.printImage(imageBytes);

//     await SunmiPrinter.lineWrap(1);
//     await SunmiPrinter.printText(widget.productName);
//     await SunmiPrinter.line();

//     await SunmiPrinter.setAlignment(Alignment.bottomLeft);
//     await _printTextRow('Order No:', widget.orderNumber);
//     await _printTextRow('Order Date:', widget.orderDate);
//     await _printTextRow('Status:', widget.status);
//     await _printTextRow('Buyer:', widget.purchasedBy);
//     await _printTextRow('Total:', 'PKR ${widget.amount}');
//     await _printTextRow('Draw Date:', widget.drawDate);
//     await _printTextRow('Prize:', widget.prize);
//     await SunmiPrinter.lineWrap(1);

//     for (int i = 0; i < widget.numbers.length; i++) {
//       await SunmiPrinter.printText('Ticket #${i + 1}');
//       final numberLine = widget.numbers[i].map((n) => n.toString().padLeft(2, '0')).join('  ');
//       await SunmiPrinter.printText(numberLine);
//       await SunmiPrinter.lineWrap(1);
//     }

//     await SunmiPrinter.line();
//     await SunmiPrinter.setAlignment(Alignment.center);
//     await SunmiPrinter.printText("Don't give up! You could be the next winner.");

//     String qrData = 'Order:${widget.orderNumber}|Product:${widget.productName}|Date:${widget.orderDate}';
//     await SunmiPrinter.printQRCode(qrData);
//     await SunmiPrinter.lineWrap(2);
//     await SunmiPrinter.printText(widget.address);
//     await SunmiPrinter.lineWrap(3);
//     await SunmiPrinter.exitTransactionPrint(true);
//   }

//   static Future<void> _printTextRow(String title, String value) async {
//     await SunmiPrinter.printText('$title $value');
//   }
// }
