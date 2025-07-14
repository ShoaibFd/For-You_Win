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
  final List<String> numbers;
  final List<String> gameTypes;

  Ticket({required this.numbers, required this.gameTypes});

  Map<String, dynamic> toJson() {
    return {'numbers': numbers, 'game_types': gameTypes};
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    final rawNumbers = json['numbers'];

    List<String> parsedNumbers = [];

    if (rawNumbers is List && rawNumbers.isNotEmpty) {
      final first = rawNumbers.first;
      if (first is String) {
        // Handle case like: ["08, 05, 20, 12, 07, 09"]
        parsedNumbers = first.split(',').map((e) => e.trim().padLeft(2, '0')).toList();
      } else if (first is int) {
        // Handle direct list of ints: [8, 5, 20]
        parsedNumbers = rawNumbers.map((e) => e.toString().padLeft(2, '0')).toList();
      } else if (first is String) {
        // Already list of strings: ["08", "05", "20"]
        parsedNumbers = rawNumbers.map((e) => e.toString().padLeft(2, '0')).toList();
      }
    }

    return Ticket(
      numbers: parsedNumbers,
      gameTypes: (json['game_types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
