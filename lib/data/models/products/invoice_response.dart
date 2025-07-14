class InvoiceResponse {
  final String productName;
  final String orderNumber;
  final String orderStatus;
  final String vat;
  final String totalAmount;
  final String orderDate;
  final String purchasedBy;
  final String productImage;
  final List<Ticket> tickets;
  final String drawDate;
  final String prize;
  final CompanyDetails companyDetails;

  InvoiceResponse({
    required this.productName,
    required this.orderNumber,
    required this.orderStatus,
    required this.vat,
    required this.totalAmount,
    required this.orderDate,
    required this.purchasedBy,
    required this.productImage,
    required this.tickets,
    required this.drawDate,
    required this.prize,
    required this.companyDetails,
  });

  factory InvoiceResponse.fromJson(Map<String, dynamic> json) {
    final invoice = json['data']['invoice'];
    final ticketsList = json['data']['tickets'] as List;
    final companyDetails = json['data']['company_details'];

    List<Ticket> tickets = ticketsList.map((ticketJson) => Ticket.fromJson(ticketJson)).toList();

    return InvoiceResponse(
      productName: invoice['product_name'],
      orderNumber: invoice['order_number'],
      orderStatus: invoice['order_status'],
      vat: invoice['vat'],
      totalAmount: invoice['total_amount'],
      orderDate: invoice['order_date'],
      purchasedBy: invoice['purchased_by'],
      productImage: invoice['product_image'],
      tickets: tickets,
      drawDate: json['data']['draw_date'],
      prize: json['data']['raffle_draw_prize'],
      companyDetails: CompanyDetails.fromJson(companyDetails),
    );
  }
}

class Ticket {
  final List<String> numbers;
  final int straight;
  final int rumble;
  final int chance;
  final String productPage;

  Ticket({
    required this.numbers,
    required this.straight,
    required this.rumble,
    required this.chance,
    required this.productPage,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      numbers: List<String>.from(json['numbers']),
      straight: json['straight'],
      rumble: json['rumble'],
      chance: json['chance'],
      productPage: json['product_page'],
    );
  }
}

class CompanyDetails {
  final String logo;
  final String address;
  final String website;
  final String qrCodeUrl;

  CompanyDetails({required this.logo, required this.address, required this.website, required this.qrCodeUrl});

  factory CompanyDetails.fromJson(Map<String, dynamic> json) {
    return CompanyDetails(
      logo: json['logo'],
      address: json['address'],
      website: json['website'],
      qrCodeUrl: json['qr_code_url'],
    );
  }
}
