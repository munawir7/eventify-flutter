import '../../repositories/booking_repository.dart';

class CancelBookingUseCase {
final BookingRepository _repository;

CancelBookingUseCase(this._repository);

Future<bool> call(String bookingReference) {
return _repository.cancelBooking(bookingReference);
}
}
