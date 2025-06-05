class ProductsDetailsResponse {
  ProductsDetailsResponse({required this.status, required this.message, required this.data});

  final bool? status;
  final String? message;
  final Data? data;

  factory ProductsDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsDetailsResponse(
      status: json["status"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({required this.product, required this.numberOfCircles});

  final Product? product;
  final int? numberOfCircles;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      product: json["product"] == null ? null : Product.fromJson(json["product"]),
      numberOfCircles: json["numberOfCircles"],
    );
  }
}

class Product {
  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.vat,
    required this.page,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String? name;
  final String? image;
  final String? price;
  final String? vat;
  final String? page;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      price: json["price"],
      vat: json["vat"],
      page: json["page"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }
}
