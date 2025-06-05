import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:for_u_win/data/app_urls.dart';
import 'package:for_u_win/data/models/dashboard/dashboard_response.dart';
import 'package:for_u_win/data/models/dashboard/ticket_history_response.dart';
import 'package:for_u_win/storage/shared_prefs.dart';
import 'package:http/http.dart' as http;

class DashboardServices with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final SharedPrefs _sharedPrefs = SharedPrefs();
  DashboardResponse? _dashboardData;
  DashboardResponse? get dashboardData => _dashboardData;
  TicketHistoryResponse? _ticketHistoryData;
  TicketHistoryResponse? get ticketHistoryData => _ticketHistoryData;

  // Products or Dashboard functions
  Future<void> fetchDashboardData() async {
    try {
      _isLoading = true;
      Future.microtask(() => notifyListeners()); 
      final token = await _sharedPrefs.getToken();
      final response = await http.get(
        Uri.parse(dashboardUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      // Successful Response!!
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _dashboardData = DashboardResponse.fromJson(jsonData);
      } else {
        log("Dashboard fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      log("Dashboard error: $e");
    }

    _isLoading = false;
     Future.microtask(() => notifyListeners()); 
  }

  //
  Future<void> fetchHistory(String pageName) async {
   

    try {
       _isLoading = true;
     Future.microtask(() => notifyListeners()); 
      final token = await _sharedPrefs.getToken();
      final response = await http.get(
        Uri.parse('https://clone.foryouwin.com/api/product-tickets/$pageName'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      // Successful Response!!
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _ticketHistoryData = TicketHistoryResponse.fromJson(jsonData);
        log('Ticket History Response: ${response.statusCode}');
      } else {
        log("Ticket History fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      log("Ticket History error: $e");
    }

    _isLoading = false;
     Future.microtask(() => notifyListeners()); 
  }
}
