import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:for_u_win/components/app_snackbar.dart';
import 'package:for_u_win/data/app_urls.dart';
import 'package:for_u_win/data/models/products/buy_now_response.dart';
import 'package:for_u_win/data/models/products/invoice_response.dart';
import 'package:for_u_win/data/models/products/products_detail_response.dart';
import 'package:for_u_win/data/models/products/products_response.dart';
import 'package:for_u_win/pages/products/invoice_page/generate_invoice_page.dart';
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

  InvoiceResponse? _invoiceResponse;
  InvoiceResponse? get invoiceResponse => _invoiceResponse;

  // Fetch Products Function!!
  Future<void> fetchProducts() async {
    try {
      _isLoading = true;
      Future.microtask(() => notifyListeners());
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
    Future.microtask(() => notifyListeners());
  }

  // Buy Products Function!!
  Future<void> buyProduct(BuyNowModel request, int productId) async {
    try {
      final token = await _sharedPrefs.getToken();
      _isLoading = true;
      Future.microtask(() => notifyListeners());
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
      Future.microtask(() => notifyListeners());
    }
  }

  // Fetch Products Details Function!!
  Future<void> fetchProductsDetails(int productId) async {
    try {
      _isLoading = true;
      Future.microtask(() => notifyListeners());
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
    Future.microtask(() => notifyListeners());
  }

  Future<String?> purchaseTicket(PurchaseTicketModel request) async {
    try {
      final token = await _sharedPrefs.getToken();
      _isLoading = true;
      Future.microtask(() => notifyListeners());

      // Debug: Print the request data before sending
      log('Purchase Request Data: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        Uri.parse(purchaseTicketUrl),
        body: jsonEncode(request.toJson()),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      );

      log('Response in Purchase Ticket: ${response.statusCode}:${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        final orderNumber = jsonData['orderNumber'];
        // AppSnackbar.showSuccessSnackbar(jsonData['message'] ?? 'Purchase successful!');
        return orderNumber?.toString();
      } else {
        final jsonData = jsonDecode(response.body);
        AppSnackbar.showErrorSnackbar(jsonData['message'] ?? 'Purchase failed');
        return null;
      }
    } catch (e) {
      log('Error During Purchasing Products: $e');
      AppSnackbar.showErrorSnackbar('Network error. Please try again.');
      return null;
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<InvoiceResponse?> fetchInvoice(String orderNumber, List numbers, List<Map<String, bool>> gameTypesForPrinting, {int? index}) async {
    try {
      _isLoading = true;
      Future.microtask(() => notifyListeners());
      final token = await _sharedPrefs.getToken();
      final response = await http.get(
        Uri.parse('$invoiceUrl/$orderNumber'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      );

      log('Response in fetch Invoice: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final invoice = InvoiceResponse.fromJson(jsonData);
        _invoiceResponse = invoice;

        // Extract straight, rumble, and chance for each ticket
        final List<Map<String, bool>> ticketDetails =
            invoice.tickets.map((ticket) {
              return {'straight': ticket.straight == 1, 'rumble': ticket.rumble == 1, 'chance': ticket.chance == 1};
            }).toList();

        Get.to(
          () => GenerateInvoicePage(
            numbers: numbers,
            ticketDetails: ticketDetails, 
            productImage: invoice.productImage,
            img: invoice.productImage,
            orderNumber: orderNumber,
            productName: invoice.productName,
            status: invoice.orderStatus,
            orderDate: invoice.orderDate,
            amount: invoice.totalAmount,
            purchasedBy: invoice.purchasedBy,
            vat: invoice.vat,
            prize: invoice.prize,
            address: invoice.companyDetails.address,
            drawDate: invoice.drawDate,
          ),
        );

        return invoice;
      } else {
        log('Failed to fetch invoice. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching invoice: $e');
    }

    _isLoading = false;
    Future.microtask(() => notifyListeners());
    return null;
  }
}
