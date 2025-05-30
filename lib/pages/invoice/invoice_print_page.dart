import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_drawer.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoicePrintPage extends StatelessWidget {
  const InvoicePrintPage({super.key});

// To Print Invoice!
  Future<pw.Document> _printInvoice() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        build:
            (pw.Context context) => [
              pw.Text("Hello Duniya!", style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 20),
              pw.Text("More content coming soon..."),
            ],
      ),
    );

    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(title: AppText('Print Invoice', fontSize: 16.sp, fontWeight: FontWeight.bold)),
      body: PdfPreview(build: (_) => _printInvoice().then((value) => value.save())),
    );
  }
}
