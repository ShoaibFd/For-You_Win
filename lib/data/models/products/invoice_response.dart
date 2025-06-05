class InvoiceResponse {
  final String productName;
  final String orderNumber;
  final String orderStatus;
  final String vat;
  final String totalAmount;
  final String orderDate;
  final String purchasedBy;
  final String productImage;
  final List<String> numbers;
  final String drawDate;
  final String prize;
  final String logoUrl;
  final String address;
  final String website;
  final String qrCodeUrl;

  InvoiceResponse({
    required this.productName,
    required this.orderNumber,
    required this.orderStatus,
    required this.vat,
    required this.totalAmount,
    required this.orderDate,
    required this.purchasedBy,
    required this.productImage,
    required this.numbers,
    required this.drawDate,
    required this.prize,
    required this.logoUrl,
    required this.address,
    required this.website,
    required this.qrCodeUrl,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    final invoice = json['data']['invoice'];
    final tickets = json['data']['tickets'][0];
    final company = json['data']['company_details'];
    return InvoiceResponse(
      productName: invoice['product_name'],
      orderNumber: invoice['order_number'],
      orderStatus: invoice['order_status'],
      vat: invoice['vat'],
      totalAmount: invoice['total_amount'],
      orderDate: invoice['order_date'],
      purchasedBy: invoice['purchased_by'],
      productImage: invoice['product_image'],
      numbers: List<String>.from(tickets['numbers']),
      drawDate: json['data']['draw_date'],
      prize: json['data']['raffle_draw_prize'],
      logoUrl: company['logo'],
      address: company['address'],
      website: company['website'],
      qrCodeUrl: company['qr_code_url'],
    );
  }
}
