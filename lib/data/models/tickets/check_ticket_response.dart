class CheckTicketResponse {
  final String status;
  final String message;
  final Data? data;
  final Errors? errors;

  CheckTicketResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory CheckTicketResponse.fromJson(Map<String, dynamic> json) {
    return CheckTicketResponse(
      status: json['status'],
      message: json['message'],
      data: json.containsKey('data') && json['data'] != null
          ? Data.fromJson(json['data'])
          : null,
      errors: json.containsKey('errors') && json['errors'] != null
          ? Errors.fromJson(json['errors'])
          : null,
    );
  }
}

class Errors {
  final String productName;
  final String drawDate;

  Errors({
    required this.productName,
    required this.drawDate,
  });

  factory Errors.fromJson(Map<String, dynamic> json) {
    return Errors(
      productName: json['product_name'],
      drawDate: json['draw_date'],
    );
  }
}

class Data {
  final String query;
  final String productName;
  final bool hasWinners;
  final List<Ticket> tickets;
  final String drawDate;
  final List<String> winningNumbers;
  final DrawWindow drawWindow;

  Data({
    required this.query,
    required this.productName,
    required this.hasWinners,
    required this.tickets,
    required this.drawDate,
    required this.winningNumbers,
    required this.drawWindow,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      query: json['query'],
      productName: json['product_name'],
      hasWinners: json['has_winners'],
      tickets: List<Ticket>.from(json['tickets'].map((x) => Ticket.fromJson(x))),
      drawDate: json['draw_date'],
      winningNumbers: List<String>.from(json['winning_numbers']),
      drawWindow: DrawWindow.fromJson(json['draw_window']),
    );
  }
}

class Ticket {
  final int ticketId;
  final String orderNumber;
  final String numbers;
  final String matchedNumbers;
  final String matchedPrice;
  final String orderDate;
  final String drawDate;
  final Candidate candidate;

  Ticket({
    required this.ticketId,
    required this.orderNumber,
    required this.numbers,
    required this.matchedNumbers,
    required this.matchedPrice,
    required this.orderDate,
    required this.drawDate,
    required this.candidate,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticket_id'],
      orderNumber: json['order_number'],
      numbers: json['numbers'],
      matchedNumbers: json['matched_numbers'],
      matchedPrice: json['matched_price'],
      orderDate: json['order_date'],
      drawDate: json['draw_date'],
      candidate: Candidate.fromJson(json['candidate']),
    );
  }
}

class Candidate {
  final String name;
  final String email;

  Candidate({
    required this.name,
    required this.email,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      name: json['name'],
      email: json['email'],
    );
  }
}

class DrawWindow {
  final String start;
  final String end;

  DrawWindow({
    required this.start,
    required this.end,
  });

  factory DrawWindow.fromJson(Map<String, dynamic> json) {
    return DrawWindow(
      start: json['start'],
      end: json['end'],
    );
  }
}
