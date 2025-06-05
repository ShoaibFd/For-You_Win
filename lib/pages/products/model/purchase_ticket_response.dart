class PurchaseTicketModel {
  final int productId;
  final List<Ticket> tickets;

  PurchaseTicketModel({required this.productId, required this.tickets});

  Map<String, dynamic> toJson() => {
    "product_id": productId,
    "tickets": tickets.map((ticket) => ticket.toJson()).toList(),
  };
}

class Ticket {
  final List<int> numbers;
  final List<String>? gameTypes;

  Ticket({required this.numbers, this.gameTypes});

  Map<String, dynamic> toJson() => {"numbers": numbers, "game_types": gameTypes};
}
