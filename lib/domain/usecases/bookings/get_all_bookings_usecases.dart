import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

class GetAllBookingsUseCase {
  final BookingRepository _repository;

  GetAllBookingsUseCase(this._repository);

  Future<List<Booking>> call() {
    return _repository.getAllBookings();
  }
}