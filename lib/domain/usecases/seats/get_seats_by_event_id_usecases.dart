import 'package:eventify/data/repositories/seat_repositery.dart';

import '../../entities/seat.dart';

class GetSeatsByEventIdUseCase {
  final SeatRepository _repository;

  GetSeatsByEventIdUseCase(this._repository);

  Future<List<Seat>> call(int eventId) async {
    final List<Seat> result =
        await _repository.getSeatsByEventId(eventId);

    return result;
  }
}
