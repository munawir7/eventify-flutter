
import '../entities/seat.dart';

abstract class SeatRepository {
  Future<List<Seat>> getSeatsByEventId(int eventId);

  Future<Seat?> getSeatById(int seatId);

  Future<List<Seat>> getSeatsByCategory({
    required int eventId,
    required String category,
  });
}
