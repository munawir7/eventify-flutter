
class SeatModel {
  final int? id;
  final int eventId;
  final String seatNumber;
  final String category;
  final double price;
  final String status;

  const SeatModel({
    this.id,
    required this.eventId,
    required this.seatNumber,
    required this.category,
    required this.price,
    this.status = 'available',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'event_id': eventId,
      'seat_number': seatNumber,
      'category': category,
      'price': price,
      'status': status,
    };
  }

  factory SeatModel.fromMap(Map<String, dynamic> map) {
    return SeatModel(
      id: map['id'] as int?,
      eventId: map['event_id'] as int,
      seatNumber: map['seat_number'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      status: map['status'] as String,
    );
  }
}
