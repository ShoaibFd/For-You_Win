import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:for_u_win/data/app_urls.dart';
import 'package:for_u_win/data/models/dashboard_response.dart';
import 'package:for_u_win/storage/shared_prefs.dart';
import 'package:http/http.dart' as http;

class DashboardServices with ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final SharedPrefs _sharedPrefs = SharedPrefs();
  DashboardResponse? _dashboardData;
  DashboardResponse? get dashboardData => _dashboardData;

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _sharedPrefs.getToken();
      final response = await http.get(
        Uri.parse(dashboardUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      // Successful Response!!
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _dashboardData = DashboardResponse.fromJson(jsonData);
        log('Dashboard Response: ${response.statusCode}${response.body}');
      } else {
        log("Dashboard fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      log("Dashboard error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
