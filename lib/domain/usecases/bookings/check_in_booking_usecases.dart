import '../../repositories/booking_repository.dart';

class CheckInBookingUseCase {
  final BookingRepository _repository;

  CheckInBookingUseCase(this._repository);

  Future<bool> call(String reference) {
    return _repository.checkInBooking(reference);
  }
}