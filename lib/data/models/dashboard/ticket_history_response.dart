class TicketHistoryResponse {
  TicketHistoryResponse({required this.productName, required this.tickets});

  final String? productName;
  final List<Ticket> tickets;

  factory TicketHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TicketHistoryResponse(
      productName: json["product_name"],
      tickets: json["tickets"] == null ? [] : List<Ticket>.from(json["tickets"]!.map((x) => Ticket.fromJson(x))),
    );
  }
}

class Ticket {
  Ticket({
    required this.orderNumber,
    required this.drawDate,
    required this.orderDate,
    required this.orderStatus,
    required this.raffleDrawPrize,
    required this.numbers,
    required this.straight,
    required this.rumble,
    required this.chance,
    required this.createdAt,
    required this.isAnnounced,
  });

  final String? orderNumber;
  final DateTime? drawDate;
  final DateTime? orderDate;
  final int? orderStatus;
  final String? raffleDrawPrize;
  final String? numbers;
  final int? straight;
  final int? rumble;
  final int? chance;
  final DateTime? createdAt;
  final bool? isAnnounced;

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      orderNumber: json["order_number"],
      drawDate: DateTime.tryParse(json["draw_date"] ?? ""),
      orderDate: DateTime.tryParse(json["order_date"] ?? ""),
      orderStatus: json["order_status"],
      raffleDrawPrize: json["raffle_draw_prize"],
      numbers: json["numbers"],
      straight: json["straight"],
      rumble: json["rumble"],
      chance: json["chance"],
      createdAt: DateTime.tryParse(json["created_at"] ?? ""),
      isAnnounced: json["is_announced"],
    );
  }
}
