class PurchaseTicketModel {
  final int productId;
  final List<Ticket> tickets;

  PurchaseTicketModel({required this.productId, required this.tickets});

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'tickets': tickets.map((ticket) => ticket.toJson()).toList()};
  }

  factory PurchaseTicketModel.fromJson(Map<String, dynamic> json) {
    return PurchaseTicketModel(
      productId: json['product_id'] ?? 0,
      tickets:
          (json['tickets'] as List<dynamic>?)
              ?.map((ticket) => Ticket.fromJson(ticket as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Ticket {
  final List<int> numbers;
  final List<String> gameTypes;

  Ticket({required this.numbers, required this.gameTypes});

  Map<String, dynamic> toJson() {
    return {'numbers': numbers, 'game_types': gameTypes};
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      numbers: (json['numbers'] as List<dynamic>?)?.map((number) => number as int).toList() ?? [],
      gameTypes: (json['game_types'] as List<dynamic>?)?.map((gameType) => gameType.toString()).toList() ?? [],
    );
  }
}
