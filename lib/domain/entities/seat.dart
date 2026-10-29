
class Seat {
  final int? id;
  final int eventId;
  final String seatNumber;
  final String category;
  final double price;
  final String status;

  const Seat({
    this.id,
    required this.eventId,
    required this.seatNumber,
    required this.category,
    required this.price,
    this.status = 'available',
  });
}
