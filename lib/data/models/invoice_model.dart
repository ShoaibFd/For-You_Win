class InvoiceModel {
  final String orderNumber;
  final String customerName;
  final String date;
  final double totalAmount;
  final List<InvoiceItem> items;

  InvoiceModel({
    required this.orderNumber,
    required this.customerName,
    required this.date,
    required this.totalAmount,
    required this.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      orderNumber: json['orderNumber'] ?? '',
      customerName: json['customerName'] ?? '',
      date: json['date'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      items: List<InvoiceItem>.from(
        json['items']?.map((x) => InvoiceItem.fromJson(x)) ?? [],
      ),
    );
  }
}

class InvoiceItem {
  final String name;
  final int quantity;
  final double price;
  final double total;

  InvoiceItem({
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
