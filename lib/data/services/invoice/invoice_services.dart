import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/data/app_urls.dart';
import 'package:for_u_win/storage/shared_prefs.dart';
import 'package:http/http.dart' as http;

class InvoiceServices with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? _earningData;
  Map<String, dynamic>? get earningData => _earningData;

  final SharedPrefs _sharedPrefs = SharedPrefs();

  /// My Earnings Function
  Future<bool> postEarning(String reportType, {DateTime? startDate, DateTime? endDate}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _sharedPrefs.getToken();

      final Map<String, dynamic> requestBody = {
        'report_type': reportType,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await http.post(
        Uri.parse(myEarningUrl),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response in My Earning: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _earningData = responseData;
        return true;
      } else {
        print("Request failed: ${response.statusCode}");
        AppSnackbar.showErrorSnackbar('Failed to fetch earnings.');
        return false;
      }
    } catch (e) {
      print("Earning error: $e");
      AppSnackbar.showErrorSnackbar('Something went wrong. Please try again.');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear earning data
  void clearEarningData() {
    _earningData = null;
    notifyListeners();
  }

  /// Clear all data (added as requested)
  void clearData() {
    _earningData = null;
    _isLoading = false;
    notifyListeners();
  }
}
