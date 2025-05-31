class ProductsResponse {
  ProductsResponse({required this.status, required this.message, required this.data});

  final bool? status;
  final String? message;
  final List<Datum> data;

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      status: json["status"],
      message: json["message"],
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }
}

class Datum {
  Datum({
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

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
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
