class ForYouTicketResponse {
  final List<Ticket> tickets;
  final double totalPrizeSum;

  ForYouTicketResponse({required this.tickets, required this.totalPrizeSum});

  factory ForYouTicketResponse.fromJson(Map<String, dynamic> json) {
    return ForYouTicketResponse(
      tickets: (json['tickets'] as List).map((e) => Ticket.fromJson(e)).toList(),
      totalPrizeSum: (json['totalPrizeSum'] as num).toDouble(),
    );
  }
}

class Ticket {
  final int id;
  final String eventName;
  final String seat;

  Ticket({required this.id, required this.eventName, required this.seat});

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(id: json['id'], eventName: json['eventName'], seat: json['seat']);
  }
}
