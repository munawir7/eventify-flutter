
import '../../../domain/entities/seat.dart';

class SeatModel extends Seat {
  const SeatModel({
    super.id,
    required super.eventId,
    required super.seatNumber,
    required super.category,
    required super.price,
    super.status = 'available',
  });

  factory SeatModel.fromEntity(Seat seat) {
    if (seat is SeatModel) return seat;
    return SeatModel(
      id: seat.id,
      eventId: seat.eventId,
      seatNumber: seat.seatNumber,
      category: seat.category,
      price: seat.price,
      status: seat.status,
    );
  }

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
