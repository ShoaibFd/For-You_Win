import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/data/app_urls.dart';
import 'package:for_u_win/data/models/tickets/check_ticket_response.dart';
import 'package:for_u_win/storage/shared_prefs.dart';
import 'package:http/http.dart' as http;

class TicketServices with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final SharedPrefs _sharedPrefs = SharedPrefs();

  CheckTicketResponse? _checkTicketResponse;
  String? errorMessage;

  CheckTicketResponse? get checkTicketResponse => _checkTicketResponse;
  String? get error => errorMessage;
  Map<String, dynamic>? _royalTicketData;
  Map<String, dynamic>? get royalTicketData => _royalTicketData;

  Map<String, dynamic>? _foryouTicketData;
  Map<String, dynamic>? get foryouTicketData => _foryouTicketData;

  Map<String, dynamic>? _megaTicketData;
  Map<String, dynamic>? get megaTicketData => _megaTicketData;

  Map<String, dynamic>? _thrillTicketData;
  Map<String, dynamic>? get thrillTicketData => _thrillTicketData;

  Map<String, dynamic>? _clickTicketData;
  Map<String, dynamic>? get clickTicketData => _clickTicketData;

  // Royal Ticket Search Function!!
  Future<void> royalTicketSearch(String orderNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _sharedPrefs.getToken();

      final response = await http.post(
        Uri.parse('$royalTicketUrl/$orderNumber'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      log("Royal ticket response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData['status'] == 'success') {
          _royalTicketData = responseData;

          if (responseData['has_winners'] == true) {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'You have winning tickets!');
          } else {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'No winners, but data fetched successfully!');
          }
        } else {
          _royalTicketData = null;
          AppSnackbar.showErrorSnackbar(responseData['message'] ?? 'No ticket found!');
        }
      } else if (response.statusCode == 404) {
        AppSnackbar.showInfoSnackbar('Winning numbers not announced for this draw');
      } else {
        log("Ticket fetch failed: ${response.statusCode}");
        _royalTicketData = null;
      }
    } catch (e) {
      log("Ticket fetch error: $e");
      _royalTicketData = null;
      AppSnackbar.showErrorSnackbar('An error occurred while fetching ticket.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // For you Ticket Search!!
  Future<void> forYouTicketSearch(String orderNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _sharedPrefs.getToken();

      final response = await http.post(
        Uri.parse('$foryouTicketUrl/$orderNumber'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Updated to handle the direct response structure
        if (responseData['status'] == true) {
          _foryouTicketData = responseData;

          // Display appropriate message based on whether there are winners
          if (responseData['has_winners'] == true) {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'You have winning tickets!');
          } else {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'Data fetched successfully!');
          }
        } else {
          _foryouTicketData = null;
          AppSnackbar.showErrorSnackbar(responseData['message'] ?? 'No ticket found!');
        }
      } else if (response.statusCode == 404) {
        AppSnackbar.showInfoSnackbar('Winning numbers not announced for this draw');
      } else {
        log("Ticket fetch failed: ${response.statusCode}");
        _foryouTicketData = null;
      }
    } catch (e) {
      log("Ticket fetch error: $e");
      _foryouTicketData = null;
      AppSnackbar.showErrorSnackbar('An error occurred while fetching ticket.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mega Ticket Search!!
  Future<void> megaTicketSearch(String orderNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _sharedPrefs.getToken();

      final response = await http.post(
        Uri.parse('$megaTicketUrl/$orderNumber'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Updated to handle the direct response structure
        if (responseData['success'] == true) {
          _megaTicketData = responseData;

          // Display appropriate message based on whether there are winners
          if (responseData['hasWinners'] == true) {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'You have winning tickets!');
          } else {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'Data fetched successfully!');
          }
        } else {
          _megaTicketData = null;
          AppSnackbar.showErrorSnackbar(responseData['message'] ?? 'No ticket found!');
        }
      } else if (response.statusCode == 404) {
        AppSnackbar.showInfoSnackbar('Winning numbers not announced for this draw');
      } else {
        log("Ticket fetch failed: ${response.statusCode}");
        _megaTicketData = null;
      }
    } catch (e) {
      log("Ticket fetch error: $e");
      _megaTicketData = null;
      AppSnackbar.showErrorSnackbar('An error occurred while fetching ticket.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thrill-3 Ticket Search!!
  Future<void> thrillTicketSearch(String orderNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _sharedPrefs.getToken();

      final response = await http.post(
        Uri.parse('$thrillTicketUrl/$orderNumber'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Updated to handle the direct response structure
        if (responseData['status'] == true) {
          _thrillTicketData = responseData;

          // Display appropriate message based on whether there are winners
          if (responseData['has_winners'] == true) {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'You have winning tickets!');
          } else {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'Data fetched successfully!');
          }
        } else {
          _thrillTicketData = null;
          AppSnackbar.showErrorSnackbar(responseData['message'] ?? 'No ticket found!');
        }
      } else if (response.statusCode == 404) {
        AppSnackbar.showInfoSnackbar('Winning numbers not announced for this draw');
      } else {
        log("Ticket fetch failed: ${response.statusCode}");
        _thrillTicketData = null;
      }
    } catch (e) {
      log("Ticket fetch error: $e");
      _thrillTicketData = null;
      AppSnackbar.showErrorSnackbar('An error occurred while fetching ticket.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Click-2 Ticket Search!!
  Future<void> clickTicketSearch(String orderNumber) async {
    try {
      _isLoading = true;
      notifyListeners();

      final token = await _sharedPrefs.getToken();

      final response = await http.post(
        Uri.parse('$clickTicketUrl/$orderNumber'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Updated to handle the direct response structure
        if (responseData['status'] == true) {
          _clickTicketData = responseData;

          // Display appropriate message based on whether there are winners
          if (responseData['has_winners'] == true) {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'You have winning tickets!');
          } else {
            AppSnackbar.showSuccessSnackbar(responseData['message'] ?? 'Data fetched successfully!');
          }
        } else {
          _clickTicketData = null;
          AppSnackbar.showErrorSnackbar(responseData['message'] ?? 'No ticket found!');
        }
      } else if (response.statusCode == 404) {
        AppSnackbar.showInfoSnackbar('Winning numbers not announced for this draw');
      } else {
        log("Ticket fetch failed: ${response.statusCode}");
        _clickTicketData = null;
      }
    } catch (e) {
      log("Ticket fetch error: $e");
      _clickTicketData = null;
      AppSnackbar.showErrorSnackbar('An error occurred while fetching ticket.');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Pay Now Function
  Future<void> payTicket(String orderNumber, String price) async {
    try {
      _isLoading = true;
      notifyListeners();
      final token = await _sharedPrefs.getToken();
      final response = await http.post(
        Uri.parse('$payNowUrl/$orderNumber'),
        body: {'matched_price': price},
        headers: {'Authorization': 'Bearer $token'},
      );
      // Successful Response!!
      log('Response in Pay Ticket: ${response.statusCode}, ${response.body}');
      log('Order Number: $orderNumber and Price: $price');
      final jsonData = jsonDecode(response.body);
      if (response.statusCode == 200) {
        AppSnackbar.showSuccessSnackbar(jsonData['message']);
      } else {
        log("Payment failed: ${response.statusCode}");
        AppSnackbar.showSuccessSnackbar(jsonData['message']);
      }
    } catch (e) {
      log("Payment error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Check Ticket Function!!
  Future<CheckTicketResponse?> checkTicket(String orderNumber) async {
    try {
      final token = await _sharedPrefs.getToken();
      _isLoading = true;
      Future.microtask(() => notifyListeners());
      final response = await http.get(
        Uri.parse('$checkTicketUrl/$orderNumber'),
        headers: {'Authorization': 'Bearer $token'},
      );
      log('Check Ticket Response: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _checkTicketResponse = CheckTicketResponse.fromJson(jsonData);
        return _checkTicketResponse;
      }
    } catch (e) {
      log('Error during check Ticket: $e');
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
    return null;
  }

  // Helper methods to access specific data from the response
  List<Map<String, dynamic>>? get tickets {
    return _foryouTicketData?['tickets']?.cast<Map<String, dynamic>>();
  }

  List<String>? get winningNumbers {
    return _foryouTicketData?['winning_numbers']?.cast<String>();
  }

  String? get drawDate {
    return _foryouTicketData?['draw_date'];
  }

  String? get orderNumber {
    return _foryouTicketData?['order_number'];
  }

  bool get hasWinners {
    return _foryouTicketData?['has_winners'] ?? false;
  }

  int get totalPrizeSum {
    return _foryouTicketData?['total_prize_sum'] ?? 0;
  }

  // Get winning tickets only
  List<Map<String, dynamic>>? get winningTickets {
    return tickets?.where((ticket) => ticket['matched_price'] > 0).toList();
  }

  // Get non-winning tickets
  List<Map<String, dynamic>>? get nonWinningTickets {
    return tickets?.where((ticket) => ticket['matched_price'] == 0).toList();
  }
}
