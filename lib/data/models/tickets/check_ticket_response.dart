// Models
class CheckTicketResponse {
  final String status;
  final String message;
  final SuccessData? data;
  final ErrorDetails? errors;

  CheckTicketResponse({
    required this.status,
    required this.message,
    this.data,
    this.errors,
  });

  factory CheckTicketResponse.fromJson(Map<String, dynamic> json) {
    String status = json['status'] ?? '';
    String message = json['message'] ?? '';

    if (status == 'success') {
      return CheckTicketResponse(
        status: status,
        message: message,
        data: SuccessData.fromJson(json['data'] ?? {}),
      );
    } else {
      return CheckTicketResponse(
        status: status,
        message: message,
        errors: ErrorDetails.fromJson(json['errors'] ?? {}),
      );
    }
  }

  bool get isSuccess => status == 'success';
}

class SuccessData {
  final String productName;
  final bool hasWinners;
  final List<Ticket> tickets;

  SuccessData({
    required this.productName,
    required this.hasWinners,
    required this.tickets,
  });

  factory SuccessData.fromJson(Map<String, dynamic> json) {
    return SuccessData(
      productName: json['product_name'] ?? '',
      hasWinners: json['has_winners'] ?? false,
      tickets: (json['tickets'] as List<dynamic>?)
              ?.map((ticket) => Ticket.fromJson(ticket))
              .toList() ??
          [],
    );
  }
}

class ErrorDetails {
  final String productName;

  ErrorDetails({required this.productName});

  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      productName: json['product_name'] ?? '',
    );
  }
}

class Ticket {
  final int ticketId;
  final String numbers;
  final String matchedNumbers;
  final int matchedPrice;

  Ticket({
    required this.ticketId,
    required this.numbers,
    required this.matchedNumbers,
    required this.matchedPrice,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticket_id'] ?? 0,
      numbers: json['numbers'] ?? '',
      matchedNumbers: json['matched_numbers'] ?? '',
      matchedPrice: json['matched_price'] ?? 0,
    );
  }
}
