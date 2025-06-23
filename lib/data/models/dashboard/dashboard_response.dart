class DashboardResponse {
  DashboardResponse({required this.success, required this.message, required this.data});

  final bool? success;
  final String? message;
  final Data? data;

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }
}

class Data {
  Data({required this.banner, required this.products});

  final Banner? banner;
  final Products? products;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      banner: json["banner"] == null ? null : Banner.fromJson(json["banner"]),
      products: json["products"] == null ? null : Products.fromJson(json["products"]),
    );
  }
}

class Banner {
  Banner({required this.id, required this.url, required this.createdAt, required this.updatedAt});

  final int? id;
  final String? url;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json["id"],
      url: json["url"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      updatedAt: DateTime.tryParse(json["updated_at"] ?? ""),
    );
  }
}

class Products {
  Products({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  final int? currentPage;
  final List<Datum> data;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<Link> links;
  final dynamic nextPageUrl;
  final String? path;
  final int? perPage;
  final dynamic prevPageUrl;
  final int? to;
  final int? total;

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      currentPage: json["current_page"],
      data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      firstPageUrl: json["first_page_url"],
      from: json["from"],
      lastPage: json["last_page"],
      lastPageUrl: json["last_page_url"],
      links: json["links"] == null ? [] : List<Link>.from(json["links"]!.map((x) => Link.fromJson(x))),
      nextPageUrl: json["next_page_url"],
      path: json["path"],
      perPage: json["per_page"],
      prevPageUrl: json["prev_page_url"],
      to: json["to"],
      total: json["total"],
    );
  }
}

class Datum {
  Datum({required this.id, required this.name, required this.price});

  final int? id;
  final String? name;
  final String? price;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(id: json["id"], name: json["name"], price: json["price"]);
  }
}

class Link {
  Link({required this.url, required this.label, required this.active});

  final String? url;
  final String? label;
  final bool? active;

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(url: json["url"], label: json["label"], active: json["active"]);
  }
}
