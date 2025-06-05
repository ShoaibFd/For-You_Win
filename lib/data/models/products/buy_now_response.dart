class BuyNowModel {
  final int productId;
  final int quantity;
  final String vatPercentage;
  final double vat;
  final double totalAmount;

  BuyNowModel({
    required this.productId,
    required this.quantity,
    required this.vatPercentage,
    required this.vat,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'vatPercentage': vatPercentage,
      'vat': vat,
      'totalAmount': totalAmount,
    };
  }
}
