import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/data/app_urls.dart';
import 'package:for_u_win/data/models/buy_now_model.dart';
import 'package:for_u_win/data/models/products_detail_response.dart';
import 'package:for_u_win/data/models/products_response.dart';
import 'package:for_u_win/pages/products/model/purchase_ticket_response.dart';
import 'package:for_u_win/pages/products/purchase_page.dart';
import 'package:for_u_win/storage/shared_prefs.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProductsServices with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  final SharedPrefs _sharedPrefs = SharedPrefs();
  ProductsResponse? _productsData;
  ProductsResponse? get productsData => _productsData;

  ProductsDetailsResponse? _productsDetailData;
  ProductsDetailsResponse? get productsDetailData => _productsDetailData;

  // Fetch Products Function!!
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _sharedPrefs.getToken();
      final response = await http.get(
        Uri.parse(productsUrl),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );
      // Successful Response!!
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _productsData = ProductsResponse.fromJson(jsonData);
        log('Products Response: ${response.statusCode}');
      } else {
        log("Products fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      log("Dashboard error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

// Buy Products Function!!
  Future<void> buyProduct(BuyNowModel request, int productId) async {
    try {
      final token = await _sharedPrefs.getToken();
      _isLoading = true;
      notifyListeners();
      final response = await http.post(
        Uri.parse('$buyUrl/$productId'),
        body: jsonEncode(request.toJson()),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      log('${response.statusCode}: Product Bought Successfully!');
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.to(() => PurchasePage(productId: productId));
      }
    } catch (e) {
      log('Error During Buying Products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch Products Details Function!!
  Future<void> fetchProductsDetails(int productId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _sharedPrefs.getToken();
      final response = await http.get(
        Uri.parse("$productsDetailUrl$productId"),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      // Successful Response!!
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        _productsDetailData = ProductsDetailsResponse.fromJson(jsonData);
        log('Products Details Response: ${response.statusCode}${response.body}');
      } else {
        log("Products Details fetch failed: ${response.statusCode}");
      }
    } catch (e) {
      log("Products Details Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

   
// Buy Products Function!!
  Future<void> purchaseTicket(PurchaseTicketModel request) async {
    try {
      final token = await _sharedPrefs.getToken();
      _isLoading = true;
      notifyListeners();
      final response = await http.post(
        Uri.parse(purchaseTicketUrl),
        body: jsonEncode(request.toJson()),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );
      log('Response in Purchase Ticket: ${response.statusCode}:${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
       AppSnackbar.showSuccessSnackbar('Purchased Successfully!');
      }
    } catch (e) {
      log('Error During Purchasing Products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

}
