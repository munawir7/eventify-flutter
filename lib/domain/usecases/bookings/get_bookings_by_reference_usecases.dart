import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

class GetBookingByReferenceUseCase {
  final BookingRepository _repository;

  GetBookingByReferenceUseCase(this._repository);

  Future<Booking?> call(String reference) {
    return _repository.getBookingByReference(reference);
  }
}