import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/pages/products/invoice_page/components/info_row.dart';
import 'package:for_u_win/pages/products/invoice_page/generate_invoice_page.dart';

class InvoiceDetails extends StatelessWidget {
  final GenerateInvoicePage widget;

  const InvoiceDetails({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Image.network(widget.productImage, height: 60.h),
          SizedBox(height: 10.h),
          infoRow('Product:', widget.productName),
          Divider(),
          infoRow('Total Price:', '${(double.tryParse(widget.amount) ?? 0).toStringAsFixed(0)} AED'),
          Divider(),
          infoRow('Order No:', '#${widget.orderNumber}'),
          Divider(),
          infoRow('VAT %:', widget.vat),
          Divider(),
          infoRow('Order Status:', widget.status, isHighlighted: true),
          Divider(),
          infoRow('Order Date:', widget.orderDate),
          Divider(),
          infoRow('Draw Date:', widget.drawDate),
          Divider(),
          infoRow('Reflex Draw Prize:', 'Rs.${widget.prize}', isHighlighted: true),
        ],
      ),
    );
  }
}
