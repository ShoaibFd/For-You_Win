import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/components/app_text.dart';
import 'package:for_u_win/core/constants/app_colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DownloadButton extends StatefulWidget {
  const DownloadButton({super.key, required this.orderNumber, required this.productName});
  final String orderNumber;
  final String productName;
  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _isDownloading = false;
  final GlobalKey _invoiceKey = GlobalKey();
  Future<void> _captureAndDownloadScreenshot() async {
    setState(() {
      _isDownloading = true;
    });

    try {
      // Capture screenshot
      RenderRepaintBoundary boundary = _invoiceKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Get temporary directory and save file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/invoice_${widget.orderNumber}_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Invoice Screenshot - Order ${widget.orderNumber}',
        subject: 'Invoice - ${widget.productName}',
      );
    } catch (e) {
      log('Error capturing screenshot: $e');
      if (mounted) {
        AppSnackbar.showErrorSnackbar('Error capturing screenshot: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isDownloading ? null : _captureAndDownloadScreenshot,
      icon:
          _isDownloading
              ? SizedBox(
                width: 20.sp,
                height: 20.sp,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
              : Icon(Icons.download, size: 20.sp),
      label: AppText(_isDownloading ? 'Downloading...' : 'Download', fontSize: 14.sp, color: primaryColor),
      style: ElevatedButton.styleFrom(
        backgroundColor: whiteColor,
        foregroundColor: primaryColor,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r), side: BorderSide(color: primaryColor)),
        elevation: 0,
      ),
    );
  }
}
