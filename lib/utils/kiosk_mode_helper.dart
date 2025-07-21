import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Copy PDF to a user‑visible folder and return final path.
Future<String> robustSavePdf(File tempFile) async {
  try {
    // ➊ Attempt: public Downloads (path_provider 2.0+)
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      final dst = File(p.join(downloads.path, p.basename(tempFile.path)));
      return (await tempFile.copy(dst.path)).path;
    }

    // ➋ Attempt: manual /storage/emulated/0/Download (Android only)
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isGranted) {
        final legacy = Directory('/storage/emulated/0/Download');
        if (await legacy.exists()) {
          final dst = File(p.join(legacy.path, p.basename(tempFile.path)));
          return (await tempFile.copy(dst.path)).path;
        }
      }
    }

    // ➌ Fallback: app Documents (always writable & permanent)
    final docs = await getApplicationDocumentsDirectory();
    final dst = File(p.join(docs.path, p.basename(tempFile.path)));
    return (await tempFile.copy(dst.path)).path;
  } catch (e) {
    debugPrint('Save fallback failed: $e');
    return tempFile.path; // worst case: return temp path
  }
}
